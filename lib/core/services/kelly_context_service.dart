import 'package:intl/intl.dart';
import 'package:hilway/core/services/hive_service.dart';
import 'package:hilway/core/services/sync_service.dart';
import 'package:uuid/uuid.dart';
import 'package:hilway/core/models/chat_message.dart' as hive_msg;

/// Formerly KellyContextService. 
/// Now LocalContextService: Responsible for lightweight local state 
/// and offline fallback logic. 
class LocalContextService {
  LocalContextService._();
  static final LocalContextService instance = LocalContextService._();

  // ── 1. Local Snapshot (Offline Fallback) ──────────────────────────────────
  /// Builds a lightweight map of current user state for offline use
  /// or when the backend is cold-starting.
  Map<String, dynamic> buildLocalSnapshot() {
    return {
      "todayMood": getTodayMood(DateTime.now()),
      "recentMoods": _getRecentMoodLabels(3),
      "pendingTasks": _getPendingTasksCount(),
      "burnoutLevel": _getLatestBurnoutLevel(),
    };
  }

  // ── 2. Persist Messages ───────────────────────────────────────────────────
  Future<void> persistMessage({
    required String userId,
    required String content,
    required String role, // 'user' or 'assistant'
    bool isCrisisDetected = false,
    String? sessionId,
  }) async {
    try {
      final msg = hive_msg.ChatMessage(
        id: const Uuid().v4(),
        userId: userId,
        content: content,
        role: role,
        sentAt: DateTime.now(),
        isCrisisDetected: isCrisisDetected,
        sessionId: sessionId,
      );
      await HiveService.chatBox.put(msg.id, msg);
      
      // Queue offline-first background sync
      SyncService.instance.queueUpsert(
        table: 'chat_messages',
        id: msg.id,
        data: msg.toMap(),
      );
    } catch (_) {
      // Non-fatal
    }
  }

  // ── 3. Local State Helpers ────────────────────────────────────────────────
  String? getTodayMood(DateTime now) {
    try {
      final todayMoods = HiveService.moodBox.values.where((m) =>
          m.loggedAt.year == now.year &&
          m.loggedAt.month == now.month &&
          m.loggedAt.day == now.day);
      if (todayMoods.isNotEmpty) {
        return todayMoods.first.moodLabel;
      }
    } catch (_) {}
    return null;
  }

  List<String> _getRecentMoodLabels(int count) {
    final moods = HiveService.moodBox.values.toList();
    if (moods.isEmpty) return [];
    moods.sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    return moods.take(count).map((m) => m.moodLabel).toList();
  }

  int _getPendingTasksCount() {
    return HiveService.plannerBox.values.where((t) => !t.isCompleted).length;
  }

  String? _getLatestBurnoutLevel() {
    final assessments = HiveService.assessmentBox.values
        .where((a) => a.type == 'burnout_prediction')
        .toList();
    if (assessments.isEmpty) return null;
    assessments.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return assessments.first.interpretation;
  }
}
