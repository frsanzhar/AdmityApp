import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/auth/presentation/auth_controller.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Two-step sign-in: pick a provider («Продолжить с Apple» /
/// «Продолжить с Gmail»). Gmail reveals an email field → «Получить код» →
/// a 6-digit code field → «Войти». Apple saves the session immediately.
///
/// A guest path keeps the app fully usable offline; when Supabase is not
/// configured the screen shows a clear notice instead of crashing.
class AuthScreen extends ConsumerStatefulWidget {
  /// Creates the auth screen.
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // The controller is a global Notifier, so its state survives across screen
    // opens. After a previous sign-in/sign-out it may still read `signedIn`,
    // which would trip the navigate-away listener the instant this screen
    // mounts. Start every visit from a clean provider-choice step.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(authControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _continueAsGuest() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final appleAvailable = ref.watch(appleAuthAvailableProvider);

    // When verification succeeds, leave the auth screen.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.step == AuthStep.signedIn &&
          prev?.step != AuthStep.signedIn) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.dashboard);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: state.step == AuthStep.chooseProvider
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: controller.reset,
                tooltip: 'Назад',
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: EralyAvatar(size: 96)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Добро пожаловать в Admity',
                style: context.text.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Войди, чтобы общаться с Ералы и сохранить аккаунт — '
                'или продолжи как гость.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.tokens.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              ..._stepBody(
                context,
                state: state,
                controller: controller,
                appleAvailable: appleAvailable,
              ),
              if (state.info != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _Banner(text: state.info!, tone: _BannerTone.info),
              ],
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                _Banner(text: state.error!, tone: _BannerTone.error),
              ],
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _continueAsGuest,
                child: const Text('Пропустить'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Тебе ещё нет 18? Мы собираем минимум данных и не '
                'передаём твои заметки и баллы третьим лицам. Продолжая, '
                'ты соглашаешься с политикой конфиденциальности.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _stepBody(
    BuildContext context, {
    required AuthState state,
    required AuthController controller,
    required bool appleAvailable,
  }) {
    switch (state.step) {
      case AuthStep.chooseProvider:
        return [
          if (appleAvailable) ...[
            _AppleButton(
              loading: state.busy,
              onPressed: controller.signInWithApple,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          PrimaryButton(
            label: 'Продолжить с Gmail',
            icon: Icons.mail_rounded,
            onPressed: state.busy ? null : controller.chooseGmail,
          ),
        ];

      case AuthStep.enterEmail:
        return [
          TextField(
            controller: _emailController,
            enabled: !state.busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'name@gmail.com',
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            onChanged: controller.setEmail,
            onSubmitted: (_) => controller.sendCode(),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Получить код',
            icon: Icons.send_rounded,
            loading: state.busy,
            onPressed: state.busy ? null : controller.sendCode,
          ),
        ];

      case AuthStep.enterCode:
        return [
          TextField(
            controller: _codeController,
            enabled: !state.busy,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(letterSpacing: 8),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              hintText: '••••••',
              labelText: 'Код из письма',
              counterText: '',
            ),
            onSubmitted: controller.verifyCode,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Войти',
            icon: Icons.login_rounded,
            loading: state.busy,
            onPressed: state.busy
                ? null
                : () => controller.verifyCode(_codeController.text),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: state.busy ? null : controller.resendCode,
            child: const Text('Отправить код ещё раз'),
          ),
        ];

      case AuthStep.signedIn:
        return [
          const SourceNote(text: 'Вход выполнен. Перенаправляем…'),
        ];
    }
  }
}

/// The black/white Apple sign-in button, styled to Apple's guidelines.
class _AppleButton extends StatelessWidget {
  const _AppleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.white : Colors.black;
    final fg = isDark ? Colors.black : Colors.white;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        ),
        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: fg),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apple_rounded, size: 22),
                  SizedBox(width: 8),
                  Text('Продолжить с Apple'),
                ],
              ),
      ),
    );
  }
}

enum _BannerTone { info, error }

/// A small inline status banner for info / error messages.
class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.tone});

  final String text;
  final _BannerTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = tone == _BannerTone.error ? tokens.danger : tokens.info;
    final icon = tone == _BannerTone.error
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadii.brSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: context.text.bodySmall
                  ?.copyWith(color: tokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
