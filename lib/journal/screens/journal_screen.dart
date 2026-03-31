import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../providers/journal_provider.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/journal/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(PhosphorIconsRegular.pencil, color: Colors.white),
      ),
      body: SafeArea(
        child: entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const PhosphorIcon(PhosphorIconsRegular.bookOpenText, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    const Text('No entries yet', style: AppTextStyles.headingMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Clear your mind by writing your thoughts.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(entry.createdAt);

                  return GestureDetector(
                    onTap: () => context.push('/journal/edit', extra: entry),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(formattedDate, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                              if (entry.moodIndex != null && entry.moodIndex! >= 0 && entry.moodIndex! < AppConstants.moodEmojis.length)
                                Text(
                                  AppConstants.moodEmojis[entry.moodIndex!.toInt()],
                                  style: const TextStyle(fontSize: 20),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            entry.title,
                            style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry.content,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}