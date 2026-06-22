import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Career-orientation test (профориентация) — STUB.
/// Phase: data-vertical agent fills this in (nicely designed test, warns it
/// takes a while, writes result into StudentProfile.careerResult).
class CareerTestScreen extends StatelessWidget {
  const CareerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Профориентация',
      subtitle: 'Тест на профориентацию (в разработке)',
      icon: Icons.psychology_outlined,
    );
  }
}
