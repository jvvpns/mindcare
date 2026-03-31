import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../providers/chat_safety_provider.dart';

/// A high-visibility persistent banner shown when crisis-level keywords
/// are detected in the user's messages. Remains active for the entire session.
class PriorityCrisisBar extends ConsumerWidget {
  const PriorityCrisisBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFC62828),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE53935).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    const PhosphorIcon(
                      PhosphorIconsRegular.warningCircle,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'You are not alone',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Immediate support is available. You don't have to go through this alone.",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons Row
                Row(
                  children: [
                    // Primary — Go to Crisis Screen
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.push(AppRoutes.crisis),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsRegular.firstAidKit,
                                size: 16,
                                color: Color(0xFFC62828),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Get Support',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: const Color(0xFFC62828),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Secondary — Hotline number
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const PhosphorIcon(
                              PhosphorIconsRegular.phone,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppConstants.hotlineNationalMH,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const PhosphorIcon(
                PhosphorIconsRegular.x,
                size: 16,
                color: Colors.white70, // Subtle, complementary color
              ),
              onPressed: () => ref.read(isCrisisActiveProvider.notifier).state = false,
            ),
          ),
        ],
      ),
    );
  }
}
