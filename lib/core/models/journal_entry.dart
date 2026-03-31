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

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    this.moodIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntry.create({
    required String title,
    required String content,
    double? moodIndex,
  }) {
    final now = DateTime.now();
    return JournalEntry(
      id: const Uuid().v4(),
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
  }) {
    return JournalEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      moodIndex: moodIndex ?? this.moodIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
