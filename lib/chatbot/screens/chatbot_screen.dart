import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/kelly_state_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/reaction_log_sheet.dart';

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

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch Kelly's current emotion for the Hero Header asset
    final currentEmotion = ref.watch(kellyEmotionProvider);
    // Watch Chat State
    final messages = ref.watch(chatMessagesProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    // Auto-scroll when new messages arrive
    ref.listen(chatMessagesProvider, (_, __) => Future.delayed(const Duration(milliseconds: 100), _scrollToBottom));
    ref.listen(chatLoadingProvider, (_, __) => Future.delayed(const Duration(milliseconds: 100), _scrollToBottom));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header & Hero Transition ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: "Reaction Log (Debug)",
                    icon: const Icon(Icons.bug_report_outlined, color: AppColors.textSecondary),
                    onPressed: () => ReactionLogSheet.show(context),
                  ),
                ],
              ),
            ),
            
            Hero(
              tag: 'kelly_chat_fab',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  alignment: Alignment.center,
                  // In phase 4.5+, this gets swapped with RiveAnimation.network or local files
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Tooltip(
                      message: 'Kelly state: $currentEmotion',
                      child: const Icon(Icons.pets, size: 72, color: AppColors.accent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // ── Chat List Area ──────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: messages.length + (isLoading ? 1 : 0) + 1, // +1 for security banner
                itemBuilder: (context, index) {
                  // Security Banner is the first item
                  if (index == 0) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "🔒 Your conversations are stored locally.",
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    );
                  }

                  // Typing Indicator is the last item if loading
                  if (isLoading && index == messages.length + 1) {
                    return const TypingIndicator();
                  }

                  final message = messages[index - 1];
                  return ChatMessageBubble(message: message);
                },
              ),
            ),
            
            // ── Input Area ──────────────────────────────────────────────
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Message Kelly...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _sendMessage,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}