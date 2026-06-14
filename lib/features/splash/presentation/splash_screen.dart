import 'dart:async';

import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/shared/widgets/admity_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The branded launch animation shown on cold start.
///
/// The Admity mark (the Eraly steppe-bird tile) springs in, the wordmark rises
/// beneath it, and after the choreography settles the app routes on to the
/// dashboard (or onboarding for a first run). Pure vector + flutter_animate,
/// so it matches the native launch screen's static logo seamlessly.
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const _hold = Duration(milliseconds: 2150);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_hold, _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    final onboarded = ref.read(profileProvider).onboarded;
    context.go(onboarded ? AppRoutes.dashboard : AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The mark: springs up + fades in, then a single soft breath.
            const AdmityLogo(size: 132)
                .animate()
                .fadeIn(duration: 420.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 720.ms,
                  curve: Curves.easeOutBack,
                )
                .then(delay: 80.ms)
                .shimmer(
                  duration: 900.ms,
                  color: AppColors.cream.withValues(alpha: 0.55),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 1,
                  end: 1.04,
                  duration: 1300.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 28),
            // Wordmark: rises and fades in after the mark lands.
            const Text(
              'Admity',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.terracotta,
              ),
            )
                .animate()
                .fadeIn(delay: 520.ms, duration: 520.ms)
                .slideY(begin: 0.6, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: 8),
            // Tagline.
            const Text(
              'Поступай честно. Поступай умно.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.inkMutedLight,
                letterSpacing: 0.2,
              ),
            ).animate().fadeIn(delay: 980.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
