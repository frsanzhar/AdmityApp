import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Daily career-orientation mini-test — a NEW set of questions each day. STUB.
class DailyCareerTestScreen extends StatelessWidget {
  const DailyCareerTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Узнай свою профессию',
      subtitle: 'Ежедневный тест профориентации (в разработке)',
      icon: Icons.psychology_outlined,
    );
  }
}
