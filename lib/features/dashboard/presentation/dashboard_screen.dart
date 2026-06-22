import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Главная',
      subtitle: 'Дашборд, следующее действие, мини-игры',
      icon: Icons.home_outlined,
    );
  }
}
