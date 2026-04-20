import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/user_extensions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/hilway_card.dart';
import '../../shared/widgets/hilway_background.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../mood_tracking/widgets/mood_bottom_sheet.dart';
import '../../journal/providers/journal_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/wellness_gauge.dart';
import '../widgets/refuel_chart.dart';
import '../providers/pulse_provider.dart';
import '../providers/streak_provider.dart';
import '../../planner/providers/planner_provider.dart';
import '../../chatbot/widgets/kelly_orb_mascot.dart';
import '../../chatbot/providers/kelly_state_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../providers/dashboard_interaction_provider.dart';
import '../../clinical_duty/providers/shift_provider.dart';
import '../../core/models/mood_log.dart';
import '../../core/models/planner_entry.dart';
import '../../clinical_duty/models/shift_task.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/burnout_provider.dart';
import '../../core/services/burnout_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/mood_checker_row.dart';
import '../widgets/hero_journal_card.dart';
import '../widgets/floating_emoji.dart';
import '../../self_assessment/providers/self_assessment_provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final userName = user?.firstName ?? 'Guiding Star';
    final dailyQuote = ref.watch(dailyQuoteProvider);
    final effectiveEmotion = ref.watch(globalBackgroundEmotionProvider);
    
    // Watch Burnout Prediction for DashboardHeader
    final burnoutResult = ref.watch(burnoutRiskProvider);
    final burnoutLevel = burnoutResult.maybeWhen(
      data: (data) => data['level'] as BurnoutLevel?,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HilwayBackground(
        emotion: effectiveEmotion,
        child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  DashboardHeader(
                    userName: userName,
                    quote: dailyQuote,
                    effectiveEmotion: effectiveEmotion,
                    burnoutLevel: burnoutLevel,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildVitalsBentoRow(context, ref),
                  const SizedBox(height: 24),

                  MoodCheckerRow(),
                  const SizedBox(height: 24),

                  RefuelChart(),
                  const SizedBox(height: 24),

                  HeroJournalCard(),
                  const SizedBox(height: 24),

                  _buildToolGrid(context, ref),
                  const SizedBox(height: 48),
                ]),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }



  Widget _buildVitalsBentoRow(BuildContext context, WidgetRef ref) {
    final pulse = ref.watch(wellnessPulseProvider);
    final tasks = ref.watch(plannerProvider);
    final now = DateTime.now();
    final next24Hours = now.add(const Duration(hours: 24));
    
    final upcomingTasks = tasks.where((t) => 
      !t.isCompleted && 
      t.dueDate.isAfter(now) && 
      t.dueDate.isBefore(next24Hours)
    ).toList();

    final cooldown = ref.watch(burnoutCooldownProvider).value ?? Duration.zero;
    final isCooldownActive = cooldown > Duration.zero;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Resilience Gauge (Primary Vital) ────────────────────────────────
        Expanded(
          flex: 5,
          child: HilwayCard(
            isGlass: true,
            glowColor: AppColors.moodHappy, // Always glow to maintain vibrancy
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            color: Colors.white.withValues(alpha: 0.3),
            onTap: isCooldownActive ? null : () => context.go(AppRoutes.burnoutAssessment),
            child: Stack(
              children: [
                WellnessGauge(
                  score: pulse.resilienceScore,
                  level: pulse.level,
                  isLocked: isCooldownActive,
                  label: pulse.label, // Always show the label (e.g., "Low Risk")
                ),
                if (isCooldownActive)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(PhosphorIconsRegular.lockKey, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            "${cooldown.inHours}h ${cooldown.inMinutes % 60}m",
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // ── Next Task Bento (Urgent Schedule) ───────────────────────────────
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildCompactNextTask(context, upcomingTasks.isNotEmpty ? upcomingTasks.first : null),
              const SizedBox(height: 12),
              _buildBentoAction(
                context, 
                title: "Breathing", 
                icon: PhosphorIconsRegular.wind, 
                color: AppColors.primary,
                route: AppRoutes.breathing,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactNextTask(BuildContext context, PlannerEntry? task) {
    return HilwayCard(
      isGlass: true,
      glowColor: AppColors.accent,
      padding: const EdgeInsets.all(12),
      onTap: () => context.go(AppRoutes.planner),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(PhosphorIconsRegular.clockUser, color: AppColors.accent, size: 18),
              const SizedBox(width: 6),
              Text(
                "Next Task",
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (task != null) ...[
            Text(
              task.title,
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              DateFormat('h:mm a').format(task.dueDate),
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ] else
            Row(
              children: [
                PhosphorIcon(PhosphorIconsRegular.checkCircle, color: AppColors.secondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  "All clear!",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBentoAction(BuildContext context, {required String title, required IconData icon, required Color color, required String route}) {
    return HilwayCard(
      isGlass: true,
      glowColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      onTap: () => context.go(route),
      child: Row(
        children: [
          PhosphorIcon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTaskCard(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink(); // Replaced by Bento
  }

  Widget _buildToolGrid(BuildContext context, WidgetRef ref) {
    final pulse = ref.watch(wellnessPulseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Wellness Tools", style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ToolCard(
                title: "Talk to Kelly",
                subtitle: "Your AI companion",
                iconData: PhosphorIconsRegular.chatTeardropDots,
                color: AppColors.secondary,
                route: AppRoutes.chatbot,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ToolCard(
                title: "Crisis Support",
                subtitle: "Get help instantly",
                iconData: PhosphorIconsRegular.phoneCall,
                color: AppColors.crisis,
                route: '/crisis',
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Color color;
  final String route;
  final bool compact;

  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.color,
    required this.route,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return HilwayCard(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 12 : 20,
      ),
      isGlass: true,
      glowColor: color,
      color: Colors.white.withValues(alpha: 0.4),
      onTap: () => context.push(route),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(iconData, color: color, size: compact ? 22 : 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 14 : 16,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (compact)
            PhosphorIcon(
              PhosphorIconsRegular.caretRight,
              color: AppColors.textTertiary,
              size: 16,
            ),
        ],
      ),
    );
  }
}
