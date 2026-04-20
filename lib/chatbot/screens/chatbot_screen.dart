import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/models/mood_log.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../providers/kelly_state_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_safety_provider.dart';
import '../providers/chat_session_provider.dart';
import '../providers/chat_tutorial_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/priority_crisis_bar.dart';
import '../widgets/chat_tutorial_overlay.dart';
import '../widgets/kelly_orb_mascot.dart';
import '../providers/usage_provider.dart';
import '../providers/kelly_sound_provider.dart';
import '../widgets/reaction_log_sheet.dart';
import '../../core/providers/debug_provider.dart';
import '../../shared/widgets/hilway_background.dart';
import '../../dashboard/providers/refuel_provider.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Send the message through the provider (handles Gemini & sentiment)
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _messageController.clear();

    // Unfocus to prevent keyboard issues during transitions or state changes
    FocusScope.of(context).unfocus();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showPrivacyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            PhosphorIcon(PhosphorIconsFill.shieldCheck, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Privacy First", style: AppTextStyles.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🔒 Your conversations are stored locally.", style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Everything you discuss with Kelly stays entirely on this device. HILWAY does not send your chat logs to any external database or server.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),
            Text("You are safe to express your feelings openly and without judgment.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Understood", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showEnergyInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            PhosphorIcon(PhosphorIconsFill.lightning, color: AppColors.accent),
            SizedBox(width: 8),
            Text("Kelly's Energy", style: AppTextStyles.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("To ensure Kelly can help all nursing students effectively, she has a limited amount of focus energy per day.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
            const SizedBox(height: 12),
            Text("• You get 20 messages every day.\n• Her energy fully recharges at midnight.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Got it", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch Kelly's current emotion for the Hero Header asset
    final currentEmotion = ref.watch(kellyEmotionProvider);
    // Watch Chat State
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);
    final isInitializing = ref.watch(chatInitializingProvider);
    // Watch crisis safety state
    final isCrisisActive = ref.watch(isCrisisActiveProvider);
    // Watch today's mood to drive context-aware chips
    final todayMood = ref.watch(todayMoodProvider);
    // Watch refuel state for physical nudges
    final refuelLog = ref.watch(refuelProvider);
    final refuelNotifier = ref.read(refuelProvider.notifier);

    // Activate sound reactor — plays tones on emotion changes
    ref.watch(kellySoundReactorProvider);

    // Auto-scroll when new messages arrive
    ref.listen(chatMessagesProvider, (_, __) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
    ref.listen(chatLoadingProvider, (_, __) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    // Watch tutorial state
    final showTutorial = ref.watch(chatTutorialProvider);
    // Watch Usage/Energy
    final usage = ref.watch(usageProvider);
    final energyRemaining = usage.messagesRemaining;
    final isEnergyLow = energyRemaining <= 3;
    final hasEnergy = energyRemaining > 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HilwayBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                // ── Header: Glassmorphic Bar ──────────────────────────────
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.92),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const PhosphorIcon(PhosphorIconsRegular.x, color: AppColors.textPrimary),
                              onPressed: () {
                                if (GoRouter.of(context).canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.dashboard);
                                }
                              },
                            ),
                            const SizedBox(width: 4),
                            // ── Badges Container ─────────────────────────────────────
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ── Privacy Badge ───────────────────────────────────────
                                    InkWell(
                                      onTap: _showPrivacyInfo,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceSecondary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const PhosphorIcon(PhosphorIconsRegular.shieldCheck, size: 14, color: AppColors.primary),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Private & Encrypted',
                                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // ── Energy Badge ────────────────────────────────────────
                                    InkWell(
                                      onTap: _showEnergyInfo,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isEnergyLow 
                                            ? AppColors.error.withValues(alpha: 0.1) 
                                            : AppColors.surfaceSecondary,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isEnergyLow ? AppColors.error.withValues(alpha: 0.2) : Colors.transparent,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            PhosphorIcon(
                                              PhosphorIconsRegular.lightning, 
                                              size: 14, 
                                              color: isEnergyLow ? AppColors.error : AppColors.accent,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Energy: $energyRemaining',
                                              style: AppTextStyles.labelSmall.copyWith(
                                                color: isEnergyLow ? AppColors.error : AppColors.textPrimary,
                                                fontWeight: isEnergyLow ? FontWeight.bold : FontWeight.normal,
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
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'New Chat',
                              icon: const PhosphorIcon(PhosphorIconsRegular.pencilSimple, color: AppColors.textSecondary),
                              onPressed: () {
                                ref.read(currentSessionIdProvider.notifier).state = null;
                                _messageController.clear();
                              },
                            ),
                            IconButton(
                              tooltip: 'History',
                              icon: const PhosphorIcon(PhosphorIconsRegular.clock, color: AppColors.textSecondary),
                              onPressed: () => context.push(AppRoutes.chatHistory),
                            ),
                            IconButton(
                              tooltip: 'How to use',
                              icon: const PhosphorIcon(PhosphorIconsRegular.question, color: AppColors.textSecondary),
                              onPressed: () => ref.read(chatTutorialProvider.notifier).showTutorial(),
                            ),
                            if (ref.watch(debugModeProvider))
                              IconButton(
                                tooltip: 'Reaction Log',
                                icon: const PhosphorIcon(PhosphorIconsRegular.bug, color: AppColors.error),
                                onPressed: () => ReactionLogSheet.show(context),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Kelly Orb Mascot ──────────────────────────────────────
                Hero(
                  tag: 'kelly_orb_hero',
                  child: KellyOrbMascot(emotion: currentEmotion, isThinking: isLoading),
                ),
                const SizedBox(height: 8),
            
            // ── Chat List Area ──────────────────────────────────────────
            Expanded(
              child: isInitializing
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Kelly is getting ready...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  // Typing Indicator is the last item if loading
                  if (isLoading && index == messages.length) {
                    return const TypingIndicator();
                  }

                  final message = messages[index];
                  // Slide + fade entrance for Kelly's replies
                  if (!message.isUser) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 18 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: ChatMessageBubble(message: message),
                    );
                  }
                  return ChatMessageBubble(message: message);
                },
              ),
            ),
            
            // ── Crisis Bar (persistent once triggered) ─────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: isCrisisActive
                  ? const PriorityCrisisBar(key: ValueKey('crisis_bar'))
                  : const SizedBox.shrink(key: ValueKey('crisis_bar_hidden')),
            ),

            // ── Quick Replies (Context Aware) ───────────────────────────────
            if (!isLoading && messages.isNotEmpty)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _buildQuickReplies(currentEmotion, todayMood, refuelLog, refuelNotifier),
              ),
            
                  // ── Input Area ──────────────────────────────────────────────────
                  _buildInputArea(hasEnergy),
                ],
              ),
              
              // ── Tutorial Overlay ──────────────────────────────────────
              if (showTutorial) const ChatTutorialOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(
    String emotion, 
    MoodLog? todayMood, 
    dynamic refuelLog, 
    dynamic refuelNotifier
  ) {
    final bool moodLogged = todayMood != null;
    List<Widget> chips = [];

    // 1. Physical Health Nudge (High Priority if hungry)
    if (refuelNotifier.shouldNudge()) {
      chips.add(_buildChip("I haven't eaten", PhosphorIconsRegular.hamburger, openRoute: AppRoutes.dashboard));
    }

    // 2. Emotional Response Logic
    if (emotion == AppConstants.kellyConcerned || emotion == AppConstants.kellySad) {
      // Feeling down: offer relief tools or simple venting
      chips.addAll([
        _buildChip("Try Breathing", PhosphorIconsRegular.wind, openRoute: AppRoutes.breathing),
        if (!moodLogged) 
          _buildChip("Log this mood", PhosphorIconsRegular.pencilLine, openRoute: AppRoutes.moodTracking),
        _buildChip("I'm overwhelmed", PhosphorIconsRegular.warningCircle, openRoute: AppRoutes.crisis),
      ]);
    } else if (emotion == AppConstants.kellyHappy || emotion == AppConstants.kellyExcited) {
      // Feeling good: celebrate or track progress
      chips.addAll([
        if (!moodLogged)
          _buildChip("Log my happy mood", PhosphorIconsRegular.smiley, openRoute: AppRoutes.moodTracking)
        else
          _buildChip("View my Progress", PhosphorIconsRegular.trendUp, openRoute: AppRoutes.progress),
        _buildChip("Thanks, Kelly!", PhosphorIconsRegular.heart),
      ]);
    } else {
      // Neutral or other states
      chips.addAll([
        _buildChip("I feel stressed", PhosphorIconsRegular.cloudRain),
        if (!moodLogged)
          _buildChip("Log my mood", PhosphorIconsRegular.smiley, openRoute: AppRoutes.moodTracking),
        _buildChip("Academic Help", PhosphorIconsRegular.books, openRoute: AppRoutes.planner),
      ]);
    }

    // Remove duplicates and limit
    final uniqueChips = chips.take(4).toList();

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) => chips[index],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {String? openRoute}) {
    return ActionChip(
      avatar: PhosphorIcon(icon, size: 16, color: AppColors.primaryDark),
      label: Text(label, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.1),
      onPressed: () {
        if (openRoute != null) {
          context.go(openRoute);
        } else {
          // Send the chip label as a message to Kelly
          _messageController.text = label;
          _sendMessage();
        }
      },
    );
  }

  Widget _buildInputArea(bool hasEnergy) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(top: BorderSide(color: AppColors.primary.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: hasEnergy,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium.copyWith(
                color: hasEnergy ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: hasEnergy ? 'Message Kelly...' : 'Kelly is resting...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: hasEnergy ? AppColors.background : AppColors.surfaceSecondary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: hasEnergy ? (_) => _sendMessage() : null,
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: hasEnergy ? _sendMessage : null,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: hasEnergy ? AppColors.primary : AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                hasEnergy ? PhosphorIconsRegular.paperPlaneTilt : PhosphorIconsRegular.coffee, 
                color: hasEnergy ? Colors.white : AppColors.textTertiary, 
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}