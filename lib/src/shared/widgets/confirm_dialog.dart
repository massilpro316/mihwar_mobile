import '../../imports/imports.dart';

/// Asks the user to confirm an action they cannot undo.
///
/// Built for elderly users:
/// - the *safe* choice is the dominant, filled button and is listed last
/// - the destructive choice is quieter and listed first
/// - tapping outside does nothing — only an explicit choice closes it
/// - both buttons are full width and 56 dp tall
///
/// Returns `true` only when the user explicitly confirmed.
///
/// Usage:
/// ```dart
/// final ok = await showConfirmDialog(
///   context,
///   title: 'profile.sign_out_title'.tr(),
///   message: 'profile.sign_out_message'.tr(),
///   confirmLabel: 'profile.sign_out_confirm'.tr(),
///   cancelLabel: 'shared.no_stay_here'.tr(),
/// );
/// if (ok) { /* proceed */ }
/// ```
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  IconData icon = Icons.help_outline_rounded,
  bool isDestructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.colors.surfaceContainerLow,
      insetPadding: EdgeInsets.all(AppSpacing.ml),
      icon: Icon(
        icon,
        size: 56.r,
        color: isDestructive ? ctx.colors.error : ctx.colors.primary,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: ctx.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: ctx.colors.onSurface,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: ctx.textTheme.bodyLarge?.copyWith(color: ctx.colors.onSurface),
      ),
      actionsPadding: EdgeInsets.fromLTRB(
        AppSpacing.ml,
        0,
        AppSpacing.ml,
        AppSpacing.ml,
      ),
      actions: [
        // Destructive choice — quieter, listed first.
        AppButton(
          label: confirmLabel,
          variant: isDestructive ? ButtonVariant.danger : ButtonVariant.outline,
          height: ButtonSize.large,
          isFullWidth: true,
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(ctx).pop(true);
          },
        ),
        SizedBox(height: AppSpacing.ms),
        // Safe choice — dominant, listed last.
        AppButton(
          label: cancelLabel,
          height: ButtonSize.large,
          isFullWidth: true,
          onPressed: () {
            HapticFeedback.selectionClick();
            Navigator.of(ctx).pop(false);
          },
        ),
      ],
    ),
  );

  return result ?? false;
}
