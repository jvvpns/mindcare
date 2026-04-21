import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sync_job.dart';
import '../constants/app_constants.dart';

enum SyncUIState { idle, syncing, pending, error }

final syncStatusProvider = StreamProvider<SyncUIState>((ref) async* {
  final box = Hive.box<SyncJob>(AppConstants.boxSyncQueue);
  
  // Initial state
  yield _calculateState(box);

  // Watch for changes in the queue
  await for (final _ in box.watch()) {
    yield _calculateState(box);
  }
});

SyncUIState _calculateState(Box<SyncJob> box) {
  if (box.isEmpty) return SyncUIState.idle;
  if (box.values.any((j) => j.state == SyncState.syncing)) return SyncUIState.syncing;
  if (box.values.any((j) => j.state == SyncState.failed)) return SyncUIState.error;
  if (box.values.any((j) => j.state == SyncState.retrying)) return SyncUIState.syncing; 
  
  // If we have jobs but none are active/failed, they are 'pending'
  return SyncUIState.pending;
}
