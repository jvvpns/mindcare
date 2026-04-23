import 'package:hive/hive.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 6)
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4, defaultValue: 'local')
  final String userId;

  ChatSession({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  ChatSession copyWith({
    String? title,
    DateTime? updatedAt,
    String? userId,
  }) =>
      ChatSession(
        id: id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  // ── Supabase ──────────────────────────────────────────────────────────────
  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'local',
      title: map['title'] as String,
      createdAt: DateTime.parse(map['started_at'] as String),
      updatedAt: DateTime.parse(map['last_message_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'started_at': createdAt.toIso8601String(),
      'last_message_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'ChatSession(id: $id, title: $title, createdAt: $createdAt)';
}
