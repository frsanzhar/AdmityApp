import 'package:admity/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash screen (DESIGN_SYSTEM.md §7.1).
///
/// Static for now — motion agent adds light sweep + fly-up in Phase 7.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TODO(motion): light sweep + fly-up
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Text(
          'Admity',
          style: textTheme.displayLarge?.copyWith(color: AppColors.ink),
        ),
      ),
    );
  }
}
