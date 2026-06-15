import 'package:flutter/foundation.dart';

/// Who authored a chat message.
enum ChatRole { user, eraly }

/// The specialized sub-agents Eraly coordinates (shown as context chips).
enum SubAgent {
  profileOrientation('Профориентатор'),
  chancingKz('Чансинг-КЗ'),
  chancingWorld('Чансинг-Мир'),
  scholarshipScout('Скаут-стипендий'),
  intensiveCoach('Тренер-интенсивов'),
  essayEditor('Редактор эссе');

  const SubAgent(this.label);

  final String label;
}

/// A single chat message.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.pending = false,
  });

  /// Rebuilds a message from cached/synced JSON; tolerant of unknown roles and
  /// missing timestamps so legacy/partial data never throws.
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String? ?? '',
        role: ChatRole.values.firstWhere(
          (r) => r.name == json['role'],
          orElse: () => ChatRole.eraly,
        ),
        content: json['content'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String id;
  final ChatRole role;
  final String content;
  final DateTime createdAt;

  /// True while Eraly's reply is streaming/awaited.
  final bool pending;

  ChatMessage copyWith({String? content, bool? pending}) => ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        pending: pending ?? this.pending,
      );

  /// Serializes for the local cache / sync. The transient [pending] flag is
  /// never persisted (an in-flight empty bubble must not be cached or uploaded).
  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
