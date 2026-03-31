import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Center(
                child: _buildKellyChathead(message.detectedEmotion),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: isUser ? 48 : 0, 
                right: isUser ? 0 : 48
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser ? AppColors.primary.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(message.timestamp),
                        style: AppTextStyles.caption.copyWith(
                          color: isUser ? Colors.white70 : AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 4),
                        const PhosphorIcon(PhosphorIconsRegular.checkCircle, size: 10, color: Colors.white70),
                      ]
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) const SizedBox(width: 8), // Padding alignment for user
        ],
      ),
    );
  }

  /// Maps emotion string to an emoji for Kelly's chathead.
  /// Only shows emoji for non-default, meaningful emotional states.
  Widget _buildKellyChathead(String? emotion) {
    const defaultIcon = PhosphorIcon(
      PhosphorIconsRegular.firstAid,
      size: 16,
      color: AppColors.primary,
    );

    if (emotion == null || emotion == AppConstants.kellyDefault) {
      return defaultIcon;
    }

    final String emoji;
    switch (emotion) {
      case AppConstants.kellySad:
        emoji = '😔';
        break;
      case AppConstants.kellyConcerned:
        emoji = '😟';
        break;
      case AppConstants.kellyHappy:
        emoji = '😊';
        break;
      case AppConstants.kellyExcited:
        emoji = '😄';
        break;
      case AppConstants.kellyCalm:
        emoji = '😌';
        break;
      case AppConstants.kellySurprised:
        emoji = '😮';
        break;
      default:
        return defaultIcon;
    }

    return Text(emoji, style: const TextStyle(fontSize: 16));
  }
}
