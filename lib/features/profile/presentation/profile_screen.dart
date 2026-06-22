import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Профиль',
      subtitle: 'Данные, заметки, язык (KZ/RU/EN)',
      icon: Icons.person_outline,
    );
  }
}
