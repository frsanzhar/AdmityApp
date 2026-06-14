import 'package:flutter/foundation.dart';

/// A concrete, dated, achievable task that closes the gap between the
/// student's profile and their goal.
@immutable
class GapTask {
  const GapTask({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    this.linkedIntensiveSlug,
    this.isDone = false,
  });

  factory GapTask.fromJson(Map<String, dynamic> json) => GapTask(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        dueDate: json['due_date'] == null
            ? null
            : DateTime.parse(json['due_date'] as String),
        linkedIntensiveSlug: json['linked_intensive_slug'] as String?,
        isDone: (json['is_done'] as bool?) ?? false,
      );

  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final String? linkedIntensiveSlug;
  final bool isDone;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'linked_intensive_slug': linkedIntensiveSlug,
        'is_done': isDone,
      };

  GapTask copyWith({bool? isDone, DateTime? dueDate}) => GapTask(
        id: id,
        title: title,
        description: description,
        dueDate: dueDate ?? this.dueDate,
        linkedIntensiveSlug: linkedIntensiveSlug,
        isDone: isDone ?? this.isDone,
      );
}
