import '../../imports/imports.dart';

/// A large, single-tap choice row: big icon + text label (+ optional subtitle).
///
/// Built for elderly / low-literacy users:
/// - 88 dp minimum height — hittable with a shaky thumb
/// - icon is never alone; it always carries a word
/// - thick 2 dp outline so the tap area is obvious in sunlight
/// - haptic feedback confirms the tap registered
///
/// Usage:
/// ```dart
/// BigChoiceTile(
///   icon: Icons.agriculture_rounded,
///   label: 'farm.my_farms'.tr(),
///   subtitle: 'farm.my_farms_hint'.tr(),
///   onTap: () => context.go(AppRoutes.home),
/// )
/// ```
class BigChoiceTile extends StatelessWidget {
  const BigChoiceTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primary;
    final isDisabled = onTap == null;
    final radius = BorderRadius.circular(AppSpacing.ml);
    final isDark = context.isDarkMode;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: subtitle == null ? label : '$label. $subtitle',
      child: ExcludeSemantics(
        // The shadow lives on an outer box: a BoxShadow declared on `Ink`
        // paints into the Material's canvas and never casts.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(isDark ? 0.16 : 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: context.colors.surfaceContainerLow,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              splashColor: accent.withOpacity(0.18),
              highlightColor: accent.withOpacity(0.10),
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      onTap!();
                    },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(
                    color: accent.withOpacity(isDark ? 0.55 : 0.40),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // Full-height accent stripe on the leading edge — mirrors
                    // automatically in Arabic.
                    PositionedDirectional(
                      start: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 8.w, color: accent),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: AppSpacing.ml + 8.w,
                        end: AppSpacing.md,
                        top: AppSpacing.md,
                        bottom: AppSpacing.md,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 88.h),
                        child: Row(
                          children: [
                            _IconBadge(icon: icon, accent: accent),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    label,
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: context.colors.onSurface,
                                      height: 1.2,
                                    ),
                                  ),
                                  if (subtitle != null) ...[
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      subtitle!,
                                      style: context.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: context.colors.onSurface,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (showChevron) ...[
                              SizedBox(width: AppSpacing.sm),
                              _Chevron(accent: accent),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The rounded icon plate. Large enough to be recognised before the words are
/// read, and tinted with the tile's own accent so each choice looks distinct.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r,
      height: 64.r,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.md),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(context.isDarkMode ? 0.30 : 0.18),
            accent.withOpacity(context.isDarkMode ? 0.16 : 0.08),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.30)),
      ),
      child: Icon(icon, size: 36.r, color: accent),
    );
  }
}

/// A filled circle around the arrow so the "this opens something" cue is
/// visible without reading — a bare chevron is easy to miss.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.accent});

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
        // Material's arrow icons do not mirror on their own — point it the way
        // the language reads.
        Directionality.of(context) == TextDirection.rtl
            ? Icons.arrow_back_ios_rounded
            : Icons.arrow_forward_ios_rounded,
        size: 20.r,
        color: accent,
      ),
    );
  }
}

/// A labelled information row — icon + what-it-is + the value, all at readable size.
///
/// Never renders a bare value: the label always says what the number or text means.
class BigInfoRow extends StatelessWidget {
  const BigInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.colors.primary;

    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.ms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.ms),
                ),
                child: Icon(icon, size: 28.r, color: accent),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
