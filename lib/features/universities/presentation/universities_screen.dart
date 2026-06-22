import 'package:admity/shared/widgets/placeholder_screen.dart';
import 'package:flutter/material.dart';

/// Full "Вузы" page — pulled out of Возможности into its own section. STUB.
class UniversitiesScreen extends StatelessWidget {
  const UniversitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Вузы',
      subtitle: 'Университеты, шансы, требования (в разработке)',
      icon: Icons.account_balance_outlined,
    );
  }
}
