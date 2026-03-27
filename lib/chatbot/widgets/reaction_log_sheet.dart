import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/chat_provider.dart';

class ReactionLogSheet extends ConsumerWidget {
  const ReactionLogSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ReactionLogSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    // Filter messages for entries that fired an emotion
    final loggedEntries = messages.where((m) => m.isUser && m.detectedEmotion != null).toList().reversed.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text("Reaction Validation Log", style: AppTextStyles.headingSmall),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: loggedEntries.isEmpty
                    ? const Center(child: Text("Say something to Kelly to trigger emotional logging.", style: AppTextStyles.bodyMedium))
                    : ListView.separated(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: loggedEntries.length,
                        separatorBuilder: (_, __) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final log = loggedEntries[index];
                          // Find AI response following user msg
                          final idx = messages.indexOf(log);
                          final aiResponse = (idx + 1 < messages.length && !messages[idx+1].isUser) ? messages[idx+1] : null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('hh:mm a').format(log.timestamp),
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "Triggered: ${log.detectedEmotion?.toUpperCase()}",
                                      style: AppTextStyles.caption.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("User Input:", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                              Text('"${log.text}"', style: AppTextStyles.bodyMedium),
                              const SizedBox(height: 8),
                              if (aiResponse != null) ...[
                                Text("Kelly Output:", style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                                Text('"${aiResponse.text}"', style: AppTextStyles.bodyMedium),
                              ] else ...[
                                Text("Kelly Output: [Thinking...]", style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
                              ]
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
