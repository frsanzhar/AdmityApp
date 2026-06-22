import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Animated onboarding / intro (Brilliant/Duolingo-style) — STUB.
/// Phase: data-vertical agent fills this in (animated feature tour while
/// collecting exams/GPA/grade/interests → ProfileRepository).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Добро пожаловать',
      subtitle: 'Анимационный онбординг (в разработке)',
      icon: Icons.auto_awesome_outlined,
    );
  }
}
