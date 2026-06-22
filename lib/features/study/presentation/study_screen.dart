import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Учёба',
      subtitle: 'Интенсивы, эссе-рубрика, прогресс',
      icon: Icons.school_outlined,
    );
  }
}
