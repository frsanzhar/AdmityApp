import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class OpportunitiesScreen extends StatelessWidget {
  const OpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Возможности',
      subtitle: 'Стипендии, университеты, мероприятия, идеи проектов',
      icon: Icons.explore_outlined,
    );
  }
}
