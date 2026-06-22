import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/shared/rive/rive_assets.dart';
import 'package:admity/shared/rive/rive_loader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

// TODO(rive-asset): Deliver assets/rive/splash.riv from designer.
// State Machine contract: machine='SplashSM'
//   triggers — play   (starts light-sweep across "Admity" then fly-up)
// Until the asset lands the static text renders and a timer drives navigation.

/// Splash screen (DESIGN_SYSTEM.md §7.1).
///
/// Phase 7 wiring: loads splash.riv, fires the [kSplashTriggerPlay] trigger,
/// and navigates to /home after the animation duration elapses.
/// reduceMotion skips to /home after a brief static pause.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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

    if (file == null || MediaQuery.of(context).disableAnimations) {
      // No asset or reduceMotion — use timer-based navigation.
      _scheduleNavigation(const Duration(milliseconds: 1500));
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
      _scheduleNavigation(const Duration(milliseconds: 1500));
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
      Future<void>.delayed(delay, () {
        if (mounted) context.go('/home');
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
    final Widget staticText = Center(
      child: Text(
        'Admity',
        style: Theme.of(context)
            .textTheme
            .displayLarge
            ?.copyWith(color: AppColors.ink),
      ),
    );

    if (!_riveReady || _controller == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: staticText,
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
