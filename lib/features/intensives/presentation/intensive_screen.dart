import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Intensive track detail: progress header + the 14 days.
class IntensiveScreen extends ConsumerWidget {
  const IntensiveScreen({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensive = ref.watch(intensiveBySlugProvider(slug));
    if (intensive == null) {
      return const Scaffold(body: Center(child: Text('Трек не найден')));
    }
    final progress = ref.watch(intensiveProgressProvider)[slug] ??
        IntensiveProgress(intensiveSlug: slug);
    final done = progress.completedDays.length;

    return Scaffold(
      appBar: AppBar(title: Text(intensive.title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          BentoCard(
            child: Row(
              children: [
                ProgressRing(
                  progress: done / intensive.totalDays,
                  label: '$done/${intensive.totalDays}',
                  sublabel: 'дней',
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(intensive.description,
                          style: context.text.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          XpChip(xp: progress.xp),
                          const SizedBox(width: AppSpacing.xs),
                          StreakBadge(days: progress.streakCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final day in intensive.days)
            _DayTile(
              day: day,
              state: _stateFor(day.day, progress),
              onTap: () => context.pushNamed(
                AppRoutes.intensiveDayName,
                pathParameters: {'slug': slug, 'day': '${day.day}'},
              ),
            ),
        ],
      ),
    );
  }

  _DayState _stateFor(int day, IntensiveProgress p) {
    if (p.isDayComplete(day)) return _DayState.done;
    if (day <= p.currentDay) return _DayState.available;
    return _DayState.locked;
  }
}

enum _DayState { done, available, locked }

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.state,
    required this.onTap,
  });

  final IntensiveDay day;
  final _DayState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final (icon, color) = switch (state) {
      _DayState.done => (Icons.check_circle_rounded, tokens.success),
      _DayState.available => (Icons.play_circle_fill_rounded, context.colors.primary),
      _DayState.locked => (Icons.lock_rounded, tokens.textMuted),
    };
    final locked = state == _DayState.locked;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadii.brLg,
            onTap: locked ? null : onTap,
            child: BentoCard(
              child: Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('День ${day.day}: ${day.title}',
                            style: context.text.titleSmall),
                        Text(
                          day.goal,
                          style: context.text.bodySmall
                              ?.copyWith(color: tokens.textMuted),
                        ),
                      ],
                    ),
                  ),
                  XpChip(xp: day.xpReward, compact: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
