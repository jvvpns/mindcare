import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/burnout_provider.dart';
import '../../core/models/burnout_risk.dart';
import '../../mood_tracking/providers/mood_provider.dart';

/// Holds the current emotion state of Kelly in the chatbot screen.
/// Can be updated based on sentiment analysis of the user's latest message.
final kellyEmotionProvider = StateProvider<String>((ref) {
  return AppConstants.kellyDefault; // Start with the default emotion
});

/// Global provider that determines the background mood for the entire app.
final globalBackgroundEmotionProvider = Provider<String>((ref) {
  final kellyEmotion = ref.watch(kellyEmotionProvider);
  final burnoutResult = ref.watch(burnoutRiskProvider);
  final todayMood = ref.watch(todayMoodProvider);
  
  final burnoutLevel = burnoutResult.maybeWhen(
    data: (data) => data['level'] as BurnoutLevel?,
    orElse: () => null,
  );

  // 1. Highest Priority: Override background with a concerned gradient if burnout is high
  if (burnoutLevel == BurnoutLevel.high) {
    return AppConstants.kellyConcerned;
  }
  
  // 2. Medium Priority: If Kelly's emotion has been changed during a chat session, use it
  if (kellyEmotion != AppConstants.kellyDefault) {
    return kellyEmotion;
  }

  // 3. Baseline Priority: Use the user's logged mood for today
  if (todayMood != null) {
    return todayMood.moodLabel.toLowerCase();
  }

  // 4. Fallback: Default state
  return AppConstants.kellyDefault;
});
