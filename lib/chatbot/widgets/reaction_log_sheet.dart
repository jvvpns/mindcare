import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../../core/services/intelligence_service.dart';
import 'dart:convert';

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
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: "Reactions"),
                          Tab(text: "Live Context"),
                        ],
                        labelColor: AppColors.primary,
                        indicatorColor: AppColors.primary,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildReactionList(context, messages, loggedEntries, controller),
                            _buildContextInspector(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReactionList(
    BuildContext context, 
    List<ChatMessage> messages, 
    List<ChatMessage> loggedEntries,
    ScrollController controller,
  ) {
    return loggedEntries.isEmpty
        ? const Center(child: Text("No reactions logged yet.", style: AppTextStyles.bodyMedium))
        : ListView.separated(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: loggedEntries.length,
            separatorBuilder: (_, __) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final log = loggedEntries[index];
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
                  ],
                ],
              );
            },
          );
  }

  Widget _buildContextInspector(BuildContext context) {
    final lastContext = IntelligenceService.instance.lastContext;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Intelligence Gateway Metadata",
            style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (lastContext == null)
            const Text("No context sent yet. Chat with Kelly to build a context.")
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(
                const JsonEncoder.withIndent('  ').convert(lastContext),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
