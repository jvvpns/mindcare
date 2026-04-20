import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hilway/core/constants/app_constants.dart';
import 'package:hilway/core/services/hive_service.dart';
import 'package:hilway/core/services/supabase_service.dart';

import '../models/mood_log.dart';
import '../models/stress_rating.dart';
import '../models/journal_entry.dart';
import '../models/planner_entry.dart';
import '../models/assessment_result.dart';
import '../models/refuel_log.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

/// Handles offline-first data synchronization between local Hive and remote Supabase.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  bool _isSyncing = false;

  Box get _queueBox => Hive.box(AppConstants.boxSyncQueue);

  /// Queues an upsert (insert or update) action for when internet is available.
  Future<void> queueUpsert({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return; // Don't queue if not logged in

    // Inject user_id securely before queueing
    data['user_id'] = userId;

    final job = {
      'action': 'upsert',
      'table': table,
      'id': id,
      'data': data,
    };

    // Store in Hive queue (using composite key to avoid duplicate jobs for same item)
    final key = '${table}_${id}';
    await _queueBox.put(key, job);
    debugPrint('SyncService: Queued upsert for $key');

    // Attempt to process queue immediately (will fail silently if offline)
    processQueue();
  }

  /// Queues a delete action for when internet is available.
  Future<void> queueDelete({
    required String table,
    required String id,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    final job = {
      'action': 'delete',
      'table': table,
      'id': id,
    };

    final key = 'delete_${table}_${id}';
    await _queueBox.put(key, job);
    debugPrint('SyncService: Queued delete for $key');

    processQueue();
  }

  /// Processes all pending jobs in the queue. Runs automatically on internet restore or app start.
  Future<void> processQueue() async {
    if (_isSyncing || _queueBox.isEmpty) return;

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    _isSyncing = true;
    debugPrint('SyncService: Processing ${_queueBox.length} items in queue...');

    try {
      final keys = _queueBox.keys.toList();
      
      for (final key in keys) {
        final job = Map<String, dynamic>.from(_queueBox.get(key) as Map);
        final action = job['action'] as String;
        final table = job['table'] as String;
        final id = job['id'] as String;

        try {
          if (action == 'upsert') {
            final data = Map<String, dynamic>.from(job['data'] as Map);
            await SupabaseService.client.from(table).upsert(data);
          } else if (action == 'delete') {
            await SupabaseService.client.from(table).delete().eq('id', id);
          }

          // If successful, remove from queue
          await _queueBox.delete(key);
        } on PostgrestException catch (e) {
          // If it's a permanent syntax error (e.g. invalid UUID format), skip it 
          // to avoid blocking the rest of the queue.
          if (e.code == '22P02') {
            debugPrint('SyncService: Skipping corrupted job $key due to invalid syntax (22P02): ${e.message}');
            await _queueBox.delete(key);
          } else {
            rethrow; // Let the outer catch handle network/temporary errors
          }
        }
      }
      debugPrint('SyncService: Queue processed successfully.');
    } catch (e) {
      debugPrint('SyncService: Queue processing failed (likely offline). Will retry later. Error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Fetches all user data from Supabase and populates local Hive boxes.
  /// Typically called on first sign-in or manual sync.
  Future<void> pullAllData() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    debugPrint('SyncService: Pulling all remote data for user \$userId...');

    try {
      final client = SupabaseService.client;

      // 1. Mood Logs
      final moods = await client.from('mood_logs').select().eq('user_id', userId);
      for (var map in moods) {
        final log = MoodLog.fromMap(map);
        await HiveService.moodBox.put(log.id, log);
      }

      // 2. Stress Ratings
      final stress = await client.from('stress_ratings').select().eq('user_id', userId);
      for (var map in stress) {
        final rating = StressRating.fromMap(map);
        await HiveService.stressBox.put(rating.id, rating);
      }

      // 3. Journal Entries
      final journals = await client.from('journal_entries').select().eq('user_id', userId);
      for (var map in journals) {
        final entry = JournalEntry.fromMap(map);
        await HiveService.journalBox.put(entry.id, entry);
      }

      // 4. Planner Entries
      final tasks = await client.from('planner_entries').select().eq('user_id', userId);
      for (var map in tasks) {
        final task = PlannerEntry.fromMap(map);
        await HiveService.plannerBox.put(task.id, task);
      }

      // 4. Assessment Results
      final assessments = await client.from('assessment_results').select().eq('user_id', userId);
      for (var map in assessments) {
        final res = AssessmentResult.fromMap(map);
        await HiveService.assessmentBox.put(res.id, res);
      }

      // 5. Refuel Logs
      final refuels = await client.from('refuel_logs').select().eq('user_id', userId);
      for (var map in refuels) {
        final log = RefuelLog.fromMap(map);
        await HiveService.refuelBox.put(log.id, log);
      }

      // 6. Chat Sessions
      final sessions = await client.from('chat_sessions').select().eq('user_id', userId);
      for (var map in sessions) {
        final session = ChatSession.fromMap(map);
        await HiveService.chatSessionBox.put(session.id, session);
      }

      // 7. Chat Messages
      final messages = await client.from('chat_messages').select().eq('user_id', userId);
      for (var map in messages) {
        final msg = ChatMessage.fromMap(map);
        await HiveService.chatBox.put(msg.id, msg);
      }

      debugPrint('SyncService: Successfully pulled and saved all remote data.');
    } catch (e) {
      debugPrint('SyncService: Failed to pull remote data: \$e');
      // If we fail to pull, the user still has an empty local DB (or whatever they had).
      // They can retry by refreshing or restarting.
    }
  }
}
