import 'dart:async';

import 'package:admity/core/theme/app_radii.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/essay_review/domain/essay_models.dart';
import 'package:admity/features/intensives/domain/intensive_models.dart';
import 'package:admity/features/intensives/presentation/intensives_providers.dart';
import 'package:admity/features/intensives/presentation/widgets/camera_task_card.dart';
import 'package:admity/features/intensives/presentation/widgets/self_assessment_card.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/eraly_avatar.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// One day of an intensive: a real micro-lesson (teaching sections + reputable
/// materials), the practice steps, the rubric check, an optional interactive
/// task, and the completion flow. XP is only awarded when the rubric check is
/// confirmed — opening the lesson earns nothing.
class IntensiveDayScreen extends ConsumerWidget {
  /// Creates the screen for [day] of the intensive identified by [slug].
  const IntensiveDayScreen({required this.slug, required this.day, super.key});

  /// Slug of the intensive this day belongs to.
  final String slug;

  /// 1-based day number to render.
  final int day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intensive = ref.watch(intensiveBySlugProvider(slug));
    if (intensive == null) {
      return const Scaffold(body: Center(child: Text('Не найдено')));
    }
    final dayData = intensive.days.firstWhere(
      (d) => d.day == day,
      orElse: () => intensive.days.first,
    );

    return Scaffold(
      appBar: AppBar(title: Text('День ${dayData.day}')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(dayData.title, style: context.text.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                dayData.goal,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.tokens.textMuted),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DayMeta(minutes: dayData.estimatedMinutes, xp: dayData.xpReward),

              // Teaching content — the actual micro-lesson.
              if (dayData.lessonSections.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                for (final section in dayData.lessonSections) ...[
                  _LessonSectionView(section: section),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],

              // Reputable external materials.
              if (dayData.resources.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                const SectionHeader(title: 'Материалы'),
                const SizedBox(height: AppSpacing.sm),
                for (final resource in dayData.resources) ...[
                  _ResourceTile(resource: resource),
                  const SizedBox(height: AppSpacing.xs),
                ],
              ],

              // Practice steps.
              const SizedBox(height: AppSpacing.md),
              const SectionHeader(title: 'Практика'),
              const SizedBox(height: AppSpacing.sm),
              for (var i = 0; i < dayData.steps.length; i++)
                _StepRow(index: i, text: dayData.steps[i]),

              // The rubric check card.
              if (dayData.rubricCheck != null) ...[
                const SizedBox(height: AppSpacing.md),
                BentoCard(
                  color: context.tokens.surfaceSunken,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            size: 20,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text('Что нужно сдать',
                              style: context.text.titleSmall),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        dayData.rubricCheck!,
                        style: context.text.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],

              // Optional interactive task (camera evidence / instant self-check).
              if (dayData.task != null) ...[
                const SizedBox(height: AppSpacing.lg),
                switch (dayData.task!.type) {
                  IntensiveTaskType.selfAssessment => SelfAssessmentCard(
                      prompt: dayData.task!.prompt,
                      kind: dayData.task!.essayKind ?? EssayKind.commonApp,
                    ),
                  IntensiveTaskType.cameraPhoto => CameraTaskCard(
                      taskId: '${intensive.slug}:day-${dayData.day}',
                      prompt: dayData.task!.prompt,
                    ),
                  IntensiveTaskType.cameraVideo => CameraTaskCard(
                      taskId: '${intensive.slug}:day-${dayData.day}',
                      prompt: dayData.task!.prompt,
                      kind: CameraEvidenceKind.video,
                    ),
                },
              ],

              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: dayData.rubricCheck == null
                    ? 'Отметить выполненным'
                    : 'Я сдал — проверить',
                icon: Icons.check_rounded,
                onPressed: () => _complete(context, ref, intensive, dayData),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    Intensive intensive,
    IntensiveDay dayData,
  ) async {
    // For rubric days, confirm the check passed before awarding XP.
    var passed = true;
    if (dayData.rubricCheck != null) {
      passed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Проверка по рубрике'),
              content: Text(
                'Ты честно выполнил: «${dayData.rubricCheck}»?\n\n'
                'XP начисляется за сделанную работу, а не за открытый урок.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Ещё нет'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Да, сдал'),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!passed) return;

    final completion =
        ref.read(intensiveProgressProvider.notifier).completeDay(
              intensive: intensive,
              day: dayData.day,
              rubricPassed: passed,
            );
    if (!context.mounted) return;
    if (completion.accepted) {
      await _celebrate(context, completion);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Этот день уже пройден')),
      );
    }
    if (context.mounted) context.pop();
  }

  Future<void> _celebrate(
    BuildContext context,
    IntensiveCompletion completion,
  ) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brXl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EralyAvatar(size: 96, state: EralyState.celebrate),
              const SizedBox(height: AppSpacing.md),
              Text(
                completion.trackFinished ? 'Трек пройден! 🎉' : 'Отлично!',
                style: context.text.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '+${completion.xpGained} XP'
                '${completion.freezeUsed ? ' · стрик спасён заморозкой' : ''}'
                '${completion.streakChanged ? ' · стрик ${completion.progress.streakCount}' : ''}',
                textAlign: TextAlign.center,
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Дальше'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small pill row showing the estimated time and XP for the day.
class _DayMeta extends StatelessWidget {
  const _DayMeta({required this.minutes, required this.xp});

  final int minutes;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final muted = context.tokens.textMuted;
    final style = context.text.labelMedium?.copyWith(color: muted);
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: muted),
        const SizedBox(width: AppSpacing.xxs),
        Text('~$minutes мин', style: style),
        const SizedBox(width: AppSpacing.md),
        Icon(Icons.bolt_rounded, size: 16, color: context.tokens.xp),
        const SizedBox(width: AppSpacing.xxs),
        Text('$xp XP', style: style),
      ],
    );
  }
}

/// Renders one teaching block: heading plus its multi-paragraph body, with
/// paragraphs split on blank lines.
class _LessonSectionView extends StatelessWidget {
  const _LessonSectionView({required this.section});

  final LessonSection section;

  @override
  Widget build(BuildContext context) {
    final paragraphs = section.body.split('\n\n');
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading, style: context.text.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < paragraphs.length; i++) ...[
            Text(
              paragraphs[i],
              style: context.text.bodyMedium?.copyWith(height: 1.45),
            ),
            if (i < paragraphs.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// A tappable «Материалы» row that opens [resource] externally with
/// `url_launcher`. Shows a kind-specific leading icon.
class _ResourceTile extends StatelessWidget {
  const _ResourceTile({required this.resource});

  final LessonResource resource;

  IconData get _icon => switch (resource.kind) {
        LessonResourceKind.article => Icons.article_outlined,
        LessonResourceKind.video => Icons.play_circle_outline_rounded,
        LessonResourceKind.tool => Icons.build_outlined,
      };

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(resource.url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: () => unawaited(_open(context)),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          Icon(_icon, size: 22, color: context.colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(resource.title, style: context.text.bodyMedium),
          ),
          Icon(
            Icons.open_in_new_rounded,
            size: 18,
            color: context.tokens.textMuted,
          ),
        ],
      ),
    );
  }
}

/// A single numbered practice step.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: context.colors.primary,
            child: Text(
              '${index + 1}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: context.text.bodyLarge),
          ),
        ],
      ),
    );
  }
}
