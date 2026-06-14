import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/chance_pill.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:admity/shared/widgets/gamification_badges.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/progress_ring.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:admity/shared/widgets/selectable_chip.dart';
import 'package:flutter/material.dart';

/// `/design` — a live showcase of the design system components.
class DesignShowcaseScreen extends StatelessWidget {
  const DesignShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design system')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const SectionHeader(
            title: 'Eraly',
            subtitle: 'idle · celebrate · encourage · thinking',
          ),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.md,
            children: [
              EralyAvatar(),
              EralyAvatar(state: EralyState.celebrate),
              EralyAvatar(state: EralyState.encourage),
              EralyAvatar(state: EralyState.thinking),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Цвета'),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _Swatch('terracotta', AppColors.terracotta),
              _Swatch('teal', AppColors.teal),
              _Swatch('amber', AppColors.amber),
              _Swatch('olive', AppColors.olive),
              _Swatch('clay', AppColors.clay),
              _Swatch('sand', AppColors.sand),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Бейджи геймификации'),
          const SizedBox(height: AppSpacing.sm),
          const Wrap(
            spacing: AppSpacing.sm,
            children: [
              XpChip(xp: 420),
              StreakBadge(days: 7),
              StreakBadge(days: 7, frozen: true),
              ChancePill.kz(KzChance.safe),
              ChancePill.world(WorldChance.reach),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Чипы и кольцо прогресса'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const ProgressRing(progress: 0.65, label: '9/14', sublabel: 'дней'),
              const SizedBox(width: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.xs,
                children: [
                  SelectableChip(label: 'Математика', selected: true, onTap: () {}),
                  SelectableChip(label: 'Биология', selected: false, onTap: () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SectionHeader(title: 'Bento + кнопка'),
          const SizedBox(height: AppSpacing.sm),
          BentoCard(
            accent: context.tokens.info,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bento-карточка', style: context.text.titleMedium),
                Text(
                  'Мягкая тень, скругление 18, акцент-полоса.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.textMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(label: 'Tactile button', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: context.text.labelSmall),
      ],
    );
  }
}
