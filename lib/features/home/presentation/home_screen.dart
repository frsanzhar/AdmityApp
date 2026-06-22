import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Главная',
      subtitle: 'Стрик, задание на сегодня, календарь дел',
      icon: Icons.home_outlined,
    );
  }
}
