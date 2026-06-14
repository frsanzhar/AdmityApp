import 'dart:convert';

import 'package:admity/features/calendar/domain/calendar_event.dart';

/// One calendar mutation requested by Ералы inside a ```calendar fenced block.
class CalendarAiAction {
  /// Creates a parsed calendar action.
  const CalendarAiAction({
    required this.op,
    required this.title,
    required this.kind,
    this.date,
    this.note,
  });

  /// Either `add` or `remove`.
  final String op;

  /// Human title of the event (used to add, or to match for removal).
  final String title;

  /// The event kind (defaults to deadline when unspecified).
  final CalendarEventKind kind;

  /// The event date for `add` (null when Ералы didn't give one).
  final DateTime? date;

  /// Optional note/subtitle.
  final String? note;
}

/// The result of parsing an Ералы reply: the human-facing [text] with any
/// machine blocks stripped out, plus the [actions] to apply to the calendar.
class ParsedEralyReply {
  /// Creates a parsed reply.
  const ParsedEralyReply({required this.text, required this.actions});

  /// The reply text shown to the student (```calendar blocks removed).
  final String text;

  /// Calendar mutations Ералы requested (possibly empty).
  final List<CalendarAiAction> actions;
}

final _calendarBlock = RegExp(r'```calendar\s*(.*?)```', dotAll: true);

/// Extracts ```calendar JSON blocks from [reply], returning the cleaned text
/// and the parsed actions. Malformed blocks are ignored (never throws), so a
/// confused model can never break the chat.
ParsedEralyReply parseEralyReply(String reply) {
  final matches = _calendarBlock.allMatches(reply).toList();
  if (matches.isEmpty) {
    return ParsedEralyReply(text: reply.trim(), actions: const []);
  }

  final actions = <CalendarAiAction>[];
  for (final m in matches) {
    final payload = m.group(1)?.trim() ?? '';
    try {
      final decoded = jsonDecode(payload);
      final items = decoded is List ? decoded : [decoded];
      for (final item in items) {
        if (item is! Map) continue;
        final op = (item['op'] ?? '').toString().toLowerCase().trim();
        final title = (item['title'] ?? '').toString().trim();
        if (title.isEmpty || (op != 'add' && op != 'remove')) continue;
        final rawDate = item['date'];
        final date = rawDate is String ? DateTime.tryParse(rawDate) : null;
        final kind = CalendarEventKind.values.firstWhere(
          (k) => k.name == (item['kind'] ?? '').toString().trim(),
          orElse: () => CalendarEventKind.deadline,
        );
        final note = (item['note'] as String?)?.trim();
        actions.add(
          CalendarAiAction(
            op: op,
            title: title,
            kind: kind,
            date: date,
            note: (note == null || note.isEmpty) ? null : note,
          ),
        );
      }
    } on Object {
      // Ignore malformed blocks.
    }
  }

  final cleaned = reply.replaceAll(_calendarBlock, '').trim();
  return ParsedEralyReply(text: cleaned, actions: actions);
}
