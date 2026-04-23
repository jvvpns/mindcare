import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 5)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final double? moodIndex; // Optional: Link to a mood at the time of writing

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6, defaultValue: 'local')
  final String userId;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.moodIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.create({
    required String userId,
    required String title,
    required String content,
    double? moodIndex,
  }) {
    final now = DateTime.now();
    return JournalEntry(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      content: content,
      moodIndex: moodIndex,
      createdAt: now,
      updatedAt: now,
    );
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    double? moodIndex,
    DateTime? updatedAt,
    String? userId,
  }) {
    return JournalEntry(
      id: id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      moodIndex: moodIndex ?? this.moodIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ── Supabase ──────────────────────────────────────────────────────────────
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'local',
      title: map['title'] as String,
      content: map['content'] as String,
      moodIndex: map['mood_index'] != null
          ? (map['mood_index'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_index': moodIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
