import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A single to-do item for today's task list.
class TodoItem {
  const TodoItem({required this.id, required this.title, this.done = false});

  final int id;
  final String title;
  final bool done;

  TodoItem copyWith({bool? done}) =>
      TodoItem(id: id, title: title, done: done ?? this.done);
}

/// In-memory to-do list for today's tasks (seed data, no backend yet).
class TodoNotifier extends Notifier<List<TodoItem>> {
  @override
  List<TodoItem> build() => const [
        TodoItem(id: 1, title: 'Пройти урок по математике'),
        TodoItem(id: 2, title: 'Изучить стипендии БОЛАШАК'),
        TodoItem(id: 3, title: 'Обновить профиль'),
        TodoItem(id: 4, title: 'Прочитать о ЕНТ требованиях'),
      ];

  void toggle(int id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
  }
}

final todoProvider =
    NotifierProvider<TodoNotifier, List<TodoItem>>(TodoNotifier.new);

/// Home screen (DESIGN_SYSTEM.md §7.2).
///
/// Layout: AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min).
/// Never use CrossAxisAlignment.stretch inside scroll — see CLAUDE.md.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final todos = ref.watch(todoProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.screenPadding,
          vertical: tokens.gapXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Привет!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(color: AppColors.ink),
                      ),
                      SizedBox(height: tokens.gapXs),
                      Text(
                        'Готов к новым знаниям?',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.inkSecondary),
                      ),
                    ],
                  ),
                ),
                const StreakBadge(days: 7),
              ],
            ),
            SizedBox(height: tokens.gapMd),
            const MascotSlot(size: 80, tag: 'home'),
            SizedBox(height: tokens.gapXl),

            // ── Задание на сегодня ──────────────────────────────────────────
            AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Задание на сегодня',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.ink),
                  ),
                  SizedBox(height: tokens.gapSm),
                  Text(
                    'Урок: Сравнение вероятностей — продолжи с того места, где остановился.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.inkSecondary),
                  ),
                  SizedBox(height: tokens.gapLg),
                  PrimaryButton(
                    label: 'Продолжить',
                    onPressed: () => context.go('/courses'),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.gapLg),

            // ── Сегодняшние задачи ──────────────────────────────────────────
            AppCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сегодняшние задачи',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: AppColors.ink),
                  ),
                  SizedBox(height: tokens.gapSm),
                  ...todos.map(
                    (item) => _TodoRow(
                      item: item,
                      onToggle: () =>
                          ref.read(todoProvider.notifier).toggle(item.id),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.gapXl),
          ],
        ),
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.item, required this.onToggle});

  final TodoItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.done ? AppColors.successGreen : AppColors.white,
                border: Border.all(
                  color:
                      item.done ? AppColors.successGreen : AppColors.border,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.done
                  ? const Icon(Icons.check, color: AppColors.white, size: 14)
                  : null,
            ),
            SizedBox(width: tokens.gapMd),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color:
                          item.done ? AppColors.inkSecondary : AppColors.ink,
                      decoration:
                          item.done ? TextDecoration.lineThrough : null,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
