import 'package:admity/core/router/app_routes.dart';
import 'package:admity/core/theme/app_spacing.dart';
import 'package:admity/core/theme/app_theme_extension.dart';
import 'package:admity/features/gap_closer/presentation/gap_providers.dart';
import 'package:admity/shared/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Gap-closer: concrete, dated tasks linked to intensives.
class GapScreen extends ConsumerStatefulWidget {
  const GapScreen({super.key});

  @override
  ConsumerState<GapScreen> createState() => _GapScreenState();
}

class _GapScreenState extends ConsumerState<GapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(gapTasksProvider).isEmpty) {
        ref.read(gapTasksProvider.notifier).regenerate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(gapTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        actions: [
          IconButton(
            onPressed: () => ref.read(gapTasksProvider.notifier).regenerate(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить под профиль',
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Text(
                'Заполни профиль — и я предложу шаги.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.tokens.textMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screen),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final task = tasks[i];
                return BentoCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.isDone,
                        onChanged: (_) => ref
                            .read(gapTasksProvider.notifier)
                            .toggle(task.id),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: context.text.titleSmall?.copyWith(
                                decoration: task.isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              task.description,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.tokens.textMuted),
                            ),
                            if (task.dueDate != null)
                              Text(
                                'до ${task.dueDate!.day}.${task.dueDate!.month}',
                                style: context.text.labelSmall
                                    ?.copyWith(color: context.tokens.warning),
                              ),
                            if (task.linkedIntensiveSlug != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => context.pushNamed(
                                    AppRoutes.intensiveName,
                                    pathParameters: {
                                      'slug': task.linkedIntensiveSlug!,
                                    },
                                  ),
                                  icon: const Icon(Icons.bolt_rounded, size: 16),
                                  label: const Text('Открыть интенсив'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
