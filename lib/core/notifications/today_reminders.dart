/// Today-reminder scheduler.
///
/// Reads [todoProvider] and [userEventsProvider] from
/// `lib/features/home/presentation/home_screen.dart` (the existing providers —
/// this file does NOT rewrite home_screen.dart) and fires local notifications
/// for items that are due today:
///
/// * Calendar events whose [CalendarUserEvent.scheduledAt] is within the next
///   15 minutes get a [NotificationsService.showNow] immediately.
/// * Calendar events later today get a [NotificationsService.scheduleDailyReminder]
///   at their exact hour (best-effort; repeat-daily semantics means the system
///   will keep rescheduling them daily, so the Integrate step can call
///   `NotificationsService.cancelAll` + [scheduleTodayReminders] each morning if desired).
/// * Incomplete [TodoItem]s get a single aggregated "you have N tasks" nudge
///   as a [NotificationsService.showNow] if [TodoItem]s are pending.
///
/// ## Usage (Integrate agent wires this — do NOT modify home_screen.dart)
///
/// ```dart
/// // In a Riverpod listener or inside initState of the shell widget:
/// ref.listen(todoProvider, (_, todos) async {
///   await scheduleTodayReminders(
///     todos: todos,
///     events: ref.read(userEventsProvider),
///   );
/// });
/// ```
///
/// Or call once at app launch after providers are ready:
/// ```dart
/// await scheduleTodayReminders(
///   todos: ref.read(todoProvider),
///   events: ref.read(userEventsProvider),
/// );
/// ```
library;

import 'package:admity/core/notifications/notifications_service.dart';
import 'package:admity/features/home/presentation/home_screen.dart';
import 'package:flutter/foundation.dart';

// ── Notification ID ranges ────────────────────────────────────────────────────

// IDs 2000–2099 are reserved for calendar event reminders.
// ID  2100       is reserved for the aggregated todo nudge.
// (Study reminder lives at 1001 — see notifications_providers.dart.)

const _calendarBaseId = 2000;
const _todoNudgeId = 2100;

// ── Public API ────────────────────────────────────────────────────────────────

/// Schedules real notifications for today's todos and calendar events.
///
/// Safe to call multiple times — existing IDs in the [_calendarBaseId] range
/// are overwritten.  Failures are swallowed (offline-first).
///
/// [now] defaults to [DateTime.now] and is injectable for testing.
Future<void> scheduleTodayReminders({
  required List<TodoItem> todos,
  required List<CalendarUserEvent> events,
  DateTime? now,
}) async {
  final today = now ?? DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // ── 1. Calendar events for today ──────────────────────────────────────────
  final todayEvents = events
      .where((e) => _isSameDay(e.date, todayDate))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  for (var i = 0; i < todayEvents.length; i++) {
    final event = todayEvents[i];
    final id = _calendarBaseId + i;
    final diff = event.scheduledAt.difference(today);

    if (diff.isNegative) {
      // Event already passed — skip.
      continue;
    }

    if (diff.inMinutes <= 15) {
      // Due now or very soon — show immediately.
      await NotificationsService.showNow(
        id: id,
        title: 'Сейчас: ${event.title}',
        body: event.description ?? 'Событие начинается!',
      );
      debugPrint(
        '[TodayReminders] showNow id=$id title="${event.title}"',
      );
    } else {
      // Due later today — schedule at that hour.
      await NotificationsService.scheduleDailyReminder(
        id: id,
        hour: event.scheduledAt.hour,
        minute: event.scheduledAt.minute,
        title: 'Скоро: ${event.title}',
        body: event.description ?? 'Запланировано на сегодня.',
      );
      debugPrint(
        '[TodayReminders] scheduled id=$id at '
        '${event.scheduledAt.hour}:${event.scheduledAt.minute} '
        '"${event.title}"',
      );
    }
  }

  // ── 2. Aggregated todo nudge ───────────────────────────────────────────────
  final pendingTodos = todos.where((t) => !t.done).toList();
  if (pendingTodos.isNotEmpty) {
    final count = pendingTodos.length;
    final label = count == 1 ? 'задача' : (count < 5 ? 'задачи' : 'задач');
    await NotificationsService.showNow(
      id: _todoNudgeId,
      title: 'У тебя $count $label на сегодня',
      body: pendingTodos.first.title,
    );
    debugPrint(
      '[TodayReminders] todo nudge: $count pending, '
      'first="${pendingTodos.first.title}"',
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
