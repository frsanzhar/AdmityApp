import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Full-screen detail for a Идея проекта. STUB — opportunities agent fills this in.
class IdeaDetailScreen extends StatelessWidget {
  const IdeaDetailScreen({required this.ideaId, super.key});

  final String ideaId;

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Идея проекта',
      subtitle: 'Детальная информация (в разработке)',
      icon: Icons.info_outline,
    );
  }
}
