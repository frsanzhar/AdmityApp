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
    this.id,
    this.userCreated = false,
  });

  /// Rebuilds a user-created event from stored JSON. Invalid values degrade
  /// gracefully so a hand-edited store never throws inside a Notifier build.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String?,
        title: (json['title'] as String?) ?? 'Событие',
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime(2000),
        kind: CalendarEventKind.values.firstWhere(
          (k) => k.name == json['kind'],
          orElse: () => CalendarEventKind.milestone,
        ),
        subtitle: json['subtitle'] as String?,
        sourceUrl: json['source_url'] as String?,
        isApproximate: (json['is_approximate'] as bool?) ?? false,
        userCreated: (json['user_created'] as bool?) ?? true,
      );

  /// Stable id, set for user-created events so they can be deleted. Null for
  /// bundled seed events.
  final String? id;

  /// Whether the student created this event (vs a bundled seed). Only
  /// user-created events can be deleted in the UI.
  final bool userCreated;

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

  /// Serializes a user-created event for the local store.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'kind': kind.name,
        'subtitle': subtitle,
        'source_url': sourceUrl,
        'is_approximate': isApproximate,
        'user_created': true,
      };

  /// Whole days from [from] (date-only) to this event's date. Negative when the
  /// event is in the past.
  int daysFrom(DateTime from) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(date.year, date.month, date.day);
    return b.difference(a).inDays;
  }
}
