import 'package:admity/core/theme/app_durations.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/games/guess_uni/presentation/guess_uni_providers.dart';
import 'package:admity/features/universities/domain/university.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// «Угадай вуз» — a GeoGuessr-style guessing game. The player identifies a
/// university from progressively revealed clues; fewer clues mean more points.
class GuessUniScreen extends ConsumerWidget {
  /// Creates the guessing-game screen.
  const GuessUniScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(guessUniProvider);
    final controller = ref.read(guessUniProvider.notifier);
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Угадай вуз')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ScoreBar(state: state),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(
                title: 'Что это за вуз?',
                subtitle: 'Чем меньше подсказок — тем больше очков',
              ),
              const SizedBox(height: AppSpacing.sm),
              _CluesCard(state: state),
              const SizedBox(height: AppSpacing.sm),
              if (state.canRevealMore && !state.answered)
                _RevealButton(
                  remaining: state.clues.length - state.revealedClues,
                  onTap: controller.revealMore,
                ),
              const SizedBox(height: AppSpacing.md),
              ..._buildOptions(context, state, controller),
              if (state.answered) ...[
                const SizedBox(height: AppSpacing.md),
                _ResultBanner(state: state),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Следующий',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: controller.nextRound,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Очки за раунд зависят от числа открытых подсказок: '
                'минимум подсказок — максимум очков.',
                style:
                    context.text.bodySmall?.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildOptions(
    BuildContext context,
    GuessUniState state,
    GuessUniController controller,
  ) {
    final widgets = <Widget>[];
    for (var i = 0; i < state.options.length; i++) {
      widgets.add(
        _OptionTile(
          university: state.options[i],
          state: state,
          index: i,
          onTap: () => controller.answer(i),
        ),
      );
      if (i != state.options.length - 1) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return widgets;
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.state});

  final GuessUniState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Icons.local_fire_department_rounded,
            color: tokens.streak,
            label: 'Серия',
            value: '${state.currentStreak}',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            icon: Icons.emoji_events_rounded,
            color: tokens.xp,
            label: 'Рекорд',
            value: '${state.stats.bestScore}',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatPill(
            icon: Icons.star_rounded,
            color: tokens.info,
            label: 'За раунд',
            value: state.answered
                ? '${state.earnedScore}'
                : '+${state.potentialScore}',
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacing.xxs),
          // Re-key on value so the number bumps (scale pop) whenever it
          // changes — e.g. the per-round score on a correct answer.
          Text(value, style: context.text.titleMedium)
              .animate(key: ValueKey<String>('$label:$value'))
              .scaleXY(
                begin: 1.35,
                end: 1,
                duration: AppDurations.medium,
                curve: Curves.easeOutBack,
              ),
          Text(
            label,
            style: context.text.labelSmall
                ?.copyWith(color: context.tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CluesCard extends StatelessWidget {
  const _CluesCard({required this.state});

  final GuessUniState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final visible = state.clues.take(state.revealedClues).toList();
    return BentoCard(
      accent: tokens.info,
      child: AnimatedSize(
        duration: AppDurations.medium,
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i != 0) const Divider(height: AppSpacing.md),
              _ClueRow(clue: visible[i], slug: state.target.slug, index: i),
            ],
          ],
        ),
      ),
    );
  }
}

class _ClueRow extends StatelessWidget {
  const _ClueRow({
    required this.clue,
    required this.slug,
    required this.index,
  });

  final GuessUniClue clue;
  final String slug;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lightbulb_rounded, size: 18, color: tokens.xp),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clue.label,
                style:
                    context.text.labelSmall?.copyWith(color: tokens.textMuted),
              ),
              const SizedBox(height: 2),
              Text(clue.value, style: context.text.bodyMedium),
            ],
          ),
        ),
      ],
    )
        // Key on slug+index so each newly revealed clue (and every fresh
        // round) cross-fades and slides in, while earlier rows stay still.
        .animate(key: ValueKey<String>('$slug:$index'))
        .fadeIn(duration: AppDurations.medium)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }
}

class _RevealButton extends StatelessWidget {
  const _RevealButton({required this.remaining, required this.onTap});

  final int remaining;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return BentoCard(
      color: tokens.surfaceSunken,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline_rounded, color: context.colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Ещё подсказка · осталось $remaining',
            style: context.text.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.university,
    required this.state,
    required this.index,
    required this.onTap,
  });

  final University university;
  final GuessUniState state;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isTarget = university.slug == state.target.slug;
    final isPicked = state.selectedIndex == index;

    Color? accent;
    Color? bg;
    if (state.answered) {
      if (isTarget) {
        accent = tokens.success;
        bg = tokens.success.withValues(alpha: 0.10);
      } else if (isPicked) {
        accent = tokens.danger;
        bg = tokens.danger.withValues(alpha: 0.10);
      }
    }

    final card = BentoCard(
      accent: accent,
      color: bg,
      onTap: state.answered ? null : onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(university.name, style: context.text.titleSmall),
          ),
          if (state.answered && isTarget)
            Icon(Icons.check_circle_rounded, color: tokens.success)
          else if (state.answered && isPicked)
            Icon(Icons.cancel_rounded, color: tokens.danger),
        ],
      ),
    );

    // Feedback once answered: the correct option pulses green, a wrong pick
    // shakes red. The shake/pulse re-key on slug so they fire per round.
    if (state.answered && isTarget) {
      return card
          .animate(key: ValueKey<String>('ok:${state.target.slug}'))
          .scaleXY(
            begin: 1,
            end: 1.04,
            duration: AppDurations.fast,
            curve: Curves.easeOut,
          )
          .then()
          .scaleXY(
            end: 1,
            duration: AppDurations.medium,
            curve: Curves.easeInOut,
          );
    }
    if (state.answered && isPicked) {
      return card
          .animate(key: ValueKey<String>('no:${state.target.slug}'))
          .shakeX(duration: AppDurations.slow, hz: 6, amount: 5);
    }

    // Pre-answer: options stagger in fresh each round (keyed by target slug).
    return card
        .animate(key: ValueKey<String>('${state.target.slug}:$index'))
        .fadeIn(
          delay: Duration(milliseconds: 60 * index),
          duration: AppDurations.medium,
        )
        .slideY(
          begin: 0.12,
          delay: Duration(milliseconds: 60 * index),
          duration: AppDurations.medium,
          curve: Curves.easeOut,
        );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.state});

  final GuessUniState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final correct = state.isCorrect;
    final color = correct ? tokens.success : tokens.danger;
    final title = correct
        ? 'Верно! +${state.earnedScore} очк.'
        : 'Мимо — это ${state.target.name}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.brLg,
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(
              correct
                  ? Icons.celebration_rounded
                  : Icons.sentiment_dissatisfied_rounded,
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    correct
                        ? 'Серия: ${state.currentStreak} подряд.'
                        : '${state.target.name} — ${state.target.country}.',
                    style: context.text.bodySmall
                        ?.copyWith(color: tokens.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: AppDurations.medium)
        .scaleXY(begin: 0.96, curve: Curves.easeOut);
  }
}
