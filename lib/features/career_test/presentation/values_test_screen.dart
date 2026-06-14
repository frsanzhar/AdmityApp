import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/career_test/domain/values_test.dart';
import 'package:admity/features/career_test/presentation/values_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The "Ценности и мотиваторы" mini-test: what drives the student, scored into
/// four ranked value scales. Complements the RIASEC/Big Five career test.
class ValuesTestScreen extends ConsumerStatefulWidget {
  /// Creates the values test screen.
  const ValuesTestScreen({super.key});

  @override
  ConsumerState<ValuesTestScreen> createState() => _ValuesTestScreenState();
}

class _ValuesTestScreenState extends ConsumerState<ValuesTestScreen> {
  late final List<int?> _answers = List.filled(kValueItems.length, null);
  bool _retaking = false;

  bool get _complete => !_answers.contains(null);

  void _submit() {
    ref.read(valuesProvider.notifier).submit(
          _answers.map((e) => e!).toList(),
        );
    setState(() => _retaking = false);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(valuesProvider);
    final showResult = result != null && !_retaking;

    return Scaffold(
      appBar: AppBar(title: const Text('Ценности и мотиваторы')),
      body: showResult
          ? _ValuesResultView(
              result: result,
              onRetake: () => setState(() => _retaking = true),
            )
          : _ValuesQuestionnaire(
              answers: _answers,
              complete: _complete,
              onChanged: () => setState(() {}),
              onSubmit: _submit,
            ),
    );
  }
}

class _ValuesQuestionnaire extends StatelessWidget {
  const _ValuesQuestionnaire({
    required this.answers,
    required this.complete,
    required this.onChanged,
    required this.onSubmit,
  });

  final List<int?> answers;
  final bool complete;
  final VoidCallback onChanged;
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
                'Насколько ты согласен с утверждением?',
                style: context.text.titleMedium,
              ),
              Text(
                '1 — совсем не про меня, 5 — полностью про меня',
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < kValueItems.length; i++)
                _LikertRow(
                  text: kValueItems[i].text,
                  value: answers[i],
                  onSelect: (v) {
                    answers[i] = v;
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

class _ValuesResultView extends StatelessWidget {
  const _ValuesResultView({required this.result, required this.onRetake});

  final ValuesResult result;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final top = result.top;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screen),
      children: [
        BentoCard(
          accent: context.colors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Твой главный мотиватор', style: context.text.labelMedium),
              Text(top.label, style: context.text.displaySmall),
              Text(
                top.blurb,
                style: context.text.bodySmall
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Все ценности', style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final s in result.ranked)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.scale.label, style: context.text.bodySmall),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: s.score.clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: context.tokens.surfaceSunken,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        TextButton(onPressed: onRetake, child: const Text('Пройти заново')),
      ],
    );
  }
}
