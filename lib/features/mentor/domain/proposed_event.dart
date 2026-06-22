/// An event proposed by Ералы before the user has reviewed/confirmed it.
///
/// Events cannot be saved to the calendar until [reviewed] is true
/// — the user must pass through the «Проверить все мероприятия» screen first.
class ProposedEvent {
  const ProposedEvent({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.description = '',
    this.reviewed = false,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String description;

  /// True once the user has completed the review step.
  /// Events MUST NOT be committed to the calendar when [reviewed] is false.
  final bool reviewed;

  ProposedEvent copyWith({
    String? title,
    DateTime? scheduledAt,
    String? description,
    bool? reviewed,
  }) {
    return ProposedEvent(
      id: id,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      description: description ?? this.description,
      reviewed: reviewed ?? this.reviewed,
    );
  }
}

/// A saved calendar event (after the review gate has been passed).
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.description = '',
  });

  /// Construct from a reviewed [ProposedEvent].
  factory CalendarEvent.fromProposed(ProposedEvent e) {
    assert(e.reviewed, 'Cannot commit an un-reviewed event to the calendar');
    return CalendarEvent(
      id: e.id,
      title: e.title,
      scheduledAt: e.scheduledAt,
      description: e.description,
    );
  }

  final String id;
  final String title;
  final DateTime scheduledAt;
  final String description;
}
