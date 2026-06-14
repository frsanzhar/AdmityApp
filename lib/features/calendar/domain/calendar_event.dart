import 'package:flutter/foundation.dart';

/// The kind of a [CalendarEvent], used for marker color and icon.
enum CalendarEventKind {
  /// A scholarship / programme application deadline.
  deadline('Дедлайн'),

  /// An exam window (e.g. ЕНТ, SAT/IELTS sittings).
  exam('Экзамен'),

  /// A general admissions milestone (e.g. Common App opens).
  milestone('Этап');

  const CalendarEventKind(this.label);

  /// Russian label shown to the user.
  final String label;
}

/// A single dated item on the admissions calendar: a deadline, an exam window
/// or an admissions milestone. Dates for recurring annual events are stored as
/// «ориентир» (approximate) and must be verified at the source.
@immutable
class CalendarEvent {
  /// Creates a calendar event.
  const CalendarEvent({
    required this.date,
    required this.title,
    required this.kind,
    this.subtitle,
    this.sourceUrl,
    this.isApproximate = false,
  });

  /// The day the event falls on (time component ignored).
  final DateTime date;

  /// Short title (e.g. the programme or exam name).
  final String title;

  /// Optional supporting line (country, note, «ориентир»).
  final String? subtitle;

  /// What kind of event this is.
  final CalendarEventKind kind;

  /// Optional link to the official source.
  final String? sourceUrl;

  /// Whether the date is an approximate yearly guide rather than a confirmed
  /// deadline. Such events are labelled «ориентир» in the UI.
  final bool isApproximate;

  /// Whole days from [from] (date-only) to this event's date. Negative when the
  /// event is in the past.
  int daysFrom(DateTime from) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(date.year, date.month, date.day);
    return b.difference(a).inDays;
  }
}
