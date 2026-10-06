import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';

import 'package:mihwar/src/features/auth/presentation/providers/session_bloc.dart';

/// The home hub: a greeting and at most three large, labelled choices.
///
/// Designed for elderly and low-literacy users — no icon is ever alone, no
/// choice is smaller than 88 dp, and there is always a way to ask for help.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final user = session.user;
    final name = user?.name?.trim();

    return Scaffold(
      backgroundColor: context.colors.surface,
      // The hub is the root — a back arrow here leads nowhere, so there is
      // none. Home is where "back" is trying to get to.
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: context.colors.surface,
        title: Text(
          'home.home_title'.tr(),
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        // Always scrollable so the screen survives a 200% system font scale.
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.ml),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Greeting(name: name),
              SizedBox(height: AppSpacing.xl),
              Text(
                'home.what_to_do'.tr(),
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.md),

              // Each card carries its own colour, so the three choices can be
              // told apart before a single word is read. The accents are green
              // / blue / amber — `colorScheme.secondary` is not used here
              // because `fromSeed` derives it from the same green as primary
              // and the two cards would look alike.
              BigChoiceTile(
                icon: Icons.agriculture_rounded,
                label: 'home.my_farms'.tr(),
                subtitle: 'home.my_farms_hint'.tr(),
                color: context.colors.primary,
                onTap: () => context.go(AppRoutes.home, extra: HomeTab.farms),
              ),
              SizedBox(height: AppSpacing.md),
              BigChoiceTile(
                icon: Icons.person_rounded,
                label: 'home.my_profile'.tr(),
                subtitle: 'home.my_profile_hint'.tr(),
                color: context.appColors.info,
                onTap: () => context.go(AppRoutes.home, extra: HomeTab.profile),
              ),
              SizedBox(height: AppSpacing.md),
              BigChoiceTile(
                icon: Icons.support_agent_rounded,
                label: 'home.get_help'.tr(),
                subtitle: 'home.get_help_hint'.tr(),
                color: context.appColors.warning,
                onTap: () => showHelpSheet(context),
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big, warm greeting card — the first thing the user sees and reads.
///
/// A filled `primaryContainer` panel, so it reads as a welcome banner rather
/// than one more thing to tap.
class _Greeting extends StatelessWidget {
  const _Greeting({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final hasName = name != null && name!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(AppSpacing.ml),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.ml),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary
                .withOpacity(context.isDarkMode ? 0.18 : 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Decorative only — a screen reader should read the greeting, not
          // announce a waving hand.
          ExcludeSemantics(
            child: Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: context.colors.onPrimaryContainer.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_rounded,
                size: 36.r,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              hasName
                  ? 'home.greeting'.tr(args: [name!])
                  : 'home.greeting_no_name'.tr(),
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onPrimaryContainer,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
