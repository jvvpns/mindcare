import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Offline AI Safety Service using TFLite to detect crisis intent.
/// This acts as a 'Guardian' layer that works without internet.
class SafetyService {
  SafetyService._();
  static final SafetyService instance = SafetyService._();

  /// Analyzes text for crisis intent using Keywords.
  bool isCrisis(String text) {
    final lower = text.toLowerCase();
    
    // 1. Baseline: Keyword Detection (Fast & Reliable)
    return AppConstants.crisisKeywords.any((k) => lower.contains(k));
  }
}
