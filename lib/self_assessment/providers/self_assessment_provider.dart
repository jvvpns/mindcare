import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilway/core/services/intelligence_service.dart';
import 'package:hilway/core/services/hive_service.dart';
import 'package:hilway/core/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:hilway/core/models/assessment_result.dart';
import '../../auth/providers/auth_provider.dart';

// State holding current answers during the assessment
class AssessmentAnswers {
  final double sleepHours;
  final double stressLevel;
  final double duties; // Number of high-intensity shifts
  final double mealsSkipped;
  final double dreadLevel; // 1-5
  final double compassionLevel; // 1-5
  final double physicalTension; // 1-5

  AssessmentAnswers({
    this.sleepHours = 7.0,
    this.stressLevel = 3.0,
    this.duties = 0.0,
    this.mealsSkipped = 0.0,
    this.dreadLevel = 1.0,
    this.compassionLevel = 5.0,
    this.physicalTension = 1.0,
  });

  AssessmentAnswers copyWith({
    double? sleepHours,
    double? stressLevel,
    double? duties,
    double? mealsSkipped,
    double? dreadLevel,
    double? compassionLevel,
    double? physicalTension,
  }) {
    return AssessmentAnswers(
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      duties: duties ?? this.duties,
      mealsSkipped: mealsSkipped ?? this.mealsSkipped,
      dreadLevel: dreadLevel ?? this.dreadLevel,
      compassionLevel: compassionLevel ?? this.compassionLevel,
      physicalTension: physicalTension ?? this.physicalTension,
    );
  }
}

final assessmentAnswersProvider = StateProvider<AssessmentAnswers>((ref) {
  return AssessmentAnswers();
});

class AssessmentStateNotifier
    extends StateNotifier<AsyncValue<AssessmentResult?>> {
  final Ref _ref;
  AssessmentStateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> evaluateAndSave(AssessmentAnswers answers) async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    state = const AsyncValue.loading();
    try {
      final analysis = await IntelligenceService.instance.predictBurnout(
        sleepHours: answers.sleepHours,
        moodTrend: answers.stressLevel / 5.0, // Normalize to 0-1
        taskLoad: answers.duties / 5.0, // Normalize to 0-1
        mealSkipRate: answers.mealsSkipped / 4.0, // Normalize to 0-1
      );

      final levelStr = analysis['level'] as String;
      final confidence = (analysis['confidence'] as num).toDouble();
      final probabilities = (analysis['probabilities'] as List).cast<double>();

      // ── Emotional Vitals Adjustment ───────────────────────────
      // Calculate a qualitative burden score (Max: 15)
      // Compassion is inverted (low compassion = high burden)
      final emotionalBurden =
          answers.dreadLevel +
          (6 - answers.compassionLevel) +
          answers.physicalTension;

      final interpretation =
          '${levelStr[0].toUpperCase()}${levelStr.substring(1)} Burnout Risk (Clinically Adjusted)';

      final result = AssessmentResult(
        id: const Uuid().v4(),
        userId: user.id,
        type: 'burnout_prediction',
        totalScore: confidence,
        answers: {
          'sleepHours': answers.sleepHours,
          'stressLevel': answers.stressLevel,
          'duties': answers.duties,
          'mealsSkipped': answers.mealsSkipped,
          'dreadLevel': answers.dreadLevel,
          'compassionLevel': answers.compassionLevel,
          'physicalTension': answers.physicalTension,
        },
        interpretation: interpretation,
        takenAt: DateTime.now(),
      );

      // Save to Hive
      await HiveService.assessmentBox.add(result);

      // Queue offline-first background sync
      SyncService.instance.queueUpsert(
        table: 'assessment_results',
        id: result.id,
        data: result.toMap(),
      );

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final assessmentStateProvider =
    StateNotifierProvider<
      AssessmentStateNotifier,
      AsyncValue<AssessmentResult?>
    >((ref) {
      ref.watch(authProvider); // Rebuild on auth change
      return AssessmentStateNotifier(ref);
    });

/// Stream that watches the Hive box for any changes (add, update, delete)
final assessmentBoxWatcherProvider = StreamProvider<void>((ref) {
  return HiveService.assessmentBox.watch();
});

/// Returns the most recent burnout assessment result.
final lastAssessmentProvider = Provider<AssessmentResult?>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return null;

  // Watch for changes in the assessment box to trigger reactivity
  ref.watch(assessmentBoxWatcherProvider);

  final box = HiveService.assessmentBox;
  if (box.isEmpty) return null;

  // Get all predictions for THIS user and sort by date
  final predictions = box.values
      .where((r) => r.userId == user.id && r.type == 'burnout_prediction')
      .toList();

  if (predictions.isEmpty) return null;

  predictions.sort((a, b) => b.takenAt.compareTo(a.takenAt));
  return predictions.first;
});

/// Calculates the remaining cooldown time (Resets at Midnight).
final burnoutCooldownProvider = StreamProvider<Duration>((ref) async* {
  final lastResult = ref.watch(lastAssessmentProvider);
  if (lastResult == null) {
    yield Duration.zero;
    return;
  }

  while (true) {
    final now = DateTime.now();
    final isSameDay =
        lastResult.takenAt.year == now.year &&
        lastResult.takenAt.month == now.month &&
        lastResult.takenAt.day == now.day;

    if (!isSameDay) {
      yield Duration.zero;
      break;
    }

    // Calculate time until midnight
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final remaining = midnight.difference(now);

    yield remaining;
    await Future.delayed(const Duration(minutes: 1));
  }
});
