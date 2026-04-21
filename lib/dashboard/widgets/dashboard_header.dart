import '../../core/models/burnout_risk.dart';
import '../../core/providers/sync_provider.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/mood_log.dart';
import '../../core/models/planner_entry.dart';
import '../../clinical_duty/models/shift_task.dart';
import '../../chatbot/widgets/kelly_orb_mascot.dart';
import '../providers/dashboard_interaction_provider.dart';
import '../providers/streak_provider.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../planner/providers/planner_provider.dart';
import '../../clinical_duty/providers/shift_provider.dart';

class DashboardHeader extends ConsumerWidget {
  final String userName;
  final String quote;
  final String effectiveEmotion;
  final BurnoutLevel? burnoutLevel;

  const DashboardHeader({
    super.key,
    required this.userName,
    required this.quote,
    required this.effectiveEmotion,
    this.burnoutLevel,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _getMoodAnalysis(
    MoodLog? log, 
    String fallbackQuote, 
    double sleepHours,
    List<PlannerEntry> todayTasks,
    List<ShiftTask> activeDuties,
    BurnoutLevel? burnoutLevel,
  ) {
    if (burnoutLevel == BurnoutLevel.high) {
      return "I've noticed your current load might lead to burnout. Let's take a 5-minute breathing break together?";
    }
    if (todayTasks.isNotEmpty) {
      final task = todayTasks.first;
      return "I see you have '${task.title}' due today. You've got this, Future Nurse!";
    }
    final pendingDuties = activeDuties.where((t) => !t.isDone).toList();
    if (pendingDuties.isNotEmpty) {
      return "You have ${pendingDuties.length} pending tasks in your Shift Buddy. Don't forget to take a breather!";
    }
    if (sleepHours > 0 && sleepHours < 6) {
      return "I see you only had ${sleepHours.toStringAsFixed(1)} hours of sleep. Please take it easy today.";
    }
    if (log == null) return fallbackQuote;
    
    final mood = log.moodLabel.toLowerCase();
    switch (mood) {
      case 'calm': return "You're feeling calm today. It's a great time to focus on your studies.";
      case 'happy': return "I love seeing you happy! Keep that positive energy going.";
      case 'energetic': return "You've got a lot of energy today! Maybe tackle those complex clinical charts?";
      case 'anxious': return "Feeling a bit anxious? Remember to take slow breaths. You've got this.";
      case 'sad': return "It's okay to feel sad. Take things one step at a time today.";
      case 'depressed': return "You seem really down. Please be gentle with yourself today.";
      default: return fallbackQuote;
    }
  }

  Color _getKellyCardColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'default':
      case 'energetic':
        return AppColors.emotionToColors['happy']![0].withValues(alpha: 0.85);
      case 'happy':
        return AppColors.emotionToColors['concerned']![0].withValues(alpha: 0.85);
      case 'calm':
        return AppColors.emotionToColors['sad']![0].withValues(alpha: 0.85);
      case 'sad':
        return AppColors.emotionToColors['calm']![0].withValues(alpha: 0.85);
      case 'excited':
        return AppColors.emotionToColors['surprised']![0].withValues(alpha: 0.85);
      case 'concerned':
        return AppColors.emotionToColors['happy']![0].withValues(alpha: 0.85);
      case 'surprised':
        return AppColors.emotionToColors['excited']![0].withValues(alpha: 0.85);
      default:
        return AppColors.emotionToColors['happy']![0].withValues(alpha: 0.85);
    }
  }

  Color _getKellyCardBorderColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'default':
      case 'energetic':
        return AppColors.emotionToColors['happy']![1].withValues(alpha: 0.4);
      case 'happy':
        return AppColors.emotionToColors['concerned']![1].withValues(alpha: 0.4);
      case 'calm':
        return AppColors.emotionToColors['sad']![1].withValues(alpha: 0.4);
      case 'sad':
        return AppColors.emotionToColors['calm']![1].withValues(alpha: 0.4);
      case 'excited':
        return AppColors.emotionToColors['surprised']![1].withValues(alpha: 0.4);
      case 'concerned':
        return AppColors.emotionToColors['happy']![1].withValues(alpha: 0.4);
      case 'surprised':
        return AppColors.emotionToColors['excited']![1].withValues(alpha: 0.4);
      default:
        return AppColors.emotionToColors['happy']![1].withValues(alpha: 0.4);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMood = ref.watch(todayMoodProvider);
    final sleepHours = ref.watch(sleepDurationProvider);
    final pokedMessage = ref.watch(kellyPokedMessageProvider);
    final plannerEntries = ref.watch(plannerProvider);
    final shiftTasks = ref.watch(shiftProvider);
    final streakCount = ref.watch(streakProvider);
    
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    final todayTasks = plannerEntries.where((e) => e.isDueToday && !e.isCompleted).toList();
    
    final syncStatus = ref.watch(syncStatusProvider).value ?? SyncUIState.idle;
    
    final message = pokedMessage ?? _getMoodAnalysis(
      todayMood, 
      quote, 
      sleepHours, 
      todayTasks, 
      shiftTasks,
      burnoutLevel,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── App Brand & Tagline ───────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/hilway_logo.png', height: 28),
                  const SizedBox(width: 10),
                  Text(
                    "HILWAY",
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Text(
                "Holistic Inner Life Well-being and AI for You",
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_greeting(), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(
                    _capitalize(userName),
                    style: AppTextStyles.displayMedium.copyWith(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF4DB6AC), Color(0xFF9575CD)],
                        ).createShader(const Rect.fromLTWH(0.0, 0.0, 220.0, 70.0)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const PhosphorIcon(PhosphorIconsFill.plant, color: AppColors.success, size: 18),
                      const SizedBox(width: 6),
                      Text('$streakCount', style: AppTextStyles.labelMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: _buildSyncIcon(syncStatus),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
                  child: const PhosphorIcon(PhosphorIconsRegular.bell, color: AppColors.textPrimary, size: 20),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (!isDesktop) // Only show the full card on Mobile/Tablet
          GestureDetector(
          onTap: () => ref.read(kellyPokedMessageProvider.notifier).poke(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Builder(
                builder: (context) {
                  final bgColor = _getKellyCardColor(effectiveEmotion);
                  final borderColor = _getKellyCardBorderColor(effectiveEmotion);
                  
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Glowing Orb (No separate background circle) ─────────
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: Center(
                            child: KellyMiniOrb(emotion: effectiveEmotion, size: 54),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ── Message Content ──────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Kelly",
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: AppColors.primary, 
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
          ),
        ) else // On Desktop, show a compact "Clinical Pulse" bar instead
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsFill.lightning, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSyncIcon(SyncUIState state) {
    switch (state) {
      case SyncUIState.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
        );
      case SyncUIState.pending:
        return const PhosphorIcon(PhosphorIconsRegular.cloudArrowUp, color: AppColors.textTertiary, size: 20);
      case SyncUIState.error:
        return const PhosphorIcon(PhosphorIconsFill.cloudWarning, color: AppColors.crisis, size: 20);
      case SyncUIState.idle:
        return const PhosphorIcon(PhosphorIconsRegular.cloudCheck, color: AppColors.success, size: 20);
    }
  }
}
