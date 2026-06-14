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
}
