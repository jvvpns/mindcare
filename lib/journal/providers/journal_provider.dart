import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/journal_entry.dart';
import '../../core/services/hive_service.dart';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]) {
    _loadEntries();
  }

  void _loadEntries() {
    final box = HiveService.journalBox;
    final entries = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = entries;
  }

  Future<void> addEntry(String title, String content, {double? moodIndex}) async {
    final newEntry = JournalEntry.create(
      title: title,
      content: content,
      moodIndex: moodIndex,
    );
    await HiveService.journalBox.put(newEntry.id, newEntry);
    _loadEntries();
  }

  Future<void> updateEntry(JournalEntry entry, String title, String content, {double? moodIndex}) async {
    final updated = entry.copyWith(
      title: title,
      content: content,
      moodIndex: moodIndex,
      updatedAt: DateTime.now(),
    );
    await HiveService.journalBox.put(updated.id, updated);
    _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await HiveService.journalBox.delete(id);
    _loadEntries();
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});
