import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/career_test/presentation/career_providers.dart';
import 'package:admity/features/project_ideas/domain/project_suggester.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:admity/shared/widgets/source_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Project ideas suggested from the student's RIASEC code.
class ProjectIdeasScreen extends ConsumerWidget {
  const ProjectIdeasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final career = ref.watch(careerProvider);
    final code = career?.riasecCode ?? 'IRC';
    final ideas = ProjectSuggester.suggest(code);

    return Scaffold(
      appBar: AppBar(title: const Text('Идеи проектов')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screen),
        children: [
          if (career == null)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: SourceNote(
                text: 'Пройди тест профориентации, чтобы идеи стали точнее.',
              ),
            ),
          for (final idea in ideas)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child:
                              Text(idea.title, style: context.text.titleSmall),
                        ),
                        Text(
                          idea.effort,
                          style: context.text.labelSmall
                              ?.copyWith(color: context.tokens.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(idea.description, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: 6,
                      children: [
                        for (final c in idea.riasecCodes)
                          Chip(
                            label: Text(c),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
