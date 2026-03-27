import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';

/// Holds the current emotion state of Kelly in the chatbot screen.
/// Can be updated based on sentiment analysis of the user's latest message.
final kellyEmotionProvider = StateProvider<String>((ref) {
  return AppConstants.kellyDefault; // Start with the default emotion
});
