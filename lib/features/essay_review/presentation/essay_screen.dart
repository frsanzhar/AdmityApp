import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:admity/features/essay_review/domain/rubric_scorer.dart';
import 'package:admity/features/essay_review/presentation/essay_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Essay review: a local rubric check (word economy, clichés, structure). Deep
/// feedback comes from Eraly online — and never as a rewritten essay.
class EssayScreen extends ConsumerStatefulWidget {
  const EssayScreen({super.key});

  @override
  ConsumerState<EssayScreen> createState() => _EssayScreenState();
}

class _EssayScreenState extends ConsumerState<EssayScreen> {
  final _controller = TextEditingController();
  EssayKind _kind = EssayKind.commonApp;
  EssayFeedback? _feedback;

  @override
  void initState() {
    super.initState();
    // Restore the saved draft + feedback for the default kind (persisted/synced).
    final rec = ref.read(essaysProvider)[_kind];
    if (rec != null) {
      _controller.text = rec.draftText;
      _feedback = rec.feedback;
    }
  }

  @override
  void dispose() {
    // Best-effort: keep the in-progress draft so it isn't lost on pop.
    final text = _controller.text;
    if (text.trim().isNotEmpty) {
      ref.read(essaysProvider.notifier).saveDraft(_kind, text);
    }
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final feedback = LocalRubricScorer.score(_controller.text, _kind);
    setState(() => _feedback = feedback);
    ref.read(essaysProvider.notifier).saveFeedback(_kind, _controller.text, feedback);
  }

  void _switchKind(EssayKind kind) {
    // Save the current draft under the old kind before loading the new one.
    if (_controller.text.trim().isNotEmpty) {
      ref.read(essaysProvider.notifier).saveDraft(_kind, _controller.text);
    }
    final rec = ref.read(essaysProvider)[kind];
    setState(() {
      _kind = kind;
      _controller.text = rec?.draftText ?? '';
      _feedback = rec?.feedback;
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedback = _feedback;
    return Scaffold(
      appBar: AppBar(title: const Text('Проверка эссе')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          const SourceNote(
            text: 'Ералы помогает и правит, но НЕ пишет эссе за тебя — '
                'сгенерированный текст вузы считают списыванием.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Тип эссе', style: context.text.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<EssayKind>(
            initialValue: _kind,
            isExpanded: true,
            items: [
              for (final k in EssayKind.values)
                DropdownMenuItem(value: k, child: Text(k.label)),
            ],
            onChanged: (v) => _switchKind(v ?? EssayKind.commonApp),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Фокус: ${_kind.focus} · лимит ~${_kind.wordLimit} слов.',
            style: context.text.bodySmall
                ?.copyWith(color: context.tokens.textMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 8,
            maxLines: 18,
            decoration: const InputDecoration(
              hintText: 'Вставь свой черновик…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(
            label: 'Проверить по рубрике',
            icon: Icons.fact_check_rounded,
            onPressed: _check,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.eraly),
            icon: const Icon(Icons.forum_rounded),
            label: const Text('Обсудить с Ералы (он задаст вопросы)'),
          ),
          if (feedback != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _FeedbackView(feedback: feedback),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _FeedbackView extends StatelessWidget {
  const _FeedbackView({required this.feedback});

  final EssayFeedback feedback;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Результат · ${feedback.wordCount} слов',
            style: context.text.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        for (final s in feedback.scores)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Text(s.criterion.label,
                      style: context.text.bodySmall),
                ),
                Expanded(
                  child: ClipRRect(
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
                ),
                const SizedBox(width: 8),
                Text('${s.score}/4', style: context.text.labelMedium),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        if (feedback.strengths.isNotEmpty) ...[
          Text('Сильные стороны', style: context.text.titleSmall),
          for (final s in feedback.strengths)
            Text('✓ $s', style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (feedback.suggestions.isNotEmpty) ...[
          Text('Что улучшить', style: context.text.titleSmall),
          for (final s in feedback.suggestions)
            Text('• $s', style: context.text.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (feedback.overall != null)
          BentoCard(
            color: context.tokens.surfaceSunken,
            child: Text(feedback.overall!, style: context.text.bodyMedium),
          ),
      ],
    );
  }
}
