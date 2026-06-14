import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/chancing_kz/domain/ent_chancing.dart';
import 'package:admity/features/chancing_kz/domain/ent_models.dart';
import 'package:admity/features/chancing_kz/presentation/ent_providers.dart';
import 'package:admity/shared/models/chance_category.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/chance_pill.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/score_bar_chart.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Honest ЕНТ chancing: enter your score, pick a target, see the category and
/// the bars it derives from (no fabricated %).
class ChancingKzScreen extends ConsumerStatefulWidget {
  const ChancingKzScreen({super.key});

  @override
  ConsumerState<ChancingKzScreen> createState() => _ChancingKzScreenState();
}

class _ChancingKzScreenState extends ConsumerState<ChancingKzScreen> {
  int _history = 16;
  int _math = 8;
  int _reading = 8;
  int _p1 = 40;
  int _p2 = 40;
  int _cutoffIndex = 0;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(entScoreProvider);
    if (saved != null) {
      _history = saved.history;
      _math = saved.mathLiteracy;
      _reading = saved.readingLiteracy;
      _p1 = saved.profile1Score;
      _p2 = saved.profile2Score;
    }
  }

  EntScore get _draft => EntScore(
        history: _history,
        mathLiteracy: _math,
        readingLiteracy: _reading,
        profile1Subject: 'Профиль 1',
        profile1Score: _p1,
        profile2Subject: 'Профиль 2',
        profile2Score: _p2,
      );

  void _save() {
    ref.read(entScoreProvider.notifier).save(_draft);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Балл сохранён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cutoffs = ref.watch(entCutoffsProvider);
    final cutoff = cutoffs[_cutoffIndex];
    final result = EntChancing.evaluateForCutoff(score: _draft, cutoff: cutoff);

    return Scaffold(
      appBar: AppBar(title: const Text('Шансы по ЕНТ')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Твой балл ЕНТ', style: context.text.titleMedium),
                    const Spacer(),
                    Text(
                      '${_draft.total}/140',
                      style: context.text.titleLarge
                          ?.copyWith(color: context.colors.primary),
                    ),
                  ],
                ),
                _slider('История Казахстана', _history, 20,
                    (v) => setState(() => _history = v)),
                _slider('Мат. грамотность', _math, 10,
                    (v) => setState(() => _math = v)),
                _slider('Грамотность чтения', _reading, 10,
                    (v) => setState(() => _reading = v)),
                _slider('Профильный 1', _p1, 50, (v) => setState(() => _p1 = v)),
                _slider('Профильный 2', _p2, 50, (v) => setState(() => _p2 = v)),
                const SizedBox(height: AppSpacing.xs),
                PrimaryButton(label: 'Сохранить балл', onPressed: _save),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Куда поступаешь?', style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<int>(
            initialValue: _cutoffIndex,
            isExpanded: true,
            items: [
              for (var i = 0; i < cutoffs.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    '${cutoffs[i].university} — ${cutoffs[i].specialty}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (v) => setState(() => _cutoffIndex = v ?? 0),
          ),
          const SizedBox(height: AppSpacing.lg),
          BentoCard(
            accent: _accent(context, result.category),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Вердикт', style: context.text.titleMedium),
                    const Spacer(),
                    ChancePill.kz(result.category),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ScoreBarChart(
                  maxY: 140,
                  bars: [
                    (
                      label: 'Ты',
                      value: result.total.toDouble(),
                      color: context.colors.primary,
                    ),
                    (
                      label: 'Гос-\nпорог',
                      value: result.govThreshold.toDouble(),
                      color: context.tokens.textMuted,
                    ),
                    if (result.realCutoff != null)
                      (
                        label: 'Проход.\n${cutoff.year}',
                        value: result.realCutoff!.toDouble(),
                        color: context.tokens.info,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(_explanation(result), style: context.text.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SourceNote(
            text: 'Итоговый грантовый балл определяется конкурсом года, и вузы '
                'могут ставить свои, более высокие пороги.',
            year: 2024,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Color _accent(BuildContext context, KzChance c) => switch (c) {
        KzChance.belowThreshold => context.tokens.danger,
        KzChance.atRisk => context.tokens.warning,
        KzChance.safe => context.tokens.success,
      };

  String _explanation(EntChancingResult r) {
    if (!r.meetsSubjectMinimums) {
      return 'Один из предметов ниже минимума (5 / 3 балла) — с таким '
          'результатом грант не присуждается. Подтяни слабый предмет.';
    }
    return switch (r.category) {
      KzChance.belowThreshold =>
        'Пока ниже порога на ${-r.marginToThreshold} б. Нужно подтянуть '
            'профильные предметы.',
      KzChance.atRisk =>
        'Ты выше порога, но рядом с прошлогодним проходным. Это зона риска — '
            'каждый балл важен.',
      KzChance.safe =>
        'Ты уверенно выше прошлогоднего проходного. Хороший расклад — но '
            'конкурс каждый год разный.',
    };
  }

  Widget _slider(String label, int value, int max, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(child: Text(label, style: context.text.bodySmall)),
            Text('$value/$max', style: context.text.labelMedium),
          ],
        ),
        Slider(
          value: value.toDouble(),
          max: max.toDouble(),
          divisions: max,
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}
