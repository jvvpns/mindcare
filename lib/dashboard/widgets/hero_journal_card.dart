import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/hilway_card.dart';
import '../../journal/providers/journal_provider.dart';

class HeroJournalCard extends ConsumerWidget {
  const HeroJournalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journals = ref.watch(journalProvider);
    final hasLogs = journals.isNotEmpty;
    final snippet = hasLogs ? journals.first.content : "Write down one good thing that happened today.";

    return HilwayCard(
      isGlass: true,
      glowColor: AppColors.secondary,
      color: AppColors.secondary.withValues(alpha: 0.08),
      onTap: () => context.push(AppRoutes.journal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const PhosphorIcon(PhosphorIconsRegular.bookOpenText, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text("Daily Reflection", style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              PhosphorIcon(PhosphorIconsRegular.caretRight, color: AppColors.secondary.withValues(alpha: 0.6), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            snippet,
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasLogs ? AppColors.textPrimary : AppColors.textSecondary,
              fontStyle: hasLogs ? FontStyle.normal : FontStyle.italic,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
