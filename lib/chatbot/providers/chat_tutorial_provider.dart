import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';

/// Manages the visibility of the First-Time User Experience (FTUE) Chat overlay.
/// State is [true] if the overlay should be shown, [false] otherwise.
final chatTutorialProvider = StateNotifierProvider<ChatTutorialNotifier, bool>((ref) {
  return ChatTutorialNotifier();
});

class ChatTutorialNotifier extends StateNotifier<bool> {
  ChatTutorialNotifier() : super(false) {
    _init();
  }

  void _init() {
    // If the setting doesn't exist or is false, show the tutorial.
    final box = HiveService.settingsBox;
    final hasSeen = box.get(AppConstants.keyHasSeenChatTutorial, defaultValue: false) as bool;
    state = !hasSeen;
  }

  void completeTutorial() {
    HiveService.settingsBox.put(AppConstants.keyHasSeenChatTutorial, true);
    state = false;
  }

  void showTutorial() {
    state = true;
  }
}
