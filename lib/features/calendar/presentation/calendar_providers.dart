import 'package:admity/features/calendar/data/calendar_seed.dart';
import 'package:admity/features/calendar/domain/calendar_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current date, as a date-only [DateTime]. Overridable in tests.
final calendarNowProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// All seed calendar events, sorted ascending by date.
final calendarEventsProvider = Provider<List<CalendarEvent>>((ref) {
  final events = [...kCalendarSeed]
    ..sort((a, b) => a.date.compareTo(b.date));
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
