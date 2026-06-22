import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class MentorScreen extends StatelessWidget {
  const MentorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Ералы',
      subtitle: 'AI-наставник: направляет, но НЕ пишет эссе за тебя',
      icon: Icons.forum_outlined,
    );
  }
}
