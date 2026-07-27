/// A single in-memory chat message used for display and AI context.
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, String> toMap() => {
        'role': role,
        'content': content,
      };
}
