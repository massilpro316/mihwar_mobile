import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../../domain/entities/farm_entity.dart';

/// One farm in the list.
///
/// Reads as a single large button: the whole card is one tap target, the name
/// is never truncated, and every fact is introduced by a word that says what
/// it means ("Size: 500 square metres") rather than sitting as a bare number
/// in a tiny chip.
class FarmCard extends StatelessWidget {
  const FarmCard({super.key, required this.farm});

  final FarmEntity farm;

  /// What a screen reader announces: the name, then each labelled fact.
  String _semanticLabel() {
    final parts = <String>[farm.name];

    if (farm.localisation != null && farm.localisation!.trim().isNotEmpty) {
      parts.add('${'farm.location'.tr()}: ${farm.localisation}');
    }
    if (farm.crop != null && farm.crop!.trim().isNotEmpty) {
      parts.add('${'farm.crop'.tr()}: ${farm.crop}');
    }
    if (farm.space != null) {
      parts.add(
        '${'farm.space'.tr()}: ${'farm.square_metres'.tr(args: [
              formatNumber(farm.space!)
            ])}',
      );
    }
    if (farm.quantity != null && farm.quantity!.trim().isNotEmpty) {
      parts.add('${'farm.quantity'.tr()}: ${farm.quantity}');
    }

    return parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.primary;
    final radius = BorderRadius.circular(AppSpacing.md);
    final isDark = context.isDarkMode;

    final facts = <Widget>[
      if (farm.localisation != null && farm.localisation!.trim().isNotEmpty)
        _FarmFact(
          icon: Icons.location_on_outlined,
          label: 'farm.location'.tr(),
          value: farm.localisation!,
        ),
      if (farm.space != null)
        _FarmFact(
          icon: Icons.square_foot_rounded,
          label: 'farm.space'.tr(),
          value: 'farm.square_metres'.tr(args: [formatNumber(farm.space!)]),
        ),
      if (farm.crop != null && farm.crop!.trim().isNotEmpty)
        _FarmFact(
          icon: Icons.eco_outlined,
          label: 'farm.crop'.tr(),
          value: farm.crop!,
        ),
      if (farm.quantity != null && farm.quantity!.trim().isNotEmpty)
        _FarmFact(
          icon: Icons.inventory_2_outlined,
          label: 'farm.quantity'.tr(),
          value: farm.quantity!,
        ),
    ];

    final phone = farm.dialablePhone;

    // Shadow on an outer box — a BoxShadow on `Ink` paints into the
    // Material's canvas and never casts.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(isDark ? 0.16 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: context.colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: accent.withOpacity(isDark ? 0.50 : 0.35),
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Leading accent stripe — mirrors in Arabic.
            PositionedDirectional(
              start: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 8.w, color: accent),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  button: true,
                  label: '${_semanticLabel()}. ${'farm.open_farm'.tr()}',
                  child: ExcludeSemantics(
                    child: InkWell(
                      splashColor: accent.withOpacity(0.18),
                      highlightColor: accent.withOpacity(0.10),
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        context.push(
                          AppRoutes.firmDetailPath(farm.id),
                          extra: farm,
                        );
                      },
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: AppSpacing.md + 8.w,
                          end: AppSpacing.md,
                          top: AppSpacing.md,
                          bottom: AppSpacing.md,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 88.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60.r,
                                    height: 60.r,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(AppSpacing.ms),
                                      color: accent.withOpacity(
                                        isDark ? 0.24 : 0.14,
                                      ),
                                      border: Border.all(
                                        color: accent.withOpacity(0.30),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.agriculture_rounded,
                                      size: 34.r,
                                      color: accent,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.md),
                                  // The name wraps. Truncating the one word that
                                  // tells farms apart is never acceptable.
                                  Expanded(
                                    child: Text(
                                      farm.name,
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: context.colors.onSurface,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.sm),
                                  _OpenChevron(accent: accent),
                                ],
                              ),
                              if (facts.isNotEmpty) ...[
                                SizedBox(height: AppSpacing.ms),
                                const AppDivider(),
                                SizedBox(height: AppSpacing.sm),
                                ...facts,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Its own tap target, outside the "open this farm" button, so
                // a screen reader announces it separately. Hidden — not
                // disabled — when there is no number to dial.
                if (phone != null)
                  _CallResponsibleButton(
                    phone: phone,
                    name: farm.responsibleName,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A full-width "Call the station" button at the foot of the card.
class _CallResponsibleButton extends StatelessWidget {
  const _CallResponsibleButton({required this.phone, this.name});

  /// Already reduced to digits and "+".
  final String phone;
  final String? name;

  Future<void> _call(BuildContext context) async {
    HapticFeedback.mediumImpact();

    var opened = false;
    try {
      opened = await launchUrl(
        Uri(scheme: 'tel', path: phone),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }

    if (!opened && context.mounted) {
      context.showErrorSnackBar('farm.call_responsible_failed'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasName = name != null && name!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.md + 8.w,
        end: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Semantics(
        button: true,
        label: hasName
            ? 'farm.call_responsible_named'.tr(args: [name!.trim()])
            : 'farm.call_responsible'.tr(),
        child: ExcludeSemantics(
          child: AppButton(
            label: 'farm.call_responsible'.tr(),
            variant: ButtonVariant.outline,
            prefixIcon: Icon(Icons.call_rounded, size: 28.r),
            height: ButtonSize.large,
            isFullWidth: true,
            onPressed: () => _call(context),
          ),
        ),
      ),
    );
  }
}

/// One labelled fact about the farm — "Size: 500 square metres".
///
/// A label always precedes the value, because a bare "500 m²" means nothing to
/// someone who is not already thinking in farm records.
class _FarmFact extends StatelessWidget {
  const _FarmFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28.r, color: context.colors.primary),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.colors.onSurface,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

/// A filled circle around the arrow, so "this opens something" is visible
/// without reading. The old 22 dp chevron at 18% opacity was invisible.
class _OpenChevron extends StatelessWidget {
  const _OpenChevron({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.r,
      height: 40.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withOpacity(context.isDarkMode ? 0.22 : 0.12),
      ),
      child: Icon(
        // Material's arrow icons do not mirror on their own.
        Directionality.of(context) == TextDirection.rtl
            ? Icons.arrow_back_ios_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 20.r,
        color: accent,
      ),
    );
  }
}
