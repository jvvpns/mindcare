import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Kelly Avatar ─────────────────────────────────────────────
          if (!isUser) ...[
            _KellyAvatar(emotion: message.detectedEmotion),
            const SizedBox(width: 10),
          ],

          // ── Bubble ───────────────────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: isUser ? 52 : 0,
                    right: isUser ? 0 : 52,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: isUser
                      ? _userBubbleDecoration()
                      : _kellyBubbleDecoration(),
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isUser ? Colors.white : AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // ── Timestamp row ─────────────────────────────────
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('hh:mm a').format(message.timestamp),
                            style: AppTextStyles.caption.copyWith(
                              color: isUser
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              PhosphorIconsRegular.checkCircle,
                              size: 10,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Suggested Action Button ────────────────────────────
                if (message.suggestedAction != null) ...[
                  const SizedBox(height: 8),
                  _SuggestedActionButton(route: message.suggestedAction!),
                ],
              ],
            ),
          ),

          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  BoxDecoration _userBubbleDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0288D1), Color(0xFF5E35B1)],
      ),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(4),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0288D1).withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  BoxDecoration _kellyBubbleDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.9),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

// ── Kelly Avatar ─────────────────────────────────────────────────────────────
class _KellyAvatar extends StatelessWidget {
  final String? emotion;
  const _KellyAvatar({this.emotion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.20),
            AppColors.primary.withValues(alpha: 0.15),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: _emotionChild(emotion)),
    );
  }

  Widget _emotionChild(String? e) {
    if (e == null || e == AppConstants.kellyDefault) {
      return const PhosphorIcon(PhosphorIconsRegular.firstAid, size: 18, color: AppColors.accent);
    }
    final Map<String, String> map = {
      AppConstants.kellySad: '😔',
      AppConstants.kellyConcerned: '😟',
      AppConstants.kellyHappy: '😊',
      AppConstants.kellyExcited: '😄',
      AppConstants.kellyCalm: '😌',
      AppConstants.kellySurprised: '😮',
    };
    final emoji = map[e];
    if (emoji == null) return const PhosphorIcon(PhosphorIconsRegular.firstAid, size: 18, color: AppColors.accent);
    return Text(emoji, style: const TextStyle(fontSize: 18));
  }
}

// ── Suggested Action Button ───────────────────────────────────────────────────
class _SuggestedActionButton extends StatelessWidget {
  final String route;
  const _SuggestedActionButton({required this.route});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PhosphorIcon(PhosphorIconsRegular.wind, size: 16, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text(
              'Start Breathing Exercise',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
