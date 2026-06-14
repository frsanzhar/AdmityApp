import 'package:admity/core/storage/local_store.dart';
import 'package:admity/features/calendar/data/calendar_seed.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current date, as a date-only [DateTime]. Overridable in tests.
final calendarNowProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// The student's own calendar events (created in-app or by Ералы), persisted
/// offline via [localStoreProvider]. Seed events are never modified here.
class UserCalendarEvents extends Notifier<List<CalendarEvent>> {
  static const _key = 'user_calendar_events';

  @override
  List<CalendarEvent> build() {
    final raw = ref.read(localStoreProvider).readList(_key);
    if (raw == null) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(CalendarEvent.fromJson)
        .toList();
  }

  /// Adds [event] and persists.
  void add(CalendarEvent event) {
    state = [...state, event];
    _persist();
  }

  /// Removes the user event with [id] and persists.
  void removeById(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  void _persist() => ref
      .read(localStoreProvider)
      .put(_key, state.map((e) => e.toJson()).toList());
}

/// The student's own (mutable) calendar events.
final userCalendarEventsProvider =
    NotifierProvider<UserCalendarEvents, List<CalendarEvent>>(
  UserCalendarEvents.new,
);

/// All calendar events — bundled seed plus the student's own — sorted ascending
/// by date.
final calendarEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final events = [
    ...kCalendarSeed,
    ...ref.watch(userCalendarEventsProvider),
  ]..sort((a, b) => a.date.compareTo(b.date));
  return events;
});

/// Upcoming events (today or later), sorted by date — for the home card and
/// the agenda list.
final upcomingEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final now = ref.watch(calendarNowProvider);
  return ref
      .watch(calendarEventsProvider)
      .where((e) => e.daysFrom(now) >= 0)
      .toList();
});

/// Events grouped by their date-only key — for the month-view markers.
final eventsByDayProvider = Provider<Map<DateTime, List<CalendarEvent>>>((ref) {
  final map = <DateTime, List<CalendarEvent>>{};
  for (final e in ref.watch(calendarEventsProvider)) {
    final key = DateTime(e.date.year, e.date.month, e.date.day);
    (map[key] ??= []).add(e);
  }
  return map;
});
