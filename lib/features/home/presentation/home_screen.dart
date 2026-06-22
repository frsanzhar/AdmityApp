import 'dart:async';

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/features/mentor/domain/proposed_event.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Domain ────────────────────────────────────────────────────────────────────

/// A single to-do item for today's task list.
class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    this.description = '',
    this.done = false,
  });

  final int id;
  final String title;
  final String description;
  final bool done;

  TodoItem copyWith({String? title, String? description, bool? done}) =>
      TodoItem(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        done: done ?? this.done,
      );
}

/// In-memory to-do list for today's tasks.  Plain Notifier — no codegen.
class TodoNotifier extends Notifier<List<TodoItem>> {
  int _nextId = 5;

  @override
  List<TodoItem> build() => [
    const TodoItem(
      id: 1,
      title: 'Пройти урок по математике',
      description: 'Раздел «Сравнение вероятностей» — примерно 15 минут.',
    ),
    const TodoItem(
      id: 2,
      title: 'Изучить стипендии БОЛАШАК',
      description:
          'Проверить требования для поступления и дедлайн подачи документов.',
    ),
    const TodoItem(
      id: 3,
      title: 'Обновить профиль',
      description:
          'Добавить последние оценки и загрузить актуальные документы.',
    ),
    const TodoItem(
      id: 4,
      title: 'Прочитать о ЕНТ требованиях',
      description: 'Минимальные баллы по каждому предмету для поступления.',
    ),
  ];

  void toggle(int id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
  }

  void update(int id, String title, String description) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(title: title, description: description)
        else
          item,
    ];
  }

  void delete(int id) {
    state = state.where((item) => item.id != id).toList();
  }

  void add(String title, String description) {
    final id = _nextId++;
    state = [
      ...state,
      TodoItem(id: id, title: title, description: description),
    ];
  }
}

final todoProvider = NotifierProvider<TodoNotifier, List<TodoItem>>(
  TodoNotifier.new,
);

// ── Streak data ───────────────────────────────────────────────────────────────

/// One day in the weekly streak view.
class StreakDay {
  const StreakDay({required this.label, required this.lit});
  final String label;
  final bool lit;
}

/// Seed streak data — 7-day week ending today with 5 lit days.
final streakWeekProvider = Provider<List<StreakDay>>((ref) {
  return const [
    StreakDay(label: 'Пн', lit: true),
    StreakDay(label: 'Вт', lit: true),
    StreakDay(label: 'Ср', lit: true),
    StreakDay(label: 'Чт', lit: false),
    StreakDay(label: 'Пт', lit: true),
    StreakDay(label: 'Сб', lit: true),
    StreakDay(label: 'Вс', lit: false),
  ];
});

// ── HomeScreen ────────────────────────────────────────────────────────────────

/// Home screen — §7.2.
///
/// Layout: AppScaffold > SingleChildScrollView > Column(mainAxisSize: .min).
/// Never uses CrossAxisAlignment.stretch inside scroll (CLAUDE.md anti-gotcha).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final todos = ref.watch(todoProvider);
    final calendarEvents = ref.watch(
      mentorProvider.select((s) => s.calendarEvents),
    );

    // Filter today's calendar events (mentor-committed).
    final now = DateTime.now();
    final todayEvents = calendarEvents.where((e) {
      final d = e.scheduledAt;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();

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
            // ── Header ─────────────────────────────────────────────────────
            _Header(tokens: tokens)
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.12, end: 0, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            // ── Compact calendar / today's agenda ──────────────────────────
            _TodayAgendaCard(events: todayEvents, tokens: tokens)
                .animate()
                .fadeIn(delay: 80.ms, duration: 350.ms)
                .slideY(begin: 0.10, end: 0, delay: 80.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            // ── Задание на сегодня ──────────────────────────────────────────
            _TodayTaskCard(tokens: tokens)
                .animate()
                .fadeIn(delay: 160.ms, duration: 350.ms)
                .slideY(begin: 0.10, end: 0, delay: 160.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            // ── Сегодняшние задачи ──────────────────────────────────────────
            _TaskListCard(todos: todos, tokens: tokens, ref: ref)
                .animate()
                .fadeIn(delay: 240.ms, duration: 350.ms)
                .slideY(begin: 0.10, end: 0, delay: 240.ms, duration: 350.ms),

            SizedBox(height: tokens.gapXl),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerStatefulWidget {
  const _Header({required this.tokens});
  final AppTokens tokens;

  @override
  ConsumerState<_Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<_Header> {
  bool _streakPopupVisible = false;

  void _toggleStreakPopup() {
    setState(() => _streakPopupVisible = !_streakPopupVisible);
  }

  @override
  Widget build(BuildContext context) {
    final streakWeek = ref.watch(streakWeekProvider);
    final tokens = widget.tokens;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting text + mascot
            Expanded(
              child: Row(
                children: [
                  const MascotSlot(size: 56, tag: 'home'),
                  SizedBox(width: tokens.gapMd),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Привет!',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(color: AppColors.ink),
                        ),
                        SizedBox(height: tokens.gapXs),
                        Text(
                          'Готов к новым знаниям?',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tappable streak badge
            GestureDetector(
              onTap: _toggleStreakPopup,
              behavior: HitTestBehavior.opaque,
              child: Semantics(
                label: 'Серия: 7 дней. Нажмите для просмотра недели',
                button: true,
                child: const StreakBadge(days: 7)
                    .animate(
                      onPlay: (ctrl) => ctrl.forward(),
                    )
                    .scaleXY(
                      begin: 0.85,
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
            ),
          ],
        ),
        // Streak week popup
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: _streakPopupVisible
              ? Padding(
                  padding: EdgeInsets.only(top: tokens.gapMd),
                  child: _StreakWeekCard(
                    days: streakWeek,
                    tokens: tokens,
                    onClose: _toggleStreakPopup,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Streak week popup ─────────────────────────────────────────────────────────

class _StreakWeekCard extends StatelessWidget {
  const _StreakWeekCard({
    required this.days,
    required this.tokens,
    required this.onClose,
  });

  final List<StreakDay> days;
  final AppTokens tokens;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentLime, size: 18),
              SizedBox(width: tokens.gapXs),
              Expanded(
                child: Text(
                  'Серия — эта неделя',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.inkSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final day in days) _StreakDayDot(day: day, tokens: tokens),
            ],
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            '5 из 7 дней на этой неделе',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: -0.05, duration: 220.ms);
  }
}

class _StreakDayDot extends StatelessWidget {
  const _StreakDayDot({required this.day, required this.tokens});
  final StreakDay day;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: day.lit ? AppColors.accentLime : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: day.lit ? AppColors.accentLime : AppColors.border,
              width: 2,
            ),
          ),
          child: day.lit
              ? const Icon(Icons.bolt, color: AppColors.ink, size: 16)
              : null,
        ),
        SizedBox(height: tokens.gapXs),
        Text(
          day.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: day.lit ? AppColors.ink : AppColors.inkSecondary,
            fontWeight: day.lit ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Today's agenda calendar strip ─────────────────────────────────────────────

class _TodayAgendaCard extends StatelessWidget {
  const _TodayAgendaCard({
    required this.events,
    required this.tokens,
  });

  final List<CalendarEvent> events;
  final AppTokens tokens;

  /// Hand-rolled RU day name — no initializeDateFormatting (CLAUDE.md §dates).
  String _todayLabel() {
    final now = DateTime.now();
    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    final wd = weekdays[now.weekday - 1];
    final m = months[now.month - 1];
    return '$wd, ${now.day} $m';
  }

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: calendar icon + today's date
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
              SizedBox(width: tokens.gapSm),
              Text(
                _todayLabel(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          // Event list or empty state
          if (events.isEmpty) ...[
            Row(
              children: [
                Container(
                  width: 3,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: tokens.gapMd),
                Expanded(
                  child: Text(
                    'Событий на сегодня нет.\nСпроси Ералы добавить их в календарь.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            for (int i = 0; i < events.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: i < events.length - 1 ? tokens.gapSm : 0,
                ),
                child: _AgendaEventRow(
                  event: events[i],
                  timeLabel: _timeLabel(events[i].scheduledAt),
                  tokens: tokens,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AgendaEventRow extends StatelessWidget {
  const _AgendaEventRow({
    required this.event,
    required this.timeLabel,
    required this.tokens,
  });

  final CalendarEvent event;
  final String timeLabel;
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accent time-bar
        Container(
          width: 3,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: tokens.gapMd),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                timeLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── "Задание на сегодня" card ──────────────────────────────────────────────────

class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Задание на сегодня',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: tokens.gapSm),
          Text(
            'Урок: Сравнение вероятностей — продолжи с того места, где остановился.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
          ),
          SizedBox(height: tokens.gapLg),
          PrimaryButton(
            label: 'Продолжить',
            onPressed: () => context.go('/courses'),
          ),
        ],
      ),
    );
  }
}

// ── Task list with CRUD ───────────────────────────────────────────────────────

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.todos,
    required this.tokens,
    required this.ref,
  });

  final List<TodoItem> todos;
  final AppTokens tokens;
  final WidgetRef ref;

  void _openTaskSheet(BuildContext context, TodoItem? item) {
    // Bottom sheet is shown inside the existing ProviderScope — no need to
    // re-wrap.  Ignore the returned Future; it resolves when the sheet closes.
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _TaskSheet(existing: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Сегодняшние задачи',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
                ),
              ),
              // Add task button
              GestureDetector(
                onTap: () => _openTaskSheet(context, null),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),
          if (todos.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.gapMd),
              child: Text(
                'Задач нет. Нажмите + чтобы добавить.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
              ),
            )
          else
            ...todos.map(
              (item) => _TodoRow(
                item: item,
                tokens: tokens,
                onToggle: () => ref.read(todoProvider.notifier).toggle(item.id),
                onTap: () => _openTaskSheet(context, item),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow({
    required this.item,
    required this.tokens,
    required this.onToggle,
    required this.onTap,
  });

  final TodoItem item;
  final AppTokens tokens;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
        child: Row(
          children: [
            // Checkbox — tapping it directly toggles; tapping row text opens sheet.
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child:
                  AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: item.done
                              ? AppColors.successGreen
                              : AppColors.white,
                          border: Border.all(
                            color: item.done
                                ? AppColors.successGreen
                                : AppColors.border,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: item.done
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 15,
                              )
                            : null,
                      )
                      .animate(target: item.done ? 1 : 0)
                      .scaleXY(begin: 1, end: 1.18, duration: 120.ms)
                      .then()
                      .scaleXY(begin: 1.18, end: 1, duration: 120.ms),
            ),
            SizedBox(width: tokens.gapMd),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: item.done ? AppColors.inkSecondary : AppColors.ink,
                      decoration: item.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.inkSecondary,
                    ),
                  ),
                  if (item.description.isNotEmpty && !item.done) ...[
                    SizedBox(height: tokens.gapXs),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.border,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task sheet (read / edit / delete) ────────────────────────────────────────

class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({this.existing});

  /// Null → add-new mode; non-null → read/edit/delete mode.
  final TodoItem? existing;

  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late bool _editing;

  @override
  void initState() {
    super.initState();
    _editing = widget.existing == null;
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    if (widget.existing == null) {
      ref.read(todoProvider.notifier).add(title, _descCtrl.text.trim());
    } else {
      ref
          .read(todoProvider.notifier)
          .update(widget.existing!.id, title, _descCtrl.text.trim());
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    ref.read(todoProvider.notifier).delete(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final isNew = widget.existing == null;
    final title = isNew ? 'Новая задача' : (widget.existing!.title);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusXl),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.gapLg,
              tokens.screenPadding,
              tokens.gapXl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sheet handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: tokens.gapLg),
                // Sheet header
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _editing
                            ? (isNew ? 'Новая задача' : 'Редактировать')
                            : title,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.ink),
                      ),
                    ),
                    if (!isNew && !_editing)
                      GestureDetector(
                        onTap: () => setState(() => _editing = true),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: tokens.gapLg),
                if (_editing) ...[
                  // Title field
                  _SheetTextField(
                    controller: _titleCtrl,
                    label: 'Название',
                    hint: 'Что нужно сделать?',
                    tokens: tokens,
                  ),
                  SizedBox(height: tokens.gapMd),
                  // Description field
                  _SheetTextField(
                    controller: _descCtrl,
                    label: 'Описание',
                    hint: 'Подробности (необязательно)',
                    tokens: tokens,
                    maxLines: 3,
                  ),
                  SizedBox(height: tokens.gapXl),
                  PrimaryButton(label: 'Сохранить', onPressed: _save),
                ] else ...[
                  // Read-only description
                  if (widget.existing!.description.isNotEmpty)
                    Text(
                      widget.existing!.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    )
                  else
                    Text(
                      'Описание не добавлено.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  SizedBox(height: tokens.gapXxl),
                  // Delete action
                  GestureDetector(
                    onTap: _delete,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 48,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: AppColors.errorRed,
                            size: 20,
                          ),
                          SizedBox(width: tokens.gapSm),
                          Text(
                            'Удалить задачу',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: AppColors.errorRed),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetTextField extends StatelessWidget {
  const _SheetTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.tokens,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final AppTokens tokens;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.inkSecondary),
        ),
        SizedBox(height: tokens.gapXs),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.border),
            filled: true,
            fillColor: AppColors.surfaceTint,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              borderSide: const BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radiusMd),
            ),
          ),
        ),
      ],
    );
  }
}
