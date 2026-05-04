class ChatMessage {
  final String? messageId;
  final String role; // 'user' | 'bot'
  final String content;
  final List<ChatSource> sources;
  final DateTime createdAt;

  const ChatMessage({
    this.messageId,
    required this.role,
    required this.content,
    this.sources = const [],
    required this.createdAt,
  });

  bool get isBot => role == 'bot';

  factory ChatMessage.user(String content) => ChatMessage(
        role: 'user',
        content: content,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.bot(String content, {List<ChatSource> sources = const []}) =>
      ChatMessage(
        role: 'bot',
        content: content,
        sources: sources,
        createdAt: DateTime.now(),
      );

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        messageId: json['message_id'] as String?,
        role: json['role'] as String,
        content: json['content'] as String,
        sources: (json['sources'] as List<dynamic>? ?? [])
            .map((s) => ChatSource.fromJson(s as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatSource {
  final String title;
  final String section;

  const ChatSource({required this.title, required this.section});

  factory ChatSource.fromJson(Map<String, dynamic> json) => ChatSource(
        title: json['title'] as String,
        section: json['section'] as String,
      );
}
