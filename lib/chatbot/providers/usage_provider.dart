import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/hive_service.dart';

class UsageState {
  final int messagesRemaining;
  final DateTime lastReset;

  UsageState({
    required this.messagesRemaining,
    required this.lastReset,
  });

  UsageState copyWith({
    int? messagesRemaining,
    DateTime? lastReset,
  }) =>
      UsageState(
        messagesRemaining: messagesRemaining ?? this.messagesRemaining,
        lastReset: lastReset ?? this.lastReset,
      );
}

class UsageNotifier extends StateNotifier<UsageState> {
  final Ref _ref;

  UsageNotifier(this._ref)
      : super(UsageState(
          messagesRemaining: AppConstants.maxDailyMessages,
          lastReset: DateTime.now(),
        )) {
    _init();
  }

  static const _cooldownHours = 4;

  void _init() {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    final settings = HiveService.settingsBox;
    final lastResetStr = settings.get('${user.id}_${AppConstants.keyLastUsageReset}') as String?;
    final count = settings.get('${user.id}_${AppConstants.keyDailyUsageCount}', defaultValue: 0) as int;

    final now = DateTime.now();

    if (lastResetStr == null) {
      // First time use for this user
      _reset(now);
    } else {
      final lastResetDate = DateTime.parse(lastResetStr);
      final hoursSince = now.difference(lastResetDate).inHours;

      if (hoursSince >= _cooldownHours) {
        // Cooldown passed — reset
        _reset(now);
      } else {
        // Still within cooldown window
        state = UsageState(
          messagesRemaining: AppConstants.maxDailyMessages - count,
          lastReset: lastResetDate,
        );
      }
    }
  }

  void _reset(DateTime date) {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    HiveService.settingsBox.put('${user.id}_${AppConstants.keyLastUsageReset}', date.toIso8601String());
    HiveService.settingsBox.put('${user.id}_${AppConstants.keyDailyUsageCount}', 0);
    
    state = UsageState(
      messagesRemaining: AppConstants.maxDailyMessages,
      lastReset: date,
    );
  }

  bool incrementUsage() {
    final user = _ref.read(authProvider).user;
    if (user == null) return false;

    if (state.messagesRemaining <= 0) return false;

    final newCount = (AppConstants.maxDailyMessages - state.messagesRemaining) + 1;
    HiveService.settingsBox.put('${user.id}_${AppConstants.keyDailyUsageCount}', newCount);

    state = state.copyWith(messagesRemaining: state.messagesRemaining - 1);
    return true;
  }
}

final usageProvider = StateNotifierProvider<UsageNotifier, UsageState>((ref) {
  ref.watch(authProvider); // Rebuild on auth change
  return UsageNotifier(ref);
});
