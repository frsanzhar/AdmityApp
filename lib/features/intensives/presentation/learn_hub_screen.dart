import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/nav_card.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Hub for the "Учёба" tab — career test, gap tasks, projects, intensives.
class LearnHubScreen extends ConsumerWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(careerProvider);
    final intensives = ref.watch(intensivesProvider);
    final progress = ref.watch(intensiveProgressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Учёба')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          NavCard(
            icon: Icons.explore_rounded,
            title: 'Профориентация',
            subtitle: career == null
                ? 'RIASEC + Big Five → направления.'
                : 'Код ${career.riasecCode} · посмотреть результат.',
            onTap: () => context.push(AppRoutes.careerTest),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.checklist_rounded,
            title: 'Мои задачи (gap-closer)',
            subtitle: 'Конкретные шаги к цели.',
            onTap: () => context.push(AppRoutes.gap),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.lightbulb_rounded,
            title: 'Идеи проектов',
            subtitle: 'Без бюджета, своими руками.',
            onTap: () => context.push(AppRoutes.projects),
          ),
          const SizedBox(height: AppSpacing.md),
          NavCard(
            icon: Icons.edit_note_rounded,
            title: 'Проверка эссе',
            subtitle: 'Фидбэк по рубрике — но не за тебя.',
            onTap: () => context.push(AppRoutes.essay),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(
            title: '2-недельные интенсивы',
            subtitle: 'XP, стрики, проверка по рубрике',
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final intensive in intensives) ...[
            NavCard(
              icon: Icons.bolt_rounded,
              title: intensive.title,
              subtitle: '${intensive.totalDays} дней · ${intensive.totalXp} XP',
              accent: context.tokens.xp,
              trailing: progress[intensive.slug] == null
                  ? null
                  : StreakBadge(days: progress[intensive.slug]!.streakCount),
              onTap: () => context.pushNamed(
                AppRoutes.intensiveName,
                pathParameters: {'slug': intensive.slug},
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}
