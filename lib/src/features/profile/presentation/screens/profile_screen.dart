import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import '../providers/profile_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../../../core/di/injection_container.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const FetchProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

/// The user's account screen: who you are, then one clear way out.
///
/// No collapsing header, no gradients, no small text — every value is
/// introduced by a word that says what it is.
class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;

        return Scaffold(
          backgroundColor: context.colors.surface,
          // A tab root has nowhere to go "back" to — no back arrow here, or the
          // user will tap it expecting to return somewhere.
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: context.colors.surface,
            title: Text(
              'profile.title'.tr(),
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ),
          body: SafeArea(
            child: switch ((state.isLoading, profile)) {
              (true, _) => const _ProfileLoading(),
              (_, null) => const _ProfileError(),
              (_, final ProfileEntity p) => _ProfileContent(profile: p),
            },
          ),
        );
      },
    );
  }
}

// ── Loading ──────────────────────────────────────────────────────────────────

/// Never a bare spinner — always say what is happening.
class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.ml),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoading(),
            SizedBox(height: AppSpacing.ml),
            Text(
              'profile.loading'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error ────────────────────────────────────────────────────────────────────

/// Plain language, no blame, one big way forward.
class _ProfileError extends StatelessWidget {
  const _ProfileError();

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      icon: Icons.person_off_outlined,
      title: 'profile.error_title'.tr(),
      message: 'profile.error_message'.tr(),
      onRetry: () => context.read<ProfileBloc>().add(const FetchProfileEvent()),
    );
  }
}

// ── Content ──────────────────────────────────────────────────────────────────

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.ml),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHeader(profile: profile),
          SizedBox(height: AppSpacing.ml),
          const _ContactUsButton(),
          SizedBox(height: AppSpacing.xl),
          Text(
            'profile.your_details'.tr(),
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border:
                  Border.all(color: context.colors.outlineVariant, width: 2),
            ),
            child: Column(
              children: [
                BigInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'profile.name'.tr(),
                  value: profile.name,
                ),
                const AppDivider(),
                BigInfoRow(
                  icon: Icons.email_outlined,
                  label: 'profile.email'.tr(),
                  value: profile.email,
                ),
                const AppDivider(),
                BigInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'profile.phone'.tr(),
                  value: profile.phoneNumber?.trim().isNotEmpty ?? false
                      ? profile.phoneNumber!
                      : 'profile.not_given'.tr(),
                ),
                if (profile.grade != null &&
                    profile.grade!.trim().isNotEmpty) ...[
                  const AppDivider(),
                  BigInfoRow(
                    icon: Icons.work_outline_rounded,
                    label: 'profile.grade'.tr(),
                    value: profile.grade!,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          const _SignOutButton(),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

/// A large avatar, the name, and the role spelled out as a sentence.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.trim().isNotEmpty
        ? profile.name.trim()[0].toUpperCase()
        : '?';

    return Column(
      children: [
        Semantics(
          label: profile.name,
          child: ExcludeSemantics(
            child: CircleAvatar(
              radius: 52.r,
              backgroundColor: context.colors.primaryContainer,
              child: Text(
                initial,
                style: context.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        // Role as a full sentence — "You are Farmer", not a bare badge.
        Text(
          '${'profile.role'.tr()} ${profile.role}',
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
          ),
        ),
      ],
    );
  }
}

// ── Contact us ───────────────────────────────────────────────────────────────

/// One tap from the top of the account screen to the Support Center's phone.
///
/// Sits directly under the header because "I am stuck and want a human" is the
/// reason this audience opens the account screen at all. It opens the dialer
/// with the number already typed in rather than placing the call itself — the
/// user still presses the green button, so a mis-tap costs nothing.
class _ContactUsButton extends StatelessWidget {
  const _ContactUsButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: 'profile.contact_us'.tr(),
          prefixIcon: Icon(Icons.call_rounded, size: 28.r),
          height: ButtonSize.large,
          isFullWidth: true,
          onPressed: () async {
            HapticFeedback.mediumImpact();

            var opened = false;
            try {
              opened = await launchUrl(
                Uri(scheme: 'tel', path: AppConfig.supportPhone),
                mode: LaunchMode.externalApplication,
              );
            } catch (_) {
              opened = false;
            }

            // A handset with no dialer, or one that refuses the intent, would
            // otherwise look like the button did nothing at all. The number is
            // printed underneath, so there is still a way through.
            if (!opened && context.mounted) {
              context.showErrorSnackBar('profile.contact_us_failed'.tr());
            }
          },
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'profile.contact_us_hint'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.onSurface,
            height: 1.4,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        // The number in full, for anyone who would rather dial it by hand on
        // their own handset than trust a button.
        Text(
          AppConfig.supportPhone,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.primary,
          ),
        ),
      ],
    );
  }
}

// ── Sign out ─────────────────────────────────────────────────────────────────

/// Signing out is not undoable from inside the app, so it is always confirmed.
class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'profile.sign_out'.tr(),
      prefixIcon: Icon(Icons.logout_rounded, size: 28.r),
      variant: ButtonVariant.danger,
      height: ButtonSize.large,
      isFullWidth: true,
      onPressed: () async {
        final bloc = context.read<ProfileBloc>();

        final confirmed = await showConfirmDialog(
          context,
          icon: Icons.logout_rounded,
          title: 'profile.sign_out_title'.tr(),
          message: 'profile.sign_out_message'.tr(),
          confirmLabel: 'profile.sign_out_confirm'.tr(),
          cancelLabel: 'shared.no_stay_here'.tr(),
        );

        if (!confirmed || !context.mounted) return;
        bloc.add(SignOutEvent(context));
      },
    );
  }
}
