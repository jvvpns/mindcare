import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hilway/core/constants/app_colors.dart';
import 'package:hilway/core/constants/app_text_styles.dart';
import 'package:hilway/self_assessment/providers/self_assessment_provider.dart';
import 'package:hilway/shared/widgets/responsive_wrapper.dart';

class BurnoutResultScreen extends ConsumerWidget {
  const BurnoutResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(assessmentStateProvider);
    final result = resultState.value;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Result')),
        body: const Center(child: Text('No result available.')),
      );
    }

    // Derive risk level from interpretation string stored in the model
    final interpLower = result.interpretation.toLowerCase();
    Color riskColor;
    String riskTitle;
    String copingAdvice;

    if (interpLower.contains('high')) {
      riskColor = AppColors.error;
      riskTitle = 'High Burnout Risk';
      copingAdvice = 'You are under significant stress. Please prioritize rest. Consider reaching out to your clinical instructor or a counselor for support.';
    } else if (interpLower.contains('medium') || interpLower.contains('moderate')) {
      riskColor = Colors.orange;
      riskTitle = 'Moderate Burnout Risk';
      copingAdvice = 'You are balancing a lot. Make sure to schedule small breaks during your duties and stay hydrated. Talk to a peer if you feel overwhelmed.';
    } else {
      riskColor = AppColors.primary;
      riskTitle = 'Low Burnout Risk';
      copingAdvice = 'You are managing your stress well! Keep up your good routines and self-care practices.';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Assessment', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () {
            // Reset state and go back to dashboard
            ref.read(assessmentStateProvider.notifier).reset();
            context.go('/');
          },
        ),
      ),
      body: ResponsiveWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Donut chart or massive score representation
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: riskColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      interpLower.contains('high')
                          ? Icons.warning_amber_rounded 
                          : Icons.favorite_border_rounded,
                      size: 64,
                      color: riskColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      riskTitle,
                      style: AppTextStyles.headingMedium.copyWith(color: riskColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Confidence: ${result.totalScore.toStringAsFixed(1)}%",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
  
              const Text(
                'What should you do next?',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 16),
  
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Text(
                  copingAdvice,
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.5),
                ),
              ),
  
              const SizedBox(height: 32),
  
              ElevatedButton(
                onPressed: () {
                  ref.read(assessmentStateProvider.notifier).reset();
                  context.go('/chat'); // Talk to Kelly — matches AppRoutes.chatbot
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Talk to Kelly',
                  style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
