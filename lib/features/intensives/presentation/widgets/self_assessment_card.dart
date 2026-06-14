import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:admity/features/essay_review/domain/rubric_scorer.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// A task widget where the student types a short response (an essay hook, a
/// paragraph, a thesis) and taps «Оценить» to get an INSTANT, fully offline
/// score from [LocalRubricScorer].
///
/// The score and per-criterion feedback are shown inline. Nothing is sent over
/// the network; deep feedback on voice and reflection comes from Eraly online
/// elsewhere. When [onScored] is provided it fires after each evaluation so the
/// parent can mark the day's evidence as collected.
class SelfAssessmentCard extends StatefulWidget {
  /// Creates a self-assessment task card.
  const SelfAssessmentCard({
    required this.prompt,
    this.kind = EssayKind.commonApp,
    this.initialText = '',
    this.hintText = 'Напиши свой ответ здесь…',
    this.minLines = 5,
    this.maxLines = 12,
    this.onTextChanged,
    this.onScored,
    super.key,
  });

  /// Short instruction shown above the input (e.g. «Напиши абзац-зацепку»).
  final String prompt;

  /// Essay kind used to calibrate the word limit in scoring.
  final EssayKind kind;

  /// Optional pre-filled draft (e.g. restored from a provider).
  final String initialText;

  /// Placeholder shown when the field is empty.
  final String hintText;

  /// Minimum visible lines of the input.
  final int minLines;

  /// Maximum visible lines before the input scrolls.
  final int maxLines;

  /// Called whenever the text changes, so the parent can persist the draft.
  final ValueChanged<String>? onTextChanged;

  /// Called after each evaluation with the produced feedback, so the parent
  /// can mark evidence collected or store the score.
  final ValueChanged<EssayFeedback>? onScored;

  @override
  State<SelfAssessmentCard> createState() => _SelfAssessmentCardState();
}

class _SelfAssessmentCardState extends State<SelfAssessmentCard> {
  late final TextEditingController _controller;
  EssayFeedback? _feedback;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _score() {
    final feedback = LocalRubricScorer.score(_controller.text, widget.kind);
    setState(() => _feedback = feedback);
    widget.onScored?.call(feedback);
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _feedback;
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rate_review_rounded,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(widget.prompt, style: context.text.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            onChanged: widget.onTextChanged,
            decoration: InputDecoration(
              hintText: widget.hintText,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Оценить',
            icon: Icons.fact_check_rounded,
            onPressed: _score,
          ),
          if (feedback != null) ...[
            const SizedBox(height: AppSpacing.md),
            _InlineFeedback(feedback: feedback),
          ],
        ],
      ),
    );
  }
}

/// Compact inline rendering of [EssayFeedback]: an average summary, the
/// per-criterion bars and the lists of strengths and suggestions.
class _InlineFeedback extends StatelessWidget {
  const _InlineFeedback({required this.feedback});

  final EssayFeedback feedback;

  @override
  Widget build(BuildContext context) {
    final average = feedback.average;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.tokens.surfaceSunken,
            borderRadius: AppRadii.brMd,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Text(
              'Оценка: ${average.toStringAsFixed(1)}/4 · '
              '${feedback.wordCount} слов',
              style: context.text.titleSmall,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final s in feedback.scores)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.criterion.label,
                        style: context.text.bodySmall,
                      ),
                    ),
                    Text('${s.score}/4', style: context.text.labelMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: s.score / 4,
                    minHeight: 8,
                    backgroundColor: context.tokens.surfaceSunken,
                    color: s.score >= 3
                        ? context.tokens.success
                        : context.tokens.warning,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  s.comment,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.tokens.textMuted),
                ),
              ],
            ),
          ),
        if (feedback.strengths.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text('Сильные стороны', style: context.text.titleSmall),
          for (final s in feedback.strengths)
            Text('✓ $s', style: context.text.bodyMedium),
        ],
        if (feedback.suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text('Что улучшить', style: context.text.titleSmall),
          for (final s in feedback.suggestions)
            Text('• $s', style: context.text.bodyMedium),
        ],
        if (feedback.overall != null) ...[
          const SizedBox(height: AppSpacing.sm),
          BentoCard(
            color: context.tokens.surfaceSunken,
            child: Text(feedback.overall!, style: context.text.bodyMedium),
          ),
        ],
      ],
    );
  }
}
