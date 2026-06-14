import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/career_test/domain/career_items.dart';
import 'package:admity/features/career_test/domain/career_models.dart';
import 'package:admity/features/career_test/domain/major_match.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Career test: the RIASEC + Big Five questionnaire, then the results.
class CareerTestScreen extends ConsumerStatefulWidget {
  const CareerTestScreen({super.key});

  @override
  ConsumerState<CareerTestScreen> createState() => _CareerTestScreenState();
}

class _CareerTestScreenState extends ConsumerState<CareerTestScreen> {
  late final List<int?> _riasec = List.filled(kRiasecItems.length, null);
  late final List<int?> _bigFive = List.filled(kBigFiveItems.length, null);
  bool _retaking = false;

  bool get _complete =>
      !_riasec.contains(null) && !_bigFive.contains(null);

  void _submit() {
    ref.read(careerProvider.notifier).submit(
          riasecAnswers: _riasec.map((e) => e!).toList(),
          bigFiveAnswers: _bigFive.map((e) => e!).toList(),
        );
    setState(() => _retaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(careerProvider);
    final showResult = result != null && !_retaking;

    return Scaffold(
      appBar: AppBar(title: const Text('Профориентация')),
      body: showResult
          ? _Results(
              result: result,
              onRetake: () => setState(() => _retaking = true),
            )
          : _Questionnaire(
              riasec: _riasec,
              bigFive: _bigFive,
              onChanged: () => setState(() {}),
              complete: _complete,
              onSubmit: _submit,
            ),
    );
  }
}

class _Questionnaire extends StatelessWidget {
  const _Questionnaire({
    required this.riasec,
    required this.bigFive,
    required this.onChanged,
    required this.complete,
    required this.onSubmit,
  });

  final List<int?> riasec;
  final List<int?> bigFive;
  final VoidCallback onChanged;
  final bool complete;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Text(
                'Насколько тебе интересно…',
                style: context.text.titleMedium,
              ),
              Text(
                '1 — совсем не интересно, 5 — очень интересно',
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < kRiasecItems.length; i++)
                _LikertRow(
                  text: kRiasecItems[i].text,
                  value: riasec[i],
                  onSelect: (v) {
                    riasec[i] = v;
                    onChanged();
                  },
                ),
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(
                title: 'Насколько это про тебя?',
                subtitle: '1 — совсем нет, 5 — полностью',
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < kBigFiveItems.length; i++)
                _LikertRow(
                  text: kBigFiveItems[i].text,
                  value: bigFive[i],
                  onSelect: (v) {
                    bigFive[i] = v;
                    onChanged();
                  },
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PrimaryButton(
              label: complete ? 'Узнать результат' : 'Ответь на все вопросы',
              onPressed: complete ? onSubmit : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _LikertRow extends StatelessWidget {
  const _LikertRow({
    required this.text,
    required this.value,
    required this.onSelect,
  });

  final String text;
  final int? value;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (var n = 1; n <= 5; n++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(n),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 40,
                      decoration: BoxDecoration(
                        color: value == n
                            ? context.colors.primary
                            : context.tokens.surfaceSunken,
                        borderRadius: AppRadii.brSm,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$n',
                        style: TextStyle(
                          color: value == n
                              ? Colors.white
                              : context.tokens.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.result, required this.onRetake});

  final CareerResult result;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        BentoCard(
          accent: context.colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Твой код RIASEC', style: context.text.labelMedium),
              Text(result.riasecCode, style: context.text.displaySmall),
              Text(
                'Это про то, в какой сфере тебе интереснее всего работать.',
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Интересы', style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final type in RiasecType.values)
          _Bar(
            label: '${type.label} (${type.letter})',
            value: result.riasecScores[type] ?? 0,
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Личность (Big Five)', style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final trait in BigFiveTrait.values)
          _Bar(label: trait.label, value: result.bigFive[trait] ?? 0),
        const SizedBox(height: AppSpacing.lg),
        Text('Подходящие направления', style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final cluster in result.recommendedClusters)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cluster.name, style: context.text.titleSmall),
                  Text(
                    cluster.description,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.tokens.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final major in cluster.majors)
                        Chip(label: Text(major)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text('Конкретные специальности под тебя',
            style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final m in matchMajors(result.riasecCode, limit: 5))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: BentoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.major, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    m.rationale,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.tokens.textMuted),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.valuesTest),
          icon: const Icon(Icons.favorite_rounded),
          label: const Text('Пройти тест «Ценности и мотиваторы»'),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.projects),
          icon: const Icon(Icons.lightbulb_rounded),
          label: const Text('Идеи проектов под мой профиль'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: onRetake, child: const Text('Пройти заново')),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.text.bodySmall),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0, 1),
              minHeight: 8,
              backgroundColor: context.tokens.surfaceSunken,
            ),
          ),
        ],
      ),
    );
  }
}
