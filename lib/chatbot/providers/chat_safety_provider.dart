import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether a crisis-level keyword was detected during the current
/// chatbot session. Once set to true, it remains true for the entire session
/// to ensure the Priority Crisis Bar stays visible.
final isCrisisActiveProvider = StateProvider<bool>((ref) => false);
