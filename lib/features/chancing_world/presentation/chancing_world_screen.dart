import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/chancing_world/domain/cds_chancing.dart';
import 'package:admity/features/chancing_world/presentation/cds_providers.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/chance_pill.dart';
import 'package:admity/shared/widgets/score_bar_chart.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CDS-based world chancing: place a SAT score in the 25–75 band and get
/// reach/target/likely plus the factors the school weighs most.
class ChancingWorldScreen extends ConsumerStatefulWidget {
  const ChancingWorldScreen({super.key});

  @override
  ConsumerState<ChancingWorldScreen> createState() =>
      _ChancingWorldScreenState();
}

class _ChancingWorldScreenState extends ConsumerState<ChancingWorldScreen> {
  int _sat = 1300;
  int _cdsIndex = 0;

  @override
  void initState() {
    super.initState();
    _sat = ref.read(satScoreProvider) ?? 1300;
  }

  @override
  Widget build(BuildContext context) {
    final snapshots = ref.watch(cdsProvider);
    final snapshot = snapshots[_cdsIndex];
    final result = CdsChancing.evaluate(snapshot: snapshot, satComposite: _sat);

    return Scaffold(
      appBar: AppBar(title: const Text('Шансы по миру')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Твой SAT', style: context.text.titleMedium),
                    const Spacer(),
                    Text(
                      '$_sat',
                      style: context.text.titleLarge
                          ?.copyWith(color: context.colors.primary),
                    ),
                  ],
                ),
                Slider(
                  value: _sat.toDouble(),
                  min: 400,
                  max: 1600,
                  divisions: 120,
                  label: '$_sat',
                  onChanged: (v) => setState(() => _sat = v.round()),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(satScoreProvider.notifier).save(_sat),
                  child: const Text('Сохранить SAT'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Университет', style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: _cdsIndex,
            isExpanded: true,
            items: [
              for (var i = 0; i < snapshots.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(snapshots[i].university,
                      overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) => setState(() => _cdsIndex = v ?? 0),
          ),
          const SizedBox(height: AppSpacing.lg),
          BentoCard(
            accent: _accent(context, result.category),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Категория', style: context.text.titleMedium),
                    const Spacer(),
                    ChancePill.world(result.category),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Приём ~${(snapshot.acceptanceRate * 100).round()}% · ты '
                  '${_position(result.bandPosition)} '
                  '(≈${result.estimatedPercentile ?? '–'}-й перцентиль).',
                  style: context.text.bodyMedium,
                ),
                if (snapshot.sat25 != null && snapshot.sat75 != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ScoreBarChart(
                    maxY: 1600,
                    bars: [
                      (
                        label: 'Ты',
                        value: _sat.toDouble(),
                        color: context.colors.primary,
                      ),
                      (
                        label: '25-й',
                        value: snapshot.sat25!.toDouble(),
                        color: context.tokens.textMuted,
                      ),
                      (
                        label: '75-й',
                        value: snapshot.sat75!.toDouble(),
                        color: context.tokens.info,
                      ),
                    ],
                  ),
                ],
                if (result.veryImportantFactors.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Здесь «очень важно»: усилься нетестовыми факторами.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.tokens.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final f in result.veryImportantFactors)
                        Chip(label: Text(_factorLabel(f))),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SourceNote(
            text: 'Диапазоны 25–75 — это ориентир, а не отсечки. Holistic-приём '
                'учитывает эссе, рекомендации и характер.',
            year: 2024,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Color _accent(BuildContext context, WorldChance c) => switch (c) {
        WorldChance.reach => context.tokens.chanceReach,
        WorldChance.target => context.tokens.chanceTarget,
        WorldChance.likely => context.tokens.chanceLikely,
      };

  String _position(BandPosition p) => switch (p) {
        BandPosition.below => 'ниже диапазона',
        BandPosition.lower => 'в нижней части диапазона',
        BandPosition.middle => 'в середине диапазона',
        BandPosition.upper => 'в верхней части диапазона',
        BandPosition.above => 'выше диапазона',
      };

  String _factorLabel(String key) => switch (key) {
        'rigor' => 'Сложность программы',
        'gpa' => 'Оценки (GPA)',
        'essay' => 'Эссе',
        'recommendations' => 'Рекомендации',
        'character' => 'Характер',
        'talent' => 'Талант',
        'extracurricular' => 'Активности',
        _ => key,
      };
}
