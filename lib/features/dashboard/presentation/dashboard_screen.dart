import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/calendar/presentation/calendar_card.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/features/gap_closer/presentation/gap_providers.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/features/profile/presentation/profile_providers.dart';
import 'package:admity/features/quotes/presentation/quote_of_day_card.dart';
import 'package:admity/features/scholarships/presentation/scholarships_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The home dashboard — a bento grid summarizing chances, the next task, the
/// active intensive, scholarships and the career result.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(profileProvider).onboarded &&
          ref.read(gapTasksProvider).isEmpty) {
        ref.read(gapTasksProvider.notifier).regenerate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final ent = ref.watch(entScoreProvider);
    final career = ref.watch(careerProvider);
    final tasks = ref.watch(gapTasksProvider);
    final progressMap = ref.watch(intensiveProgressProvider);
    final eligible =
        ref.watch(scholarshipMatchesProvider).where((m) => m.eligible).length;
    final tokens = context.tokens;

    final nextTask = tasks.where((t) => !t.isDone).firstOrNull;
    IntensiveProgress? active;
    for (final p in progressMap.values) {
      if (p.completedDays.isEmpty) continue;
      if (active == null ||
          p.completedDays.length > active.completedDays.length) {
        active = p;
      }
    }

    final name = (profile.fullName ?? '').trim();
    final greeting = name.isEmpty ? 'Привет!' : 'Привет, $name!';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              children: [
                const EralyAvatar(size: 56),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: context.text.headlineSmall),
                      Text(
                        'Твой путь в университет',
                        style: context.text.bodySmall
                            ?.copyWith(color: tokens.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Цитата дня — живой, мотивирующий контент, а не только переходы.
            const QuoteOfDayCard(),
            const SizedBox(height: AppSpacing.md),

            // Календарь — ближайшие дедлайны грантов и экзаменов.
            const CalendarCard(),
            const SizedBox(height: AppSpacing.md),

            if (!profile.onboarded)
              BentoCard(
                accent: tokens.warning,
                onTap: () => context.push(AppRoutes.onboarding),
                child: const _TileBody(
                  icon: Icons.flag_rounded,
                  title: 'Заполни профиль',
                  subtitle: 'Пара шагов — и я подберу шансы и стипендии.',
                ),
              ),
            if (!profile.onboarded) const SizedBox(height: AppSpacing.md),

            // Chances — wide card.
            BentoCard(
              accent: tokens.info,
              onTap: () => context.go(AppRoutes.chances),
              child: _TileBody(
                icon: Icons.insights_rounded,
                title: 'Твои шансы',
                subtitle: ent == null
                    ? 'Узнай свои шансы по ЕНТ и по миру (CDS).'
                    : 'ЕНТ ${ent.total}/140 · посмотри расклад по вузам.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Two-up row. IntrinsicHeight bounds the row's height so the two
            // equal-height (stretch) cards lay out correctly inside the
            // scroll view's unbounded vertical space.
            IntrinsicHeight(
              child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BentoCard(
                    onTap: () => context.push(AppRoutes.scholarships),
                    child: _TileBody(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Стипендии',
                      subtitle: '$eligible подходящих тебе сейчас.',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BentoCard(
                    onTap: () => context.push(AppRoutes.careerTest),
                    child: _TileBody(
                      icon: Icons.explore_rounded,
                      title: 'Профориентация',
                      subtitle: career == null
                          ? 'Пройди тест RIASEC.'
                          : 'Твой код: ${career.riasecCode}.',
                    ),
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Next step.
            BentoCard(
              accent: tokens.success,
              onTap: () => context.push(AppRoutes.gap),
              child: _TileBody(
                icon: Icons.checklist_rounded,
                title: 'Следующий шаг',
                subtitle: nextTask?.title ?? 'Все задачи закрыты — красавчик!',
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Active intensive.
            BentoCard(
              onTap: () => context.go(AppRoutes.learn),
              child: Row(
                children: [
                  Expanded(
                    child: _TileBody(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Интенсив',
                      subtitle: active == null
                          ? 'Начни 2-недельный трек.'
                          : 'Прогресс: ${active.completedDays.length}/14 дней.',
                    ),
                  ),
                  if (active != null) ...[
                    XpChip(xp: active.xp),
                    const SizedBox(width: AppSpacing.xs),
                    StreakBadge(days: active.streakCount),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            BentoCard(
              color: tokens.surfaceSunken,
              onTap: () => context.go(AppRoutes.eraly),
              child: const _TileBody(
                icon: Icons.forum_rounded,
                title: 'Спроси Ералы',
                subtitle: 'Помогу и подскажу — но не сделаю работу за тебя.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Мини-игры и инструменты — уникальный контент, а не только навигация.
            const SectionHeader(
              title: 'Мини-игры и инструменты',
              subtitle: 'Прокачивай мозг каждый день',
            ),
            const SizedBox(height: AppSpacing.sm),
            BentoCard(
              accent: tokens.success,
              onTap: () => context.push(AppRoutes.wordleGame),
              child: const _TileBody(
                icon: Icons.grid_view_rounded,
                title: 'Слово дня',
                subtitle: 'Отгадай слово за 6 попыток.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BentoCard(
              accent: tokens.xp,
              onTap: () => context.push(AppRoutes.guessUni),
              child: const _TileBody(
                icon: Icons.travel_explore_rounded,
                title: 'Угадай вуз',
                subtitle: 'Узнай университет по подсказкам.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            BentoCard(
              accent: tokens.info,
              onTap: () => context.push(AppRoutes.gpa),
              child: const _TileBody(
                icon: Icons.calculate_rounded,
                title: 'Калькулятор GPA',
                subtitle: 'Посчитай средний балл по таблице оценок.',
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const SectionHeader(
              title: 'Совет дня',
              subtitle: 'Честность — часть продукта',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Есть 5 вузов США (MIT, Harvard, Yale, Princeton, Amherst), где '
              'заявка на финпомощь НЕ снижает шанс поступить. «Need-blind» ≠ '
              'автоматически бесплатно — но точно стоит подавать.',
              style: context.text.bodyMedium?.copyWith(color: tokens.textMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          ),
        ),
      ),
    );
  }
}

class _TileBody extends StatelessWidget {
  const _TileBody({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: context.colors.primary),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: context.text.titleMedium),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style:
              context.text.bodySmall?.copyWith(color: context.tokens.textMuted),
        ),
      ],
    );
  }
}
