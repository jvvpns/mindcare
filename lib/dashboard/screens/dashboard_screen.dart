import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/hilway_card.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../mood_tracking/widgets/mood_bottom_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final userName = user?.email?.split('@').first ?? 'Guiding Star';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(userName),
                  const SizedBox(height: 32),
                  
                  _buildMoodCheckerRow(context, ref),
                  const SizedBox(height: 24),

                  _buildKellyPlaceholder(context),
                  const SizedBox(height: 24),

                  _buildAcademicSnapshot(context),
                  const SizedBox(height: 24),

                  _buildQuickActionCards(context),
                  const SizedBox(height: 48), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi $name,',
              style: AppTextStyles.displayLarge,
            ),
            const SizedBox(height: 4),
            Text(
              "Take a deep breath, you've got this.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 24),
        ),
      ],
    );
  }

  Widget _buildMoodCheckerRow(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayMoodProvider);

    return HilwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todayLog == null ? "How are you feeling today?" : "You're feeling ${todayLog.moodLabel}",
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(AppConstants.moodEmojis.length, (index) {
              final isSelected = todayLog != null && todayLog.moodIndex == index;
              
              return GestureDetector(
                onTap: () {
                  if (todayLog == null) {
                    MoodBottomSheet.show(context, index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    AppConstants.moodEmojis[index],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKellyPlaceholder(BuildContext context) {
    return HilwayCard(
      color: AppColors.accent.withValues(alpha: 0.1),
      onTap: () => context.go(AppRoutes.chatbot),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelly is here",
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "It looks like you had a long shift. Want to debrief?",
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSnapshot(BuildContext context) {
    return HilwayCard(
      onTap: () => context.go(AppRoutes.planner),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Next Up", style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text("Return Demo: Foley Catheter", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          Text("8:00 AM", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildQuickActionCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HilwayCard(
            color: AppColors.secondary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            onTap: () => context.go(AppRoutes.breathing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.air, color: AppColors.secondary, size: 28),
                const SizedBox(height: 12),
                Text("Take a\nBreather", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: HilwayCard(
            color: AppColors.primary.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            onTap: () => context.go(AppRoutes.selfAssessment),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.assignment_outlined, color: AppColors.primary, size: 28),
                const SizedBox(height: 12),
                Text("Check your\nStress", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}