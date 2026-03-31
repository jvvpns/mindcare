import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hilway/core/constants/app_colors.dart';
import 'package:hilway/core/constants/app_text_styles.dart';
import 'package:hilway/self_assessment/providers/self_assessment_provider.dart';

class BurnoutAssessmentScreen extends ConsumerWidget {
  const BurnoutAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(assessmentAnswersProvider);
    final evaluationState = ref.watch(assessmentStateProvider);

    // Watch evaluation state to navigate when complete
    ref.listen(assessmentStateProvider, (previous, next) {
      if (next.hasValue && next.value != null && !next.isLoading) {
        context.push('/burnout-result');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Burnout Assessment', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: evaluationState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Let\'s check in on how you\'re doing.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Question 1: Sleep
                  _buildQuestionLabel('1. Average sleep hours per night this week?'),
                  Slider(
                    value: answers.sleepHours,
                    min: 0,
                    max: 12,
                    divisions: 12,
                    label: "${answers.sleepHours.toInt()} hours",
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      ref.read(assessmentAnswersProvider.notifier).state =
                          answers.copyWith(sleepHours: val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Question 2: Stress
                  _buildQuestionLabel('2. Rate your average stress level (1 = Low, 5 = Extreme)'),
                  Slider(
                    value: answers.stressLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: "${answers.stressLevel.toInt()}",
                    activeColor: AppColors.secondary,
                    onChanged: (val) {
                      ref.read(assessmentAnswersProvider.notifier).state =
                          answers.copyWith(stressLevel: val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Question 3: Clinical Duties
                  _buildQuestionLabel('3. How many days of clinical duty did you have this week?'),
                  Slider(
                    value: answers.duties,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: "${answers.duties.toInt()}",
                    activeColor: AppColors.error,
                    onChanged: (val) {
                      ref.read(assessmentAnswersProvider.notifier).state =
                          answers.copyWith(duties: val);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Question 4: Meals
                  _buildQuestionLabel('4. On average, how many meals do you skip a day?'),
                  Slider(
                    value: answers.mealsSkipped,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    label: "${answers.mealsSkipped.toInt()}",
                    activeColor: Colors.orange,
                    onChanged: (val) {
                      ref.read(assessmentAnswersProvider.notifier).state =
                          answers.copyWith(mealsSkipped: val);
                    },
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(assessmentStateProvider.notifier).evaluateAndSave(answers);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'Analyze Risk',
                        style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildQuestionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        text,
        style: AppTextStyles.buttonLarge.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
