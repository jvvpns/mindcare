import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

enum BurnoutLevel { low, medium, high }

class BurnoutService {
  BurnoutService._();
  static final BurnoutService instance = BurnoutService._();

  Interpreter? _interpreter;

  /// Loads the TFLite model from assets.
  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/burnout_model.tflite');
      debugPrint('Burnout model loaded successfully.');
    } catch (e) {
      debugPrint('Error loading burnout model: \$e');
      // If we failed to load for any reason, don't crash, just log it.
    }
  }

  /// Evaluates burnout risk based on four inputs:
  /// 1: Sleep Hours (e.g., 2.0 - 10.0)
  /// 2: Stress Level (e.g., 1.0 - 5.0)
  /// 3: Clinical Duties per week (e.g., 0.0 - 5.0)
  /// 4: Meals Skipped per day (e.g., 0.0 - 4.0)
  /// Returns a Map contaning the predicted level and confidence probabilities.
  Future<Map<String, dynamic>> evaluateRisk({
    required double sleepHours,
    required double stressLevel,
    required double duties,
    required double mealsSkipped,
  }) async {
    if (_interpreter == null) {
      debugPrint('Interpreter not initialized, attempting to init...');
      await init();
      if (_interpreter == null) {
        throw Exception('Failure initializing TFLite Interpreter.');
      }
    }

    // Prepare inputs: The Python model was built with input_shape=(4,)
    // TFlite flutter expects inputs as multi-dimensional lists or Float32List.
    // Shape is [1, 4] for a single batch inference.
    // [ [sleepHours, stressLevel, duties, mealsSkipped] ]
    var inputList = [
      [sleepHours, stressLevel, duties, mealsSkipped]
    ];
    
    // The output tensor from Python model is a Dense(3) with softmax activation.
    // Shape is [1, 3] representing probabilities for [Low, Medium, High].
    var outputList = List.filled(1 * 3, 0.0).reshape([1, 3]);

    try {
      _interpreter!.run(inputList, outputList);

      // Extract probabilities
      List<double> probabilities = (outputList[0] as List).map((e) => (e as num).toDouble()).toList();
      double pLow = probabilities[0];
      double pMed = probabilities[1];
      double pHigh = probabilities[2];

      // Find highest probability
      BurnoutLevel predictedLevel = BurnoutLevel.low;
      double maxProb = pLow;

      if (pMed > maxProb) {
        predictedLevel = BurnoutLevel.medium;
        maxProb = pMed;
      }
      if (pHigh > maxProb) {
        predictedLevel = BurnoutLevel.high;
        maxProb = pHigh;
      }

      return {
        'level': predictedLevel,
        'confidence': maxProb,
        'probabilities': probabilities,
      };
    } catch (e) {
      debugPrint('Error running model inference: \$e');
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}
