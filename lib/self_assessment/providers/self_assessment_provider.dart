import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hilway/core/services/burnout_service.dart';
import 'package:hilway/core/services/hive_service.dart';
import 'package:hilway/core/models/assessment_result.dart';

// State holding current answers during the assessment
class AssessmentAnswers {
  final double sleepHours;
  final double stressLevel;
  final double duties;
  final double mealsSkipped;

  AssessmentAnswers({
    this.sleepHours = 7.0,
    this.stressLevel = 3.0,
    this.duties = 0.0,
    this.mealsSkipped = 0.0,
  });

  AssessmentAnswers copyWith({
    double? sleepHours,
    double? stressLevel,
    double? duties,
    double? mealsSkipped,
  }) {
    return AssessmentAnswers(
      sleepHours: sleepHours ?? this.sleepHours,
      stressLevel: stressLevel ?? this.stressLevel,
      duties: duties ?? this.duties,
      mealsSkipped: mealsSkipped ?? this.mealsSkipped,
    );
  }
}

final assessmentAnswersProvider = StateProvider<AssessmentAnswers>((ref) {
  return AssessmentAnswers();
});

class AssessmentStateNotifier extends StateNotifier<AsyncValue<AssessmentResult?>> {
  AssessmentStateNotifier() : super(const AsyncValue.data(null));

  Future<void> evaluateAndSave(AssessmentAnswers answers) async {
    state = const AsyncValue.loading();
    try {
      final analysis = await BurnoutService.instance.evaluateRisk(
        sleepHours: answers.sleepHours,
        stressLevel: answers.stressLevel,
        duties: answers.duties,
        mealsSkipped: answers.mealsSkipped,
      );

      final levelStr = (analysis['level'] as BurnoutLevel).toString().split('.').last; // low, medium, high
      final interpretation = '${levelStr[0].toUpperCase()}${levelStr.substring(1)} Burnout Risk';

      final result = AssessmentResult(
        id:             DateTime.now().millisecondsSinceEpoch.toString(),
        userId:         '', // populated if user is logged in — optional for local-only
        type:           'burnout_prediction',
        totalScore:     (analysis['confidence'] as double) * 100,
        answers:        {
          'sleepHours':   answers.sleepHours,
          'stressLevel':  answers.stressLevel,
          'duties':       answers.duties,
          'mealsSkipped': answers.mealsSkipped,
        },
        interpretation: interpretation,
        takenAt:        DateTime.now(),
      );

      // Save to Hive
      await HiveService.assessmentBox.add(result);
      
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final assessmentStateProvider = StateNotifierProvider<AssessmentStateNotifier, AsyncValue<AssessmentResult?>>((ref) {
  return AssessmentStateNotifier();
});
