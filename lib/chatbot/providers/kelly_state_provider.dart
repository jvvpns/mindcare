import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/burnout_provider.dart';
import '../../core/services/burnout_service.dart';

/// Holds the current emotion state of Kelly in the chatbot screen.
/// Can be updated based on sentiment analysis of the user's latest message.
final kellyEmotionProvider = StateProvider<String>((ref) {
  return AppConstants.kellyDefault; // Start with the default emotion
});

/// Global provider that determines the background mood for the entire app.
final globalBackgroundEmotionProvider = Provider<String>((ref) {
  final kellyEmotion = ref.watch(kellyEmotionProvider);
  final burnoutResult = ref.watch(burnoutRiskProvider);
  
  final burnoutLevel = burnoutResult.maybeWhen(
    data: (data) => data['level'] as BurnoutLevel?,
    orElse: () => null,
  );

  // Override background with a concerned gradient if burnout is high
  if (burnoutLevel == BurnoutLevel.high) {
    return AppConstants.kellyConcerned;
  }
  
  return kellyEmotion;
});
