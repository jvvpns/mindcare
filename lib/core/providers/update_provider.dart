import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/update_service.dart';
import 'dart:async';

/// Notifier to manage the update state of the application.
class UpdateNotifier extends StateNotifier<bool> {
  UpdateNotifier() : super(false) {
    _startPolling();
  }

  Timer? _timer;

  void _startPolling() {
    // Check for updates every 15 minutes
    _timer = Timer.periodic(const Duration(minutes: 15), (_) => checkForUpdate());
    // Initial check
    checkForUpdate();
  }

  Future<void> checkForUpdate() async {
    final available = await UpdateService.instance.checkForUpdate();
    if (available) {
      state = true;
    }
  }

  void updateApp() {
    UpdateService.instance.performUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, bool>((ref) {
  return UpdateNotifier();
});
