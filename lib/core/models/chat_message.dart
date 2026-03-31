import 'package:hive/hive.dart';

part 'chat_message.g.dart';

enum MessageRole { user, assistant }

@HiveType(typeId: 2)
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String role; // 'user' or 'assistant'

  @HiveField(3)
  final DateTime sentAt;

  @HiveField(4)
  final bool isCrisisDetected;

  @HiveField(5)
  final String? sessionId;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.sentAt,
    this.isCrisisDetected = false,
    this.sessionId,
  });

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool get isUser      => role == 'user';
  bool get isAssistant => role == 'assistant';

  MessageRole get messageRole =>
      role == 'user' ? MessageRole.user : MessageRole.assistant;

  // ── Serialization ─────────────────────────────────────────────────────────
  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    id:               map['id'] as String,
    content:          map['content'] as String,
    role:             map['role'] as String,
    sentAt:           DateTime.parse(map['sent_at'] as String),
    isCrisisDetected: map['is_crisis_detected'] as bool? ?? false,
    sessionId:        map['session_id'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id':                 id,
    'content':            content,
    'role':               role,
    'sent_at':            sentAt.toIso8601String(),
    'is_crisis_detected': isCrisisDetected,
    'session_id':         sessionId,
  };

  // ── Gemini API Format ─────────────────────────────────────────────────────
  Map<String, dynamic> toGeminiPart() => {
    'role': role == 'assistant' ? 'model' : 'user',
    'parts': [
      {'text': content}
    ],
  };

  ChatMessage copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? sentAt,
    bool? isCrisisDetected,
    String? sessionId,
  }) =>
      ChatMessage(
        id:               id ?? this.id,
        content:          content ?? this.content,
        role:             role ?? this.role,
        sentAt:           sentAt ?? this.sentAt,
        isCrisisDetected: isCrisisDetected ?? this.isCrisisDetected,
        sessionId:        sessionId ?? this.sessionId,
      );

  @override
  String toString() =>
      'ChatMessage(role: $role, sentAt: $sentAt, crisis: $isCrisisDetected)';
}