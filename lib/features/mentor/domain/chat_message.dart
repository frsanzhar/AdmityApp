/// A single message in the Ералы chat thread.
///
/// [role] is either 'user' or 'assistant'.
/// [text] is the display text.
/// [id] is a locally-unique identifier for list keying.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });

  final String id;

  /// 'user' or 'assistant'.
  final String role;

  final String text;
  final DateTime timestamp;

  bool get isUser => role == 'user';

  ChatMessage copyWith({String? text}) {
    return ChatMessage(
      id: id,
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
    );
  }
}
