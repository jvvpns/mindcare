import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/chat_session_provider.dart';
import '../../shared/widgets/responsive_wrapper.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(chatSessionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const PhosphorIcon(PhosphorIconsRegular.caretLeft, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chat History',
          style: AppTextStyles.headingLarge,
        ),
        actions: [
          IconButton(
            tooltip: 'Clear All Sessions',
            icon: const PhosphorIcon(PhosphorIconsRegular.trash, color: AppColors.error),
            onPressed: () => _confirmDeleteAll(context, ref),
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child: sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PhosphorIcon(PhosphorIconsRegular.chatCircleText, size: 64, color: AppColors.textTertiary),
                    const SizedBox(height: 16),
                    Text(
                      'No chat history yet.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final dateStr = DateFormat('MMM d, h:mm a').format(session.updatedAt);
                  final isActive = ref.read(currentSessionIdProvider) == session.id;
  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Dismissible(
                        key: ValueKey(session.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const PhosphorIcon(PhosphorIconsRegular.trash, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref.read(chatSessionsProvider.notifier).deleteSession(session.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Session deleted')),
                          );
                        },
                        child: InkWell(
                          onTap: () {
                            ref.read(currentSessionIdProvider.notifier).state = session.id;
                            context.pop(); // Go back to chatbot
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive ? AppColors.primary : AppColors.borderLight,
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const PhosphorIcon(PhosphorIconsRegular.chatCircleText, color: AppColors.primary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.title,
                                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr,
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const PhosphorIcon(PhosphorIconsRegular.caretRight, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All History?'),
        content: const Text('Are you sure you want to delete all your conversations? This cannot be undone.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel', style: AppTextStyles.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatSessionsProvider.notifier).deleteAllSessions();
              ctx.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All history deleted.')),
              );
            },
            child: Text('Delete', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
