import '../../imports/imports.dart';

/// A bare refresh icon, sized to stay tappable with a shaky thumb.
///
/// Lives in an app bar's `actions`, which Flutter mirrors to the **leading
/// (left) edge** in Arabic — the app's default locale — so the reload for a
/// list always sits in the same top corner. It carries no visible word on
/// purpose: it is one small repeat of an action the screen already explains,
/// and a full-width "Try Again" button in the middle of the list was pushing
/// the tasks themselves off screen. The word is still there for TalkBack and
/// for a long-press tooltip.
class RetryIconButton extends StatelessWidget {
  const RetryIconButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback onPressed;

  /// Defaults to the shared "Try Again" wording.
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final label = tooltip ?? 'shared.try_again'.tr();

    return Padding(
      padding: EdgeInsetsDirectional.only(end: AppSpacing.sm),
      child: Semantics(
        button: true,
        label: label,
        child: Tooltip(
          message: label,
          child: IconButton.outlined(
            // Comfortably past the 48 dp floor — this is the only way back
            // from an error on these screens.
            constraints: BoxConstraints(minWidth: 52.r, minHeight: 52.r),
            iconSize: 28.r,
            icon: const Icon(Icons.refresh_rounded),
            color: context.colors.primary,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onPressed();
            },
          ),
        ),
      ),
    );
  }
}
