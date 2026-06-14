import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/shared/widgets/nav_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub for the "Шансы" tab — honest chancing + universities + scholarships.
class ChancesHubScreen extends ConsumerWidget {
  const ChancesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Шансы')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          NavCard(
            icon: Icons.flag_circle_rounded,
            title: 'Шансы по ЕНТ (Казахстан)',
            subtitle: 'Пороги + реальные проходные баллы.',
            onTap: () => context.push(AppRoutes.chancingKz),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.public_rounded,
            title: 'Шансы по миру (Common Data Set)',
            subtitle: 'Диапазоны SAT/ACT + reach/target/likely.',
            onTap: () => context.push(AppRoutes.chancingWorld),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.account_balance_rounded,
            title: 'Университеты',
            subtitle: 'КЗ и мир в одном месте.',
            onTap: () => context.push(AppRoutes.universities),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.workspace_premium_rounded,
            title: 'Стипендии',
            subtitle: 'Что подходит именно тебе.',
            onTap: () => context.push(AppRoutes.scholarships),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.list_alt_rounded,
            title: 'Мой список вузов',
            subtitle: 'Сохранённые университеты.',
            onTap: () => context.push(AppRoutes.collegeList),
          ),
        ],
      ),
    );
  }
}
