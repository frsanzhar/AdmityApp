import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Курсы',
      subtitle: 'Узловой путь уроков, уровни, 3D-диаграммы (Brilliant-стиль)',
      icon: Icons.school_outlined,
    );
  }
}
