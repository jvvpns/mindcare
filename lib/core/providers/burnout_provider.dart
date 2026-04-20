import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/burnout_service.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../clinical_duty/providers/shift_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../dashboard/providers/refuel_provider.dart';

/// Provider for the calculated burnout risk using the TFLite model.
final burnoutRiskProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final sleepHours = ref.watch(sleepDurationProvider);
  final todayMood = ref.watch(todayMoodProvider);
  final shiftTasks = ref.watch(shiftProvider);
  final refuelLog = ref.watch(refuelProvider);
  
  // Mapping mood to stress level (1.0 - 5.0)
  double stressLevel = 3.0; // Default Neutral
  if (todayMood != null) {
    final mood = todayMood.moodLabel.toLowerCase();
    if (mood == 'calm') stressLevel = 1.0;
    else if (mood == 'happy') stressLevel = 2.0;
    else if (mood == 'energetic') stressLevel = 2.0;
    else if (mood == 'anxious') stressLevel = 4.0;
    else if (mood == 'sad') stressLevel = 4.0;
    else if (mood == 'depressed') stressLevel = 5.0;
  }

  // Clinical duties (normalized 0.0 - 5.0)
  // We'll count active tasks and cap it at 5 for the model input
  double dutyCount = shiftTasks.where((t) => !t.isDone).length.toDouble();
  if (dutyCount > 5.0) dutyCount = 5.0;

  // Meals skipped (Actual data from RefuelProvider)
  double mealsSkipped = refuelLog?.missedMeals.toDouble() ?? 0.0;

  try {
    final result = await BurnoutService.instance.evaluateRisk(
      sleepHours: sleepHours > 0 ? sleepHours : 7.0, // Default to 7h if no sync
      stressLevel: stressLevel,
      duties: dutyCount,
      mealsSkipped: mealsSkipped,
    );
    return result;
  } catch (e) {
    return {
      'level': BurnoutLevel.low,
      'confidence': 0.0,
      'error': e.toString(),
    };
  }
});
