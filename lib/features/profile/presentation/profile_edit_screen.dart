import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Full-screen "Мои данные" editor — opened from the Profile pencil. STUB.
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Мои данные',
      subtitle: 'Редактирование данных (в разработке)',
      icon: Icons.edit_outlined,
    );
  }
}
