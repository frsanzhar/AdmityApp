/// Sign-in / sign-up screen for Admity.
///
/// Supports email+password (toggle sign-in ↔ sign-up), Google, Apple, and
/// guest flows.  On success routes to /onboarding when the profile is
/// incomplete, or /home when onboarding is already done.
///
/// ## Social-button visibility
/// Google is shown only when [AppConfig.hasGoogle] && [AppConfig.hasSupabase].
/// Apple is shown only when [AppConfig.hasSupabase].
/// This prevents the "Error upon Google login" rejection Apple issued when both
/// env values were empty.
///
/// ## OTP sign-up flow
/// When Supabase has email-confirmation enabled, registering returns an
/// [AuthResult.otpPending] and the screen transitions to [_OtpStep], where
/// the user enters the 6-digit code from their inbox.
library;

import 'dart:async';

import 'package:admity/core/config/app_config.dart';
import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/auth/application/auth_providers.dart';
import 'package:admity/features/auth/data/auth_service.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_painter.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── AuthScreen ────────────────────────────────────────────────────────────────

/// The sign-in/sign-up entry point of the app.
///
/// Shown when the user has not authenticated yet (routed from `SplashScreen`
/// or directly via `/auth`).  On successful authentication the screen reads
/// [profileProvider] to determine whether onboarding is complete and routes
/// to `/onboarding` or `/home` accordingly.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates an [AuthScreen].
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  // ── Form controllers ────────────────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  // ── UI state ────────────────────────────────────────────────────────────────
  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ── OTP step state ──────────────────────────────────────────────────────────
  bool _showOtp = false;
  String _pendingOtpEmail = '';
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _navigateAfterAuth({bool saveAutofill = false}) {
    if (!mounted) return;
    if (saveAutofill) {
      TextInput.finishAutofillContext();
    }
    final profile = ref.read(profileProvider).profile;
    if (profile.onboardingComplete) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  // ── OTP timer ───────────────────────────────────────────────────────────────

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendCountdown--;
        if (_resendCountdown <= 0) {
          t.cancel();
          _resendCountdown = 0;
        }
      });
    });
  }

  // ── Auth handlers ───────────────────────────────────────────────────────────

  Future<void> _handleEmailAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _setLoading(true);
    final service = ref.read(authServiceProvider);
    final email = _emailCtrl.text.trim();
    final AuthResult result;
    if (_isSignUp) {
      result = await service.signUpWithEmail(
        email: email,
        password: _passwordCtrl.text,
      );
    } else {
      result = await service.signInWithEmail(
        email: email,
        password: _passwordCtrl.text,
      );
    }
    if (!mounted) return;
    if (result.needsOtp) {
      setState(() {
        _isLoading = false;
        _showOtp = true;
        _pendingOtpEmail = email;
        _errorMessage = null;
      });
      _startResendTimer();
      return;
    }
    _handleResult(result, saveAutofill: true);
  }

  Future<void> _handleVerifyOtp() async {
    if (!(_otpFormKey.currentState?.validate() ?? false)) return;
    _setLoading(true);
    final result = await ref.read(authServiceProvider).verifyOtp(
          email: _pendingOtpEmail,
          token: _otpCtrl.text.trim(),
        );
    if (!mounted) return;
    _handleResult(result, saveAutofill: true);
  }

  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;
    final result = await ref
        .read(authServiceProvider)
        .resendSignupOtp(email: _pendingOtpEmail);
    if (!mounted) return;
    if (result.ok) {
      _startResendTimer();
      _showSnackBar('Код отправлен повторно на $_pendingOtpEmail');
    } else {
      _showSnackBar(result.error ?? 'Не удалось отправить код.');
    }
  }

  Future<void> _handleGoogle() async {
    _setLoading(true);
    final result = await ref.read(authServiceProvider).signInWithGoogle();
    if (!mounted) return;
    if (result.ok) {
      _setLoading(false);
      _navigateAfterAuth();
    } else if (result.error != null && result.error != 'Вход отменён.') {
      _setLoading(false);
      _showSnackBar(result.error!);
    } else {
      _setLoading(false);
    }
  }

  Future<void> _handleApple() async {
    _setLoading(true);
    final result = await ref.read(authServiceProvider).signInWithApple();
    if (!mounted) return;
    if (result.ok) {
      _setLoading(false);
      _navigateAfterAuth();
    } else if (result.error != null && result.error != 'Вход отменён.') {
      _setLoading(false);
      _showSnackBar(result.error!);
    } else {
      _setLoading(false);
    }
  }

  void _handleResult(AuthResult result, {bool saveAutofill = false}) {
    if (!mounted) return;
    if (result.ok) {
      _setLoading(false);
      _navigateAfterAuth(saveAutofill: saveAutofill);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.error;
      });
    }
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
      _errorMessage = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    final showGoogle = AppConfig.hasGoogle && AppConfig.hasSupabase;
    final showApple = AppConfig.hasSupabase;
    final showSocialSection = showGoogle || showApple;

    return AppScaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.screenPadding,
            vertical: tokens.gapXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot — always visible in both steps.
              const MascotSlot(
                size: 100,
                mood: MascotMood.happy,
                flyIn: true,
              ).animate().fadeIn(duration: 400.ms),

              SizedBox(height: tokens.gapLg),

              if (_showOtp) ...[
                // ── OTP verification step ────────────────────────────────────
                _OtpStep(
                  email: _pendingOtpEmail,
                  otpCtrl: _otpCtrl,
                  formKey: _otpFormKey,
                  isLoading: _isLoading,
                  errorMessage: _errorMessage,
                  resendCountdown: _resendCountdown,
                  onVerify: _isLoading ? null : _handleVerifyOtp,
                  onResend: _resendCountdown > 0 ? null : _handleResendOtp,
                  onBack: _isLoading
                      ? null
                      : () => setState(() {
                            _showOtp = false;
                            _errorMessage = null;
                            _otpCtrl.clear();
                            _resendTimer?.cancel();
                            _resendCountdown = 0;
                          }),
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
              ] else ...[
                // ── Normal sign-in / sign-up step ────────────────────────────

                // Heading
                Text(
                  _isSignUp ? 'Создать аккаунт' : 'Добро пожаловать',
                  style: textTheme.headlineLarge?.copyWith(
                    color: AppColors.ink,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms, duration: 350.ms),

                SizedBox(height: tokens.gapSm),

                Text(
                  _isSignUp
                      ? 'Введите данные, чтобы начать'
                      : 'Войдите, чтобы продолжить',
                  style: textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 180.ms, duration: 350.ms),

                SizedBox(height: tokens.gapXxl),

                // Email / password form
                _EmailForm(
                  formKey: _formKey,
                  emailCtrl: _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  obscurePassword: _obscurePassword,
                  onToggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  isSignUp: _isSignUp,
                ).animate().fadeIn(delay: 240.ms, duration: 350.ms),

                if (_errorMessage != null) ...[
                  SizedBox(height: tokens.gapMd),
                  _ErrorBanner(message: _errorMessage!),
                ],

                SizedBox(height: tokens.gapLg),

                // Primary CTA (email auth)
                PrimaryButton(
                  label: _isSignUp ? 'Зарегистрироваться' : 'Войти',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _handleEmailAuth,
                ).animate().fadeIn(delay: 300.ms, duration: 350.ms),

                SizedBox(height: tokens.gapMd),

                // Toggle sign-in ↔ sign-up
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                            _errorMessage = null;
                          });
                        },
                  child: Text(
                    _isSignUp
                        ? 'Уже есть аккаунт? Войти'
                        : 'Нет аккаунта? Зарегистрироваться',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ).animate().fadeIn(delay: 340.ms, duration: 350.ms),

                if (showSocialSection) ...[
                  SizedBox(height: tokens.gapXl),

                  // Divider
                  const _OrDivider()
                      .animate()
                      .fadeIn(delay: 360.ms, duration: 350.ms),

                  SizedBox(height: tokens.gapXl),

                  if (showGoogle) ...[
                    _SocialButton(
                      label: 'Продолжить с Google',
                      icon: const _GoogleIcon(),
                      onPressed: _isLoading ? null : _handleGoogle,
                    ).animate().fadeIn(delay: 400.ms, duration: 350.ms),
                    SizedBox(height: tokens.gapMd),
                  ],

                  if (showApple)
                    _SocialButton(
                      label: 'Продолжить с Apple',
                      icon: const Icon(
                        Icons.apple,
                        size: 20,
                        color: AppColors.ink,
                      ),
                      onPressed: _isLoading ? null : _handleApple,
                    ).animate().fadeIn(delay: 440.ms, duration: 350.ms),
                ],

                SizedBox(height: tokens.gapLg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── _OtpStep ──────────────────────────────────────────────────────────────────

/// OTP verification step shown after a successful sign-up request.
///
/// Displays a 6-digit input, a verify button, and a resend control with a
/// 60-second countdown.
class _OtpStep extends StatelessWidget {
  const _OtpStep({
    required this.email,
    required this.otpCtrl,
    required this.formKey,
    required this.isLoading,
    required this.resendCountdown,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    this.errorMessage,
  });

  final String email;
  final TextEditingController otpCtrl;
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final String? errorMessage;
  final int resendCountdown;
  final VoidCallback? onVerify;
  final VoidCallback? onResend;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Введи код из письма',
          style: textTheme.headlineLarge?.copyWith(color: AppColors.ink),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.gapSm),
        Text(
          'Мы отправили 6-значный код на\n$email',
          style: textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.gapXxl),
        Form(
          key: formKey,
          child: AutofillGroup(
            child: TextFormField(
              controller: otpCtrl,
              autofillHints: const [AutofillHints.oneTimeCode],
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: textTheme.headlineMedium?.copyWith(
                color: AppColors.ink,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                hintStyle: textTheme.headlineMedium?.copyWith(
                  color: AppColors.inkSecondary,
                  letterSpacing: 8,
                ),
                filled: true,
                fillColor: AppColors.surfaceTint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(color: AppColors.errorRed),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.errorRed,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().length < 6) {
                  return 'Введите 6-значный код';
                }
                return null;
              },
              onFieldSubmitted: (_) => onVerify?.call(),
            ),
          ),
        ),
        if (errorMessage != null) ...[
          SizedBox(height: tokens.gapMd),
          _ErrorBanner(message: errorMessage!),
        ],
        SizedBox(height: tokens.gapLg),
        PrimaryButton(
          label: 'Подтвердить',
          isLoading: isLoading,
          onPressed: onVerify,
        ),
        SizedBox(height: tokens.gapMd),
        // Resend control with countdown.
        if (resendCountdown > 0)
          Text(
            'Отправить ещё раз через $resendCountdown с',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          )
        else
          TextButton(
            onPressed: onResend,
            child: Text(
              'Отправить код ещё раз',
              style: textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        SizedBox(height: tokens.gapSm),
        TextButton(
          onPressed: onBack,
          child: Text(
            '← Изменить email',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.inkSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── _EmailForm ────────────────────────────────────────────────────────────────

/// Email + password input form, reused for both sign-in and sign-up.
///
/// Wrapped in [AutofillGroup] so iOS/Android credential managers can offer
/// to save and fill the user's credentials.
class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.formKey,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isSignUp,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isSignUp;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;

    return AutofillGroup(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AuthTextField(
              controller: emailCtrl,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите email';
                if (!v.contains('@')) return 'Некорректный email';
                return null;
              },
            ),
            SizedBox(height: tokens.gapMd),
            _AuthTextField(
              controller: passwordCtrl,
              label: 'Пароль',
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: isSignUp
                  ? const [AutofillHints.newPassword]
                  : const [AutofillHints.password],
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.inkSecondary,
                  size: 20,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Введите пароль';
                if (isSignUp && v.length < 6) {
                  return 'Минимум 6 символов';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── _AuthTextField ────────────────────────────────────────────────────────────

/// Styled text field used in [_EmailForm].
class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      autofillHints: autofillHints,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.ink,
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: AppColors.inkSecondary, fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceTint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide:
              const BorderSide(color: AppColors.errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── _ErrorBanner ──────────────────────────────────────────────────────────────

/// Inline error banner shown below the form.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.errorRed,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _OrDivider ────────────────────────────────────────────────────────────────

/// "— или —" divider between email and social auth sections.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'или',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }
}

// ── _SocialButton ─────────────────────────────────────────────────────────────

/// Outlined social auth button (Google / Apple).
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.ink,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── _GoogleIcon ───────────────────────────────────────────────────────────────

/// Minimal hand-drawn "G" icon for the Google button.
///
/// Avoids a third-party icon package dependency — just a styled [Text] using
/// the system sans-serif, which renders identically on Android and iOS.
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4285F4), // Google blue
        fontFamily: 'sans-serif',
      ),
    );
  }
}
