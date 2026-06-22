import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Full-screen detail for a Университет. STUB — opportunities agent fills this in.
class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({required this.universityId, super.key});

  final String universityId;

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Университет',
      subtitle: 'Детальная информация (в разработке)',
      icon: Icons.info_outline,
    );
  }
}
