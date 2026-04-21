import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';

part 'shift_task.g.dart';

@HiveType(typeId: AppConstants.hiveTypeShiftTask)
class ShiftTask extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String userId;

  ShiftTask({
    String? id,
    required this.title,
    required this.category,
    this.isDone = false,
    DateTime? createdAt,
    this.userId = 'local',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ShiftTask copyWith({
    String? title,
    String? category,
    bool? isDone,
    String? userId,
  }) {
    return ShiftTask(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt,
      userId: userId ?? this.userId,
    );
  }

  // ── Supabase ──────────────────────────────────────────────────────────────
  factory ShiftTask.fromMap(Map<String, dynamic> map) => ShiftTask(
    id:        map['id'] as String,
    userId:    map['user_id'] as String? ?? 'local',
    title:     map['title'] as String,
    category:  map['category'] as String,
    isDone:    map['is_done'] as bool? ?? false,
    createdAt: DateTime.parse(map['created_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    'id':         id,
    'user_id':    userId,
    'title':      title,
    'category':   category,
    'is_done':    isDone,
    'created_at': createdAt.toIso8601String(),
  };
}
