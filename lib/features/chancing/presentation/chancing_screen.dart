import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class ChancingScreen extends StatelessWidget {
  const ChancingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Шансы',
      subtitle: 'Честная оценка по ЕНТ + CDS логике',
      icon: Icons.insights_outlined,
    );
  }
}
