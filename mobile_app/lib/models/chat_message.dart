class ChatSource {
  final String title;
  final String section;
  const ChatSource({required this.title, required this.section});

  factory ChatSource.fromMap(Map<String, dynamic> map) => ChatSource(
    title: map['title'] as String? ?? '',
    section: map['section'] as String? ?? '',
  );
}

enum ChatModule { labourRights, negotiationCoach, contractAnalysis }

extension ChatModuleExt on ChatModule {
  String get apiValue {
    switch (this) {
      case ChatModule.labourRights: return 'labour_rights';
      case ChatModule.negotiationCoach: return 'negotiation_coach';
      case ChatModule.contractAnalysis: return 'contract_review';
    }
  }
}

class ChatMessage {
  final String messageId;
  final String role;
  final String content;
  final List<ChatSource> sources;
  final DateTime? createdAt;
  final String? attachmentName;

  const ChatMessage({
    required this.messageId,
    required this.role,
    required this.content,
    this.sources = const [],
    this.createdAt,
    this.attachmentName,
  });

  bool get isUser => role == 'user';

  factory ChatMessage.fromApiResponse(Map<String, dynamic> json, String messageId) => ChatMessage(
    messageId: messageId,
    role: 'bot',
    content: json['answer'] as String? ?? '',
    sources: ((json['sources'] as List<dynamic>?) ?? [])
        .map((s) => ChatSource.fromMap(s as Map<String, dynamic>))
        .toList(),
  );
}
