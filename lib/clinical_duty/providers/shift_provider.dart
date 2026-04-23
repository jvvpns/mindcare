import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_task.dart';
import '../../core/services/hive_service.dart';
import '../../core/services/sync_service.dart';
import '../../auth/providers/auth_provider.dart';

final shiftProvider = StateNotifierProvider<ShiftNotifier, List<ShiftTask>>((
  ref,
) {
  ref.watch(authProvider); // Rebuild on auth change
  return ShiftNotifier(ref);
});

class ShiftNotifier extends StateNotifier<List<ShiftTask>> {
  final Ref _ref;
  StreamSubscription? _subscription;

  ShiftNotifier(this._ref) : super([]) {
    _init();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    await _checkMidnightReset();
    _loadTasks();
    // Watch for external changes
    _subscription = HiveService.shiftBox.watch().listen((_) => _loadTasks());
  }

  Future<void> _checkMidnightReset() async {
    const resetKey = 'last_shift_reset_date';
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";

    final lastReset =
        HiveService.settingsBox.get(resetKey, defaultValue: '') as String;

    if (lastReset != todayStr) {
      // It's a new day! Reset all tasks
      final box = HiveService.shiftBox;
      for (var task in box.values) {
        if (task.isDone) {
          task.isDone = false;
          await task.save();
        }
      }
      await HiveService.settingsBox.put(resetKey, todayStr);
    }
  }

  void _loadTasks() {
    if (!mounted) return;
    final user = _ref.read(authProvider).user;
    if (user == null) {
      state = [];
      return;
    }

    final box = HiveService.shiftBox;
    final tasks = box.values.where((t) => t.userId == user.id).toList();

    if (tasks.isEmpty) {
      // Default tasks if none exist
      final defaultTasks = [
        ShiftTask(title: 'Receive Endorsement', category: 'Handover'),
        ShiftTask(title: 'Check Patient Vitals', category: 'Routine'),
        ShiftTask(title: 'Medication Rounds (8 AM)', category: 'Meds'),
        ShiftTask(title: 'IVF Monitoring & Regulation', category: 'Monitoring'),
        ShiftTask(title: 'Update Patient Charts', category: 'Documentation'),
        ShiftTask(title: 'Prepare for Endorsement', category: 'Handover'),
      ];

      for (var task in defaultTasks) {
        box.put(task.id, task);
      }
      state = defaultTasks;
    } else {
      state = tasks;
    }
  }

  Future<void> addTask(String title, String category) async {
    final user = _ref.read(authProvider).user;
    if (user == null) return;

    final task = ShiftTask(title: title, category: category, userId: user.id);
    await HiveService.shiftBox.put(task.id, task);
    state = [...state, task];

    // Sync to cloud
    SyncService.instance.queueUpsert(
      table: 'shift_tasks',
      id: task.id,
      data: task.toMap(),
    );
  }

  Future<void> toggleDone(String id) async {
    final box = HiveService.shiftBox;
    final task = box.get(id);
    if (task != null) {
      task.isDone = !task.isDone;
      await task.save();
      state = [
        for (final t in state)
          if (t.id == id) t.copyWith(isDone: task.isDone) else t,
      ];

      // Sync to cloud
      SyncService.instance.queueUpsert(
        table: 'shift_tasks',
        id: task.id,
        data: task.toMap(),
      );
    }
  }

  Future<void> deleteTask(String id) async {
    await HiveService.shiftBox.delete(id);
    state = state.where((t) => t.id != id).toList();

    // Sync deletion to cloud
    SyncService.instance.queueDelete(table: 'shift_tasks', id: id);
  }

  Future<void> resetProgress() async {
    final box = HiveService.shiftBox;
    for (var task in box.values) {
      task.isDone = false;
      await task.save();
    }
    state = [for (final t in state) t.copyWith(isDone: false)];
  }
}
