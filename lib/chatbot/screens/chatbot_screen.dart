import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/kelly_emotion_service.dart';
import '../providers/kelly_state_provider.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Simulate sentiment detection and set Kelly's emotion
    final detectedEmotion = KellyEmotionService.detectEmotion(text);
    ref.read(kellyEmotionProvider.notifier).state = detectedEmotion;

    // TODO: Phase 4.5+ actual messaging logic
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Current state from the provider
    final currentEmotion = ref.watch(kellyEmotionProvider);

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
                ],
              ),
            ),
            
            Hero(
              tag: 'kelly_chat_fab',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  alignment: Alignment.center,
                  // In phase 4, this gets swapped with RiveAnimation.network or local
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Tooltip(
                      message: 'Kelly state: $currentEmotion',
                      child: const Icon(Icons.pets, size: 80, color: AppColors.accent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // ── Chat List Area ──────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Center(
                    child: Container(
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
                  ),
                  const SizedBox(height: 24),
                  
                  // Initial Placeholder
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(right: 48),
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Hi! I'm Kelly. I'm here to listen. How are you feeling right now?",
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                  ),
                ],
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