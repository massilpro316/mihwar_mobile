import 'package:mihwar/src/imports/core_imports.dart';
import 'package:mihwar/src/imports/packages_imports.dart';
import 'package:mihwar/src/features/auth/presentation/providers/auth_bloc.dart';

/// Sign-in screen.
///
/// The first thing a nervous user meets, so it does as little as possible:
/// two numbered questions, one big button, and a way to call a human. No
/// entrance animation — a screen that is still moving is a screen you cannot
/// start reading.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    context.hideKeyboard();
    context.read<AuthBloc>().add(LoginRequested(
          context: context,
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthBloc bloc) => bloc.state.isLoading);

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.ml),
          child: Form(
            key: _formKey,
            // Problems appear as the user types, not only after they press the
            // button and it seems to do nothing.
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: AppSpacing.lg),
                const _LoginHeader(),
                SizedBox(height: AppSpacing.xl),

                const _StepLabel(step: 1, text: 'auth.step_email'),
                AppTextField(
                  controller: _emailController,
                  enabled: !isLoading,
                  label: 'auth.email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 28.r,
                    color: context.colors.primary,
                  ),
                  validator: (v) {
                    if (AppUtils.isBlank(v)) return 'auth.email_required'.tr();
                    if (!AppUtils.isValidEmail(v!)) {
                      return 'auth.email_invalid'.tr();
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.ml),

                const _StepLabel(step: 2, text: 'auth.step_password'),
                AppTextField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  label: 'auth.password'.tr(),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => isLoading ? null : _handleLogin(),
                  prefixIcon: Icon(
                    Icons.lock_outline_rounded,
                    size: 28.r,
                    color: context.colors.primary,
                  ),
                  validator: (v) {
                    if (AppUtils.isBlank(v)) {
                      return 'auth.password_required'.tr();
                    }
                    if (v!.length < 6) return 'auth.password_too_short'.tr();
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.sm),

                // A labelled toggle, not a lone eye glyph — "what does the
                // crossed-out eye mean?" is a real question for this audience.
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 28.r,
                    ),
                    label: Text(
                      _obscurePassword
                          ? 'auth.show_password'.tr()
                          : 'auth.hide_password'.tr(),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 48.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'auth.login_button'.tr(),
                  prefixIcon: Icon(Icons.login_rounded, size: 28.r),
                  isLoading: isLoading,
                  isFullWidth: true,
                  height: ButtonSize.large,
                  onPressed: isLoading ? null : _handleLogin,
                ),

                SizedBox(height: AppSpacing.md),

                SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96.r,
          height: 96.r,
          padding: EdgeInsets.all(AppSpacing.ms),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.primaryContainer,
          ),
          child: Image.asset(
            'assets/logo/logo_mihwar.png',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
        SizedBox(height: AppSpacing.ml),
        Text(
          'auth.welcome_title'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
            height: 1.2,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'auth.welcome_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurface,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// ── Numbered step label ──────────────────────────────────────────────────────

/// Turns the form into two small steps instead of two boxes appearing at once.
class _StepLabel extends StatelessWidget {
  const _StepLabel({required this.step, required this.text});

  final int step;

  /// Translation key — resolved here so the widget stays `const` at call sites.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
