import 'package:hive/hive.dart';

part 'refuel_log.g.dart';

@HiveType(typeId: 9) // Assign a unique typeId
class RefuelLog extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final bool hasBreakfast;

  @HiveField(2)
  final bool hasLunch;

  @HiveField(3)
  final bool hasDinner;

  @HiveField(4, defaultValue: '')
  final String id;

  @HiveField(5, defaultValue: 'local')
  final String userId;

  RefuelLog({
    required this.id,
    required this.date,
    this.hasBreakfast = false,
    this.hasLunch = false,
    this.hasDinner = false,
    this.userId = 'local',
  });

  RefuelLog copyWith({
    String? id,
    DateTime? date,
    bool? hasBreakfast,
    bool? hasLunch,
    bool? hasDinner,
  }) {
    return RefuelLog(
      id: id ?? this.id,
      date: date ?? this.date,
      hasBreakfast: hasBreakfast ?? this.hasBreakfast,
      hasLunch: hasLunch ?? this.hasLunch,
      hasDinner: hasDinner ?? this.hasDinner,
      userId: userId ?? this.userId,
    );
  }

  // ── Supabase ──────────────────────────────────────────────────────────────
  factory RefuelLog.fromMap(Map<String, dynamic> map) {
    return RefuelLog(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? 'local',
      date: DateTime.parse(map['logged_at'] as String),
      hasBreakfast: map['has_breakfast'] as bool? ?? false,
      hasLunch: map['has_lunch'] as bool? ?? false,
      hasDinner: map['has_dinner'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'logged_at': date.toIso8601String(),
      'has_breakfast': hasBreakfast,
      'has_lunch': hasLunch,
      'has_dinner': hasDinner,
    };
  }

  int get missedMeals {
    final now = DateTime.now();
    // Only count as missed if the time has passed AND it's not logged
    int count = 0;

    // Breakfast: 7:00 AM
    if (now.hour >= 7 && !hasBreakfast) count++;

    // Lunch: 11:30 AM
    if ((now.hour > 11 || (now.hour == 11 && now.minute >= 30)) && !hasLunch)
      count++;

    // Dinner: 7:00 PM (19:00)
    if (now.hour >= 19 && !hasDinner) count++;

    return count;
  }
}
