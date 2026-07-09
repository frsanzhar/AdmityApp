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
import 'package:hive_flutter/hive_flutter.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Formats [d] as `'yyyy-MM-dd'` for use as a Hive key.
String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Russian plural for "день": 1 день, 2–4 дня, 5+ дней.
String _streakDayWord(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod10 == 1 && mod100 != 11) return 'день';
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'дня';
  return 'дней';
}

// ── Domain: Todo ──────────────────────────────────────────────────────────────

/// A user-created task associated with a specific calendar day.
class TodoItem {
  /// Creates a [TodoItem].
  const TodoItem({
    required this.id,
    required this.title,
    required this.date,
    this.description = '',
    this.done = false,
  });

  final int id;
  final String title;
  final String description;
  final bool done;

  /// Day this task belongs to (normalised to midnight local time).
  final DateTime date;

  /// Returns a copy with the given fields replaced.
  TodoItem copyWith({
    String? title,
    String? description,
    bool? done,
    DateTime? date,
  }) => TodoItem(
    id: id,
    title: title ?? this.title,
    description: description ?? this.description,
    done: done ?? this.done,
    date: date ?? this.date,
  );
}

/// Notifier for the user's task list.
///
/// New accounts start with an empty list — no fabricated default tasks.
class TodoNotifier extends Notifier<List<TodoItem>> {
  int _nextId = 1;

  @override
  List<TodoItem> build() => const [];

  /// Toggles the done flag of the task with the given id.
  void toggle(int id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(done: !item.done) else item,
    ];
  }

  /// Updates the title and description of the task with [id].
  void update(int id, String title, String description) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(title: title, description: description)
        else
          item,
    ];
  }

  /// Deletes the task with [id].
  void delete(int id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Adds a new task for [date].
  void add(String title, String description, DateTime date) {
    final id = _nextId++;
    final normalised = DateTime(date.year, date.month, date.day);
    state = [
      ...state,
      TodoItem(
        id: id,
        title: title,
        description: description,
        date: normalised,
      ),
    ];
  }
}

/// Provider for the user's task list.
final todoProvider = NotifierProvider<TodoNotifier, List<TodoItem>>(
  TodoNotifier.new,
);

// ── Domain: Activity seconds (streak data) ────────────────────────────────────

/// In-memory accumulator of daily active seconds, optionally backed by Hive.
///
/// Keys are `'yyyy-MM-dd'` strings; values are accumulated seconds.
/// A day is considered "active" when its value is ≥ 300 (5 minutes).
///
/// ActivityTimeTracker writes to this notifier; streak providers read it.
///
/// Hive persistence (cross-session): call `Hive.openBox<int>('admity_activity')`
/// in bootstrap.dart before HomeScreen mounts; build() will then load the data
/// synchronously.  Without that, the notifier operates in-memory only.
class ActivitySecondsNotifier extends Notifier<Map<String, int>> {
  static const _boxName = 'admity_activity';

  @override
  Map<String, int> build() {
    // Synchronous load — only works when the box was opened at app startup.
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box<int>(_boxName);
        return Map<String, int>.unmodifiable({
          for (final k in box.keys.cast<String>())
            k: box.get(k, defaultValue: 0) ?? 0,
        });
      }
    } on Object {
      // Box inaccessible — fall through to empty map.
    }
    return const {};
  }

  /// Adds [delta] seconds to [dateKey] and persists to Hive (best-effort).
  void addSeconds(String dateKey, int delta) {
    if (delta <= 0) return;
    final updated = Map<String, int>.from(state);
    updated[dateKey] = (updated[dateKey] ?? 0) + delta;
    state = Map<String, int>.unmodifiable(updated);
    _persist(dateKey, updated[dateKey]!);
  }

  // Silently persists one entry to Hive if the box is already open.
  // In tests the box is never opened, so this is a no-op — no async futures
  // are created and no zone errors can leak into the test binding.
  void _persist(String dateKey, int value) {
    try {
      if (!Hive.isBoxOpen(_boxName)) return;
      // box.put() is async; consume any error before it reaches the zone.
      unawaited(
        Hive.box<int>(_boxName)
            .put(dateKey, value)
            .then((_) {}, onError: (Object _) {}),
      );
    } on Object {
      // Box became unavailable between isBoxOpen and put — skip persist.
    }
  }

  /// Bulk-loads external data into the notifier state.
  void loadFromHive(Map<String, int> data) {
    state = Map<String, int>.unmodifiable(data);
  }
}

/// Provider for accumulated daily active seconds.
final activitySecondsProvider =
    NotifierProvider<ActivitySecondsNotifier, Map<String, int>>(
      ActivitySecondsNotifier.new,
    );

// ── Domain: Streak ────────────────────────────────────────────────────────────

/// A day in the streak-week widget.
class StreakDay {
  /// Creates a [StreakDay].
  const StreakDay({required this.label, required this.lit});

  /// Short weekday label ('Пн', 'Вт', …).
  final String label;

  /// Whether the user earned this day (≥ 5 minutes of active time).
  final bool lit;
}

/// The seven days of the current calendar week with [StreakDay.lit] set from
/// real activity data.  Monday is index 0.
final streakWeekProvider = Provider<List<StreakDay>>((ref) {
  final data = ref.watch(activitySecondsProvider);
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
  return List.generate(7, (i) {
    final day = DateTime(monday.year, monday.month, monday.day + i);
    final key = _dateKey(day);
    return StreakDay(label: labels[i], lit: (data[key] ?? 0) >= 300);
  });
});

/// Number of consecutive days (ending today) where the user was active ≥ 5 min.
///
/// Returns 0 if today is not yet earned.
final streakCountProvider = Provider<int>((ref) {
  final data = ref.watch(activitySecondsProvider);
  var count = 0;
  var date = DateTime.now();
  while (true) {
    final key = _dateKey(date);
    if ((data[key] ?? 0) >= 300) {
      count++;
      date = date.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return count;
});

// ── Activity time tracker ─────────────────────────────────────────────────────

/// Tracks how many seconds the app is actively in the foreground per calendar
/// day.
///
/// Registers itself as a [WidgetsBindingObserver] and flushes accumulated
/// seconds to activitySecondsProvider every 30 s and on every pause/detach.
///
/// Hive persistence is handled entirely by ActivitySecondsNotifier (sync load
/// in build() if box is pre-opened) and addSeconds() (sync-guarded put).
/// This tracker never opens a Hive box directly, so no async Futures are
/// created in tests and no zone errors can leak into the test binding.
class ActivityTimeTracker with WidgetsBindingObserver {
  /// Creates a tracker that writes to the given Riverpod ref.
  ActivityTimeTracker(this._ref);

  final WidgetRef _ref;
  DateTime? _sessionStart;
  Timer? _flushTimer;

  /// Registers the lifecycle observer and starts the flush timer.
  ///
  /// Fully synchronous — safe to call directly from State.initState.
  void init() {
    WidgetsBinding.instance.addObserver(this);
    _onResume(); // home mounts while the app is already in the foreground
  }

  /// Flushes the final partial session and stops tracking.
  ///
  /// Call from [State.dispose].
  void dispose() {
    _flushNow();
    _flushTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onResume();
    } else {
      // paused / inactive / detached / hidden
      _flushNow();
      _flushTimer?.cancel();
    }
  }

  void _onResume() {
    _sessionStart = DateTime.now();
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _flushNow(),
    );
  }

  /// Attributes elapsed seconds since _sessionStart to the correct date key
  /// and advances the window to avoid double-counting.
  void _flushNow() {
    final start = _sessionStart;
    if (start == null) return;
    final now = DateTime.now();
    final delta = now.difference(start).inSeconds;
    if (delta <= 0) return;
    _sessionStart = DateTime.now();
    _ref.read(activitySecondsProvider.notifier).addSeconds(_dateKey(start), delta);
  }
}

// ── Domain: User Calendar Events ──────────────────────────────────────────────

/// A calendar event created by the user (or confirmed from Ералы).
class CalendarUserEvent {
  /// Creates a [CalendarUserEvent].
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

  /// Day normalised to midnight local time.
  final DateTime date;
  final DateTime scheduledAt;

  /// Returns a copy with the given fields replaced.
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

/// Notifier for user-created calendar events.
class UserEventsNotifier extends Notifier<List<CalendarUserEvent>> {
  int _nextId = 1;

  @override
  List<CalendarUserEvent> build() {
    // A new account starts with an empty calendar — no fabricated events.
    return const [];
  }

  /// Adds a new event.
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

  /// Updates an existing event.
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

  /// Deletes the event with [id].
  void delete(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

/// Provider for user-created calendar events.
final userEventsProvider =
    NotifierProvider<UserEventsNotifier, List<CalendarUserEvent>>(
      UserEventsNotifier.new,
    );

// ── HomeScreen ────────────────────────────────────────────────────────────────

/// The main home tab screen.
///
/// Mounts an [ActivityTimeTracker] so that every second the home shell is
/// visible counts towards the daily active-time streak.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates [HomeScreen].
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final ActivityTimeTracker _tracker;

  @override
  void initState() {
    super.initState();
    _tracker = ActivityTimeTracker(ref);
    _tracker.init();
  }

  @override
  void dispose() {
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppTokens>() ?? AppTokens.defaults();

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

            _CareerTestCard(tokens: tokens)
                .animate()
                .fadeIn(delay: 180.ms, duration: 350.ms)
                .slideY(begin: 0.08, end: 0, delay: 180.ms, duration: 350.ms),

            SizedBox(height: tokens.gapXxl),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.tokens});
  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakCountProvider);
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
        if (streak > 0)
          Semantics(
            label: 'Серия: $streak ${_streakDayWord(streak)}',
            child: StreakBadge(days: streak),
          ),
      ],
    );
  }
}

// ── Streak Week ────────────────────────────────────────────────────────────────

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
    final litCount = days.where((d) => d.lit).length;

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
                litCount == 0
                    ? 'Начни свою серию!'
                    : 'Серия — $litCount ${_streakDayWord(litCount)}',
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
                          borderRadius:
                              BorderRadius.circular(tokens.radiusSm),
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(
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
                      : 'Ещё не завершён',
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
            '$litCount из 7 дней на этой неделе',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Interactive Calendar (events + tasks unified) ─────────────────────────────

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
    setState(
      () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1),
    );
  }

  void _nextMonth() {
    setState(
      () => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1),
    );
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

  void _openTaskSheet(BuildContext context, TodoItem? existing) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _TaskSheet(
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
    final allTodos = ref.watch(todoProvider);

    // Calendar grid cells
    final firstOfMonth = _viewMonth;
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

    // Events and todos for the selected date
    final selectedUserEvents = userEvents
        .where((e) => _isSameDay(e.date, _selectedDate))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final selectedMentorEvents = mentorEvents
        .where((e) => _isSameDay(e.scheduledAt, _selectedDate))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final selectedTodos = allTodos
        .where((t) => _isSameDay(t.date, _selectedDate))
        .toList();

    // Calendar dot indicators
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
    final todoDates = allTodos.map((t) => t.date).toSet();
    final allEventDates = {...eventDates, ...mentorEventDates, ...todoDates};

    final isEmpty = selectedUserEvents.isEmpty &&
        selectedMentorEvents.isEmpty &&
        selectedTodos.isEmpty;

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Month navigation ──────────────────────────────────────────────
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

          // ── Weekday labels ────────────────────────────────────────────────
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

          // ── Calendar grid ─────────────────────────────────────────────────
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: isToday
                                        ? AppColors.white
                                        : isSelected
                                        ? AppColors.primary
                                        : isCurrentMonth
                                        ? AppColors.ink
                                        : AppColors.inkSecondary
                                              .withValues(alpha: 0.5),
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

          // ── Day agenda divider ────────────────────────────────────────────
          Container(width: double.infinity, height: 1, color: AppColors.border),
          SizedBox(height: tokens.gapMd),

          // ── Agenda header ─────────────────────────────────────────────────
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

          // ── Agenda items: events + tasks ──────────────────────────────────
          if (isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.gapSm),
              child: Text(
                'Событий и задач нет.',
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
            for (final t in selectedTodos)
              _TodoRow(
                item: t,
                tokens: tokens,
                onToggle: () =>
                    ref.read(todoProvider.notifier).toggle(t.id),
                onTap: () => _openTaskSheet(context, t),
              ),
          ],

          SizedBox(height: tokens.gapMd),

          // ── Add buttons (side by side) ────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Добавить событие',
                  icon: const Icon(Icons.add, color: AppColors.white, size: 18),
                  onPressed: () => _openEventSheet(context, null),
                ),
              ),
              SizedBox(width: tokens.gapSm),
              Expanded(
                child: FeaturedButton(
                  label: 'Добавить задачу',
                  onPressed: () => _openTaskSheet(context, null),
                ),
              ),
            ],
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

// ── Agenda event row ──────────────────────────────────────────────────────────

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
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.inkSecondary),
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

// ── Todo row (used in calendar day agenda) ────────────────────────────────────

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
              child: AnimatedContainer(
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
      ref.read(userEventsProvider.notifier).add(
        title,
        desc.isEmpty ? null : desc,
        _scheduledAt,
      );
    } else {
      ref.read(userEventsProvider.notifier).update(
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
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: AppColors.errorRed,
                            ),
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

// ── Task Sheet ────────────────────────────────────────────────────────────────

class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({required this.initialDate, this.existing});
  final TodoItem? existing;

  /// Day to assign when creating a new task.
  final DateTime initialDate;

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
      ref.read(todoProvider.notifier).add(
        title,
        _descCtrl.text.trim(),
        widget.initialDate,
      );
    } else {
      ref.read(todoProvider.notifier).update(
        widget.existing!.id,
        title,
        _descCtrl.text.trim(),
      );
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
    final title = isNew ? 'Новая задача' : widget.existing!.title;

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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: AppColors.ink,
                        ),
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
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: AppColors.errorRed,
                            ),
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
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: AppColors.ink),
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
