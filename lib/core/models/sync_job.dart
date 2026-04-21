import 'package:hive/hive.dart';
import 'package:hilway/core/constants/app_constants.dart';

part 'sync_job.g.dart';

@HiveType(typeId: 10) // AppConstants.hiveTypeSyncJob
enum SyncState {
  @HiveField(0)
  pending,
  @HiveField(1)
  syncing,
  @HiveField(2)
  failed,
  @HiveField(3)
  retrying,
}

@HiveType(typeId: 11) // AppConstants.hiveTypeSyncJobModel
class SyncJob extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String action; // 'upsert' or 'delete'

  @HiveField(2)
  final String table;

  @HiveField(3)
  final Map<String, dynamic> payload;

  @HiveField(4)
  SyncState state;

  @HiveField(5)
  int retryCount;

  @HiveField(6)
  DateTime? lastAttempt;

  @HiveField(7)
  final DateTime createdAt;

  SyncJob({
    required this.id,
    required this.action,
    required this.table,
    required this.payload,
    this.state = SyncState.pending,
    this.retryCount = 0,
    this.lastAttempt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'table': table,
      'payload': payload,
      'state': state.index,
      'retryCount': retryCount,
      'lastAttempt': lastAttempt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
