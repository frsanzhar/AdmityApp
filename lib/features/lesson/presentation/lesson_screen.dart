import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Lesson screen placeholder — Phase 3 builds the full Brilliant-style lesson
/// mechanics (intro, step cards, ✓/✗ feedback, XP complete screen).
///
/// This stub exists so the `/lesson` GoRoute has a valid destination and
/// navigation from CoursesScreen works immediately.
class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Урок',
      subtitle:
          'Механики Brilliant: интро → шаги → фидбэк ✓/✗ → экран завершения (Phase 3)',
      icon: Icons.menu_book_outlined,
    );
  }
}
