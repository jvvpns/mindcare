import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../mood_tracking/providers/mood_provider.dart';

class DailyProgress {
  final DateTime date;
  final int? stressRating;
  final int? moodIndex;

  DailyProgress({required this.date, this.stressRating, this.moodIndex});
}

// Emits the progress data for the last 7 days including today.
final weeklyProgressProvider = Provider<List<DailyProgress>>((ref) {
  final userId = ref.watch(authProvider).user?.id ?? '';
  if (userId.isEmpty) return [];

  // Watch mood to potentially trigger rebuilds if logged today
  ref.watch(todayMoodProvider);

  final stressLogs = HiveService.stressBox.values.where((log) => log.userId == userId).toList();
  final moodLogs = HiveService.moodBox.values.where((log) => log.userId == userId).toList();

  final today = DateTime.now();
  final last7Days = List.generate(7, (index) {
    // Going backwards from 6 days ago up to today
    final delta = 6 - index;
    return DateTime(today.year, today.month, today.day).subtract(Duration(days: delta));
  });

  return last7Days.map((date) {
    // Filter to specific date
    final dailyStress = stressLogs.where((l) =>
        l.loggedAt.year == date.year &&
        l.loggedAt.month == date.month &&
        l.loggedAt.day == date.day);
    
    final latestStress = dailyStress.isNotEmpty
        ? dailyStress.reduce((a, b) => a.loggedAt.isAfter(b.loggedAt) ? a : b).rating
        : null;

    final dailyMood = moodLogs.where((l) =>
        l.loggedAt.year == date.year &&
        l.loggedAt.month == date.month &&
        l.loggedAt.day == date.day);
    
    final latestMood = dailyMood.isNotEmpty
        ? dailyMood.reduce((a, b) => a.loggedAt.isAfter(b.loggedAt) ? a : b).moodIndex
        : null;

    return DailyProgress(
      date: date,
      stressRating: latestStress,
      moodIndex: latestMood,
    );
  }).toList();
});
