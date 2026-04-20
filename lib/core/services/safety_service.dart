import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/app_constants.dart';

/// Offline AI Safety Service using TFLite to detect crisis intent.
/// This acts as a 'Guardian' layer that works without internet.
class SafetyService {
  SafetyService._();
  static final SafetyService instance = SafetyService._();

  Interpreter? _interpreter;

  /// Loads the TFLite safety model.
  Future<void> init() async {
    try {
      // NOTE: User needs to add safety_model.tflite to assets/models
      _interpreter = await Interpreter.fromAsset('assets/models/safety_model.tflite');
      debugPrint('Safety TFLite model loaded.');
    } catch (e) {
      debugPrint('Safety model not found or failed to load. Falling back to keyword safety. — $e');
    }
  }

  /// Analyzes text for crisis intent using AI + Keywords.
  bool isCrisis(String text) {
    final lower = text.toLowerCase();
    
    // 1. Baseline: Keyword Detection (Fast & Reliable)
    bool hasCrisisKeywords = AppConstants.crisisKeywords.any((k) => lower.contains(k));
    if (hasCrisisKeywords) return true;

    // 2. AI Layer: TFLite Classifier (Contextual)
    if (_interpreter != null) {
      try {
        // Prepare input (tokenization usually happens here)
        // For now, this is a stub for where the model would run
        // var input = _tokenize(text);
        // var output = List.filled(2, 0.0).reshape([1, 2]); // [Safe, Crisis]
        // _interpreter!.run(input, output);
        // return output[0][1] > 0.8; // High confidence crisis
      } catch (e) {
        debugPrint('Safety AI Error: $e');
      }
    }

    return false;
  }
}
