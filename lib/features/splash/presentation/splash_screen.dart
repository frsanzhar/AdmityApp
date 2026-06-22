import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/features/profile/application/profile_notifier.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

// TODO(rive-asset): Deliver assets/rive/splash.riv from designer.
// State Machine contract: machine='SplashSM'
//   triggers — play   (starts light-sweep across "Admity" then fly-up)
// Until the asset lands the static text renders and a timer drives navigation.

/// Splash screen (DESIGN_SYSTEM.md §7.1).
///
/// After animation completes, loads the profile and routes:
///   - onboardingComplete == true → /home
///   - otherwise → /onboarding
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  RiveWidgetController? _controller;
  bool _riveReady = false;

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    final file = await loadRiveAsset(kSplashRivAsset);
    if (!mounted) return;

    final reduceMotion = MediaQuery.of(context).disableAnimations;

    if (file == null || reduceMotion) {
      // No asset or reduceMotion — use timer-based navigation.
      // reduceMotion path: 1800ms, no-asset path: 2200ms
      final delay = reduceMotion
          ? const Duration(milliseconds: 1800)
          : const Duration(milliseconds: 2200);
      _scheduleNavigation(delay);
      return;
    }

    RiveWidgetController? ctrl;
    try {
      ctrl = RiveWidgetController(
        file,
        stateMachineSelector: const StateMachineNamed(kSplashMachineName),
      );
      // ignore: avoid_catches_without_on_clauses // Must catch Error + Exception from Rive internals.
    } catch (_) {
      // State machine not found or native renderer unavailable — fall back to timer.
      _scheduleNavigation(const Duration(milliseconds: 2200));
      return;
    }

    if (!mounted) {
      ctrl.dispose();
      return;
    }

    setState(() {
      _controller = ctrl;
      _riveReady = true;
    });

    // Fire the play trigger — light-sweep + fly-up animation starts.
    // ignore: deprecated_member_use // SMI inputs deprecated in rive 0.14.x; assets not yet migrated.
    _controller?.stateMachine.trigger(kSplashTriggerPlay)?.fire();

    // Navigate after animation duration (light sweep ~800 ms + fly-up ~700 ms).
    _scheduleNavigation(const Duration(milliseconds: 2500));
  }

  void _scheduleNavigation(Duration delay) {
    unawaited(
      Future<void>.delayed(delay, () async {
        if (!mounted) return;
        try {
          final profile = await ref
              .read(profileRepositoryProvider)
              .loadProfile();
          if (!mounted) return;
          if (profile.onboardingComplete) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        } on Object catch (_) {
          // Any error — default to onboarding so the user can set up their profile.
          if (mounted) context.go('/onboarding');
        }
      }),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_riveReady || _controller == null) {
      final reduceMotion = MediaQuery.of(context).disableAnimations;

      final Widget wordmark;
      if (reduceMotion) {
        // Static — no shimmer or fly-up.
        wordmark = const Text(
          'Admity',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
            color: AppColors.ink,
          ),
        );
      } else {
        // Shimmer sweep left→right, then fly up + fade out.
        wordmark =
            const Text(
                  'Admity',
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    color: AppColors.ink,
                  ),
                )
                .animate(onPlay: (ctrl) => ctrl.forward())
                .shimmer(
                  delay: 300.ms,
                  duration: 900.ms,
                  color: Color.fromRGBO(
                    AppColors.primary.r.round(),
                    AppColors.primary.g.round(),
                    AppColors.primary.b.round(),
                    0.6,
                  ),
                )
                .then(delay: 200.ms)
                .slideY(
                  begin: 0,
                  end: -0.5,
                  duration: 600.ms,
                  curve: Curves.easeIn,
                )
                .fadeOut(duration: 500.ms);
      }

      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(child: wordmark),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: RiveWidget(
        controller: _controller!,
      ),
    );
  }
}
