import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/refuel_log.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/notification_service.dart';

/// Manages the "Self-Care MAR" (Meal Refuel Chart).
final refuelProvider = StateNotifierProvider<RefuelNotifier, RefuelLog?>((ref) {
  return RefuelNotifier();
});

class RefuelNotifier extends StateNotifier<RefuelLog?> {
  final _uuid = const Uuid();

  RefuelNotifier() : super(null) {
    _loadToday();
  }

  late Box<RefuelLog> _box;

  Future<void> _loadToday() async {
    _box = Hive.box<RefuelLog>(AppConstants.boxRefuelLogs);
    _refresh();
    
    // Listen for external changes (sync, etc.)
    _box.watch().listen((_) => _refresh());
    
    // Ensure daily reminders are scheduled
    NotificationService.instance.scheduleDailyRefuelReminders();

    // Refresh state periodically to update 'missedMeals' and handle midnight resets
    Stream.periodic(const Duration(minutes: 1)).listen((_) {
      if (mounted) {
        final currentKey = _dateToKey(state?.date ?? DateTime.now());
        final todayKey = _dateToKey(DateTime.now());
        if (currentKey != todayKey) {
          _refresh();
        }
      }
    });
  }

  void _refresh() {
    final todayKey = _dateToKey(DateTime.now());
    state = _box.get(todayKey) ?? RefuelLog(id: _uuid.v4(), date: DateTime.now());
  }

  String _dateToKey(DateTime date) => 
      '${date.year}-${date.month}-${date.day}';

  Future<void> logRefuel({
    bool? breakfast,
    bool? lunch,
    bool? dinner,
  }) async {
    final current = state ?? RefuelLog(id: _uuid.v4(), date: DateTime.now());
    final updated = current.copyWith(
      id: current.id.isEmpty ? _uuid.v4() : current.id,
      hasBreakfast: breakfast,
      hasLunch: lunch,
      hasDinner: dinner,
    );

    state = updated;
    await _box.put(_dateToKey(updated.date), updated);

    // Queue offline-first background sync
    SyncService.instance.queueUpsert(
      table: 'refuel_logs',
      id: updated.id,
      data: updated.toMap(),
    );
  }

  /// Determines if a nudge should pop out based on time of day.
  bool shouldNudge() {
    if (state == null) return true;
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour <= 10 && !state!.hasBreakfast) return true;
    if (hour >= 11 && hour <= 14 && !state!.hasLunch) return true;
    if (hour >= 18 && hour <= 21 && !state!.hasDinner) return true;
    
    return false;
  }
}
