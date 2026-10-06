import '../../imports/core_imports.dart';
import '../../imports/packages_imports.dart';

/// Opens the "I need help" sheet: one reassuring sentence, one phone number,
/// one way out.
///
/// Available from anywhere a user can get stuck. The message deliberately says
/// nothing is broken — fear of having damaged something is the most common
/// reason this audience abandons an app.
Future<void> showHelpSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceContainerLow,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.ml),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.r,
              height: 88.r,
              decoration: BoxDecoration(
                color: ctx.colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                size: 48.r,
                color: ctx.colors.onPrimaryContainer,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'home.help_title'.tr(),
              textAlign: TextAlign.center,
              style: ctx.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: ctx.colors.onSurface,
                height: 1.2,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'home.help_message'.tr(),
              textAlign: TextAlign.center,
              style: ctx.textTheme.bodyLarge?.copyWith(
                color: ctx.colors.onSurface,
                height: 1.3,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            // Show the number as text too — some users prefer to dial it on
            // their own handset rather than trust a button.
            Text(
              AppConfig.supportPhone,
              textAlign: TextAlign.center,
              style: ctx.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: ctx.colors.primary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'home.help_call'.tr(),
              prefixIcon: Icon(Icons.call_rounded, size: 28.r),
              height: ButtonSize.large,
              isFullWidth: true,
              onPressed: () {
                HapticFeedback.mediumImpact();
                launchUrl(Uri.parse('tel:${AppConfig.supportPhone}'));
              },
            ),
            SizedBox(height: AppSpacing.ms),
            AppButton(
              label: 'home.help_close'.tr(),
              variant: ButtonVariant.outline,
              height: ButtonSize.large,
              isFullWidth: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
