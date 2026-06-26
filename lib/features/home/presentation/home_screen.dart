import 'dart:async';
import 'dart:math' as math;

import 'package:admity/core/theme/app_colors.dart';
import 'package:admity/core/theme/app_tokens.dart';
import 'package:admity/features/mentor/application/mentor_notifier.dart';
import 'package:admity/shared/widgets/app_card.dart';
import 'package:admity/shared/widgets/app_scaffold.dart';
import 'package:admity/shared/widgets/featured_button.dart';
import 'package:admity/shared/widgets/mascot_slot.dart';
import 'package:admity/shared/widgets/primary_button.dart';
import 'package:admity/shared/widgets/streak_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Domain: Todo ──────────────────────────────────────────────────────────────

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

// ── Domain: Streak ────────────────────────────────────────────────────────────

class StreakDay {
  const StreakDay({required this.label, required this.lit});
  final String label;
  final bool lit;
}

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

// ── Domain: User Calendar Events ──────────────────────────────────────────────

class CalendarUserEvent {
  const CalendarUserEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.scheduledAt,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final DateTime scheduledAt;

  CalendarUserEvent copyWith({
    String? title,
    String? description,
    DateTime? date,
    DateTime? scheduledAt,
  }) => CalendarUserEvent(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    scheduledAt: scheduledAt ?? this.scheduledAt,
  );
}

class UserEventsNotifier extends Notifier<List<CalendarUserEvent>> {
  int _nextId = 10;

  @override
  List<CalendarUserEvent> build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return [
      CalendarUserEvent(
        id: '1',
        title: 'Онлайн-консультация по ЕНТ',
        description: 'Вебинар с преподавателем математики',
        date: today,
        scheduledAt: DateTime(today.year, today.month, today.day, 15),
      ),
      CalendarUserEvent(
        id: '2',
        title: 'Повторение биологии',
        description: 'Темы: клетка, фотосинтез',
        date: today,
        scheduledAt: DateTime(today.year, today.month, today.day, 18, 30),
      ),
      CalendarUserEvent(
        id: '3',
        title: 'Сдать эссе наставнику',
        description: 'Черновик на тему «Моя будущая профессия»',
        date: tomorrow,
        scheduledAt: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10),
      ),
    ];
  }

  void add(String title, String? description, DateTime scheduledAt) {
    final id = (_nextId++).toString();
    final date = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );
    state = [
      ...state,
      CalendarUserEvent(
        id: id,
        title: title,
        description: description,
        date: date,
        scheduledAt: scheduledAt,
      ),
    ];
  }

  void update(
    String id,
    String title,
    String? description,
    DateTime scheduledAt,
  ) {
    final date = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );
    state = [
      for (final e in state)
        if (e.id == id)
          e.copyWith(
            title: title,
            description: description,
            date: date,
            scheduledAt: scheduledAt,
          )
        else
          e,
    ];
  }

  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final userEventsProvider =
    NotifierProvider<UserEventsNotifier, List<CalendarUserEvent>>(
      UserEventsNotifier.new,
    );

// ── HomeScreen ────────────────────────────────────────────────────────────────

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
            _Header(tokens: tokens)
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.12, end: 0, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            _StreakWeekSection(tokens: tokens)
                .animate()
                .fadeIn(delay: 60.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 60.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            _InteractiveCalendar(tokens: tokens)
                .animate()
                .fadeIn(delay: 120.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 120.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            _TodayTaskCard(tokens: tokens)
                .animate()
                .fadeIn(delay: 180.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 180.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            _TaskListCard(todos: todos, tokens: tokens, ref: ref)
                .animate()
                .fadeIn(delay: 240.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 240.ms, duration: 350.ms),

            SizedBox(height: tokens.gapLg),

            _CareerTestCard(tokens: tokens)
                .animate()
                .fadeIn(delay: 300.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 300.ms, duration: 350.ms),

            SizedBox(height: tokens.gapXxl),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
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
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(color: AppColors.ink),
              ),
              SizedBox(height: tokens.gapXs),
              Text(
                'Готов к новым знаниям?',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Серия: 7 дней',
          button: false,
          child: const StreakBadge(days: 7),
        ),
      ],
    );
  }
}

// ── Streak Week (always-visible beautiful card) ───────────────────────────────

class _StreakWeekSection extends ConsumerStatefulWidget {
  const _StreakWeekSection({required this.tokens});
  final AppTokens tokens;

  @override
  ConsumerState<_StreakWeekSection> createState() => _StreakWeekSectionState();
}

class _StreakWeekSectionState extends ConsumerState<_StreakWeekSection> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(streakWeekProvider);
    final tokens = widget.tokens;
    final todayWeekday = DateTime.now().weekday; // 1=Mon … 7=Sun

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.accentLime, size: 18),
              SizedBox(width: tokens.gapXs),
              Text(
                'Серия — 7 дней',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final day = days[i];
              final isToday = (i + 1) == todayWeekday;
              final isSelected = _selectedIndex == i;

              return GestureDetector(
                onTap: () => setState(
                  () => _selectedIndex = _selectedIndex == i ? null : i,
                ),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 40,
                        height: 44,
                        decoration: BoxDecoration(
                          color: day.lit
                              ? AppColors.accentLime
                              : AppColors.surfaceTint,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: isToday || isSelected
                              ? Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                )
                              : Border.all(
                                  color: day.lit
                                      ? AppColors.accentLime
                                      : AppColors.border,
                                  width: 1.5,
                                ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (day.lit)
                              const Icon(
                                Icons.bolt,
                                color: AppColors.ink,
                                size: 16,
                              )
                            else
                              const Icon(
                                Icons.circle_outlined,
                                color: AppColors.border,
                                size: 14,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: tokens.gapXs),
                      Text(
                        day.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: day.lit
                              ? AppColors.ink
                              : AppColors.inkSecondary,
                          fontWeight: day.lit || isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          // Selected day state pill
          if (_selectedIndex != null) ...[
            SizedBox(height: tokens.gapSm),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey(_selectedIndex),
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.gapMd,
                  vertical: tokens.gapXs,
                ),
                decoration: BoxDecoration(
                  color: days[_selectedIndex!].lit
                      ? AppColors.accentLime.withValues(alpha: 0.18)
                      : AppColors.surfaceTint,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: days[_selectedIndex!].lit
                        ? AppColors.accentLime
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  days[_selectedIndex!].lit
                      ? 'День завершён!'
                      : 'Этот день пропущен',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: days[_selectedIndex!].lit
                        ? AppColors.ink
                        : AppColors.inkSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: tokens.gapXs),
          Text(
            '5 из 7 дней на этой неделе',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Interactive Calendar ───────────────────────────────────────────────────────

class _InteractiveCalendar extends ConsumerStatefulWidget {
  const _InteractiveCalendar({required this.tokens});
  final AppTokens tokens;

  @override
  ConsumerState<_InteractiveCalendar> createState() =>
      _InteractiveCalendarState();
}

class _InteractiveCalendarState extends ConsumerState<_InteractiveCalendar> {
  late DateTime _viewMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  static const _monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];
  static const _weekdayLabels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  String _timeLabel(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, DateTime.now());

  void _openEventSheet(BuildContext context, CalendarUserEvent? existing) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _EventSheet(
          existing: existing,
          initialDate: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final userEvents = ref.watch(userEventsProvider);
    final mentorEvents = ref.watch(
      mentorProvider.select((s) => s.calendarEvents),
    );

    // Build calendar grid days
    final firstOfMonth = _viewMonth;
    // weekday: 1=Mon, offset so Mon=col0
    final startOffset = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      _viewMonth.year,
      _viewMonth.month,
    );

    final prevMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
    final daysInPrevMonth = DateUtils.getDaysInMonth(
      prevMonth.year,
      prevMonth.month,
    );

    final totalCells = ((startOffset + daysInMonth) / 7).ceil() * 7;

    final cells = <DateTime>[];
    for (var i = 0; i < totalCells; i++) {
      final offset = i - startOffset;
      if (offset < 0) {
        cells.add(
          DateTime(
            prevMonth.year,
            prevMonth.month,
            daysInPrevMonth + offset + 1,
          ),
        );
      } else if (offset < daysInMonth) {
        cells.add(DateTime(_viewMonth.year, _viewMonth.month, offset + 1));
      } else {
        final nextMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
        cells.add(
          DateTime(nextMonth.year, nextMonth.month, offset - daysInMonth + 1),
        );
      }
    }

    // Events for selected date
    final selectedUserEvents =
        userEvents
            .where(
              (e) => _isSameDay(e.date, _selectedDate),
            )
            .toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final selectedMentorEvents = mentorEvents.where((e) {
      return _isSameDay(e.scheduledAt, _selectedDate);
    }).toList()..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    // Days that have user events (for dot indicator)
    final eventDates = userEvents.map((e) => e.date).toSet();
    final mentorEventDates = mentorEvents
        .map(
          (e) => DateTime(
            e.scheduledAt.year,
            e.scheduledAt.month,
            e.scheduledAt.day,
          ),
        )
        .toSet();
    final allEventDates = {...eventDates, ...mentorEventDates};

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Row(
            children: [
              GestureDetector(
                onTap: _prevMonth,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_left,
                    color: AppColors.ink,
                    size: 22,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${_monthNames[_viewMonth.month - 1]} ${_viewMonth.year}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
                ),
              ),
              GestureDetector(
                onTap: _nextMonth,
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.ink,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),

          // Weekday labels
          Row(
            children: _weekdayLabels
                .map(
                  (l) => Expanded(
                    child: Text(
                      l,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: tokens.gapXs),

          // Calendar grid
          ...List.generate((totalCells / 7).ceil(), (rowIdx) {
            final rowCells = cells.sublist(
              rowIdx * 7,
              math.min(rowIdx * 7 + 7, cells.length),
            );
            return Padding(
              padding: EdgeInsets.only(bottom: tokens.gapXs),
              child: Row(
                children: rowCells.map((date) {
                  final isCurrentMonth = date.month == _viewMonth.month;
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isToday(date);
                  final hasEvent = allEventDates.any(
                    (d) => _isSameDay(d, date),
                  );

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 44,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : isSelected
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: isToday
                                            ? AppColors.white
                                            : isSelected
                                            ? AppColors.primary
                                            : isCurrentMonth
                                            ? AppColors.ink
                                            : AppColors.inkSecondary.withValues(
                                                alpha: 0.5,
                                              ),
                                        fontWeight: isToday || isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      ),
                                ),
                              ),
                            ),
                            if (hasEvent && !isToday)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentLime,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),

          SizedBox(height: tokens.gapSm),

          // Selected day agenda
          Container(
            width: double.infinity,
            height: 1,
            color: AppColors.border,
          ),
          SizedBox(height: tokens.gapMd),

          // Agenda header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.primary,
                  size: 14,
                ),
              ),
              SizedBox(width: tokens.gapSm),
              Text(
                _agendaDateLabel(_selectedDate),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.ink),
              ),
            ],
          ),
          SizedBox(height: tokens.gapSm),

          // User events
          if (selectedUserEvents.isEmpty && selectedMentorEvents.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
              child: Text(
                'Событий нет. Добавьте первое!',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.inkSecondary),
              ),
            )
          else ...[
            for (final e in selectedUserEvents)
              _AgendaEventRow(
                title: e.title,
                time: _timeLabel(e.scheduledAt),
                isEraly: false,
                tokens: tokens,
                onEdit: () => _openEventSheet(context, e),
                onDelete: () =>
                    ref.read(userEventsProvider.notifier).delete(e.id),
              ),
            for (final e in selectedMentorEvents)
              _AgendaEventRow(
                title: e.title,
                time: _timeLabel(e.scheduledAt),
                isEraly: true,
                tokens: tokens,
              ),
          ],

          SizedBox(height: tokens.gapMd),

          PrimaryButton(
            label: 'Добавить событие',
            icon: const Icon(Icons.add, color: AppColors.white, size: 18),
            onPressed: () => _openEventSheet(context, null),
          ),
        ],
      ),
    );
  }

  String _agendaDateLabel(DateTime d) {
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
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
  }
}

class _AgendaEventRow extends StatelessWidget {
  const _AgendaEventRow({
    required this.title,
    required this.time,
    required this.isEraly,
    required this.tokens,
    this.onEdit,
    this.onDelete,
  });

  final String title;
  final String time;
  final bool isEraly;
  final AppTokens tokens;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.gapSm),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: isEraly ? AppColors.primary : AppColors.mascotGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: tokens.gapSm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isEraly)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Ералы',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                  ],
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isEraly) ...[
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.inkSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.errorRed,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Event Sheet ───────────────────────────────────────────────────────────────

class _EventSheet extends ConsumerStatefulWidget {
  const _EventSheet({required this.initialDate, this.existing});
  final CalendarUserEvent? existing;
  final DateTime initialDate;

  @override
  ConsumerState<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends ConsumerState<_EventSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _scheduledAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _descCtrl = TextEditingController(
      text: widget.existing?.description ?? '',
    );
    _scheduledAt =
        widget.existing?.scheduledAt ??
        DateTime(
          widget.initialDate.year,
          widget.initialDate.month,
          widget.initialDate.day,
          9,
        );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (!mounted) return;
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _scheduledAt.hour,
        time?.minute ?? _scheduledAt.minute,
      );
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final desc = _descCtrl.text.trim();
    if (widget.existing == null) {
      ref
          .read(userEventsProvider.notifier)
          .add(
            title,
            desc.isEmpty ? null : desc,
            _scheduledAt,
          );
    } else {
      ref
          .read(userEventsProvider.notifier)
          .update(
            widget.existing!.id,
            title,
            desc.isEmpty ? null : desc,
            _scheduledAt,
          );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    ref.read(userEventsProvider.notifier).delete(widget.existing!.id);
    Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();
    final isNew = widget.existing == null;

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
                Text(
                  isNew ? 'Новое событие' : 'Редактировать событие',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
                ),
                SizedBox(height: tokens.gapLg),
                _SheetTextField(
                  controller: _titleCtrl,
                  label: 'Название',
                  hint: 'Что запланировано?',
                  tokens: tokens,
                ),
                SizedBox(height: tokens.gapMd),
                _SheetTextField(
                  controller: _descCtrl,
                  label: 'Описание',
                  hint: 'Подробности (необязательно)',
                  tokens: tokens,
                  maxLines: 2,
                ),
                SizedBox(height: tokens.gapMd),
                GestureDetector(
                  onTap: () => _pickDateTime(context),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.all(tokens.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint,
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: tokens.gapSm),
                        Text(
                          _formatDateTime(_scheduledAt),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.inkSecondary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: tokens.gapXl),
                PrimaryButton(label: 'Сохранить', onPressed: _save),
                if (!isNew) ...[
                  SizedBox(height: tokens.gapMd),
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
                            'Удалить событие',
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

// ── Today Task Card ───────────────────────────────────────────────────────────

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
            onPressed: () => context.go('/lesson'),
          ),
        ],
      ),
    );
  }
}

// ── Task List with CRUD ───────────────────────────────────────────────────────

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

// ── Task Sheet ────────────────────────────────────────────────────────────────

class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({this.existing});
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
    _descCtrl = TextEditingController(
      text: widget.existing?.description ?? '',
    );
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
                  _SheetTextField(
                    controller: _titleCtrl,
                    label: 'Название',
                    hint: 'Что нужно сделать?',
                    tokens: tokens,
                  ),
                  SizedBox(height: tokens.gapMd),
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

// ── Shared sheet text field ───────────────────────────────────────────────────

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

// ── Career Test entry card ────────────────────────────────────────────────────

class _CareerTestCard extends StatelessWidget {
  const _CareerTestCard({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.navyDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: tokens.gapMd),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Узнай свою профессию',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.ink),
                    ),
                    SizedBox(height: tokens.gapXs),
                    Text(
                      'Ежедневный тест — 3 минуты',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.gapMd),
          FeaturedButton(
            label: 'Пройти тест',
            onPressed: () => context.push('/career-test'),
          ),
        ],
      ),
    );
  }
}
