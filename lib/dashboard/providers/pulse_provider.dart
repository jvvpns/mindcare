import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/hive_service.dart';
import '../../core/models/assessment_result.dart';
import '../../core/models/burnout_risk.dart';
import '../../core/providers/burnout_provider.dart';

class PulseState {
  final double resilienceScore; // 0.0 (High Risk) to 1.0 (Stable)
  final String label;
  final BurnoutLevel level;
  final bool hasData;

  PulseState({
    required this.resilienceScore,
    required this.label,
    required this.level,
    this.hasData = true,
  });

  factory PulseState.initial() => PulseState(
        resilienceScore: 0.8, // Default "Healthy" state
        label: 'Healthy',
        level: BurnoutLevel.low,
        hasData: false,
      );
}

/// A reactive provider that combines manual assessments with real-time health data.
final wellnessPulseProvider = Provider<PulseState>((ref) {
  // 1. Watch for manual assessments (formal tests)
  // We don't watch the box directly here for simplicity, 
  // but we'll use the dynamic burnout risk as the primary driver.
  final burnoutResult = ref.watch(burnoutRiskProvider);

  return burnoutResult.maybeWhen(
    data: (data) {
      final level = data['level'] as BurnoutLevel;
      final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
      
      // Calculate a "Resilience Score" based on level and confidence
      double score = 0.8;
      String label = "Healthy";

      if (level == BurnoutLevel.high) {
        score = 0.2 - (confidence * 0.1);
        label = "High Risk";
      } else if (level == BurnoutLevel.medium) {
        score = 0.5;
        label = "Medium Risk";
      } else {
        score = 0.7 + (confidence * 0.2);
        label = "Low Risk";
      }

      return PulseState(
        resilienceScore: score.clamp(0.05, 0.95),
        label: label,
        level: level,
      );
    },
    orElse: () {
      // Fallback to initial or last known
      return PulseState.initial();
    },
  );
});
