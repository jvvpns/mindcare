import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/philippines_schools.dart';
import '../../core/utils/user_extensions.dart';
import '../../auth/providers/auth_provider.dart';
import '../../chatbot/providers/kelly_state_provider.dart';
import '../../shared/widgets/hilway_background.dart';
import '../../shared/widgets/responsive_wrapper.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final authState = ref.watch(authProvider);
    final effectiveEmotion = ref.watch(globalBackgroundEmotionProvider);

    if (user == null) return const SizedBox.shrink();

    final schoolName = user.school;
    final schoolInfo = AppSchools.capizNursingSchools.where((s) => s.name == schoolName).firstOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: HilwayBackground(
        emotion: effectiveEmotion,
        child: ResponsiveWrapper(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 280,
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const PhosphorIcon(PhosphorIconsRegular.gear, color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Profile Header Content
                      SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            // Avatar
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surface.withValues(alpha: 0.5),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                                  style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Name
                            Text(
                              user.displayName,
                              style: AppTextStyles.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            // Email
                            Text(
                              user.email ?? '',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Academic Identity', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 16),
                      
                      // School Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: schoolInfo != null
                                    ? (schoolInfo.logoUrl.startsWith('http')
                                        ? Image.network(
                                            schoolInfo.logoUrl,
                                            fit: BoxFit.contain,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 15,
                                                  height: 15,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              );
                                            },
                                            errorBuilder: (_, __, ___) => const Icon(
                                              PhosphorIconsRegular.graduationCap,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          )
                                        : Image.asset(
                                            schoolInfo.logoUrl,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              PhosphorIconsRegular.graduationCap,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                          ))
                                    : const Icon(
                                        PhosphorIconsRegular.graduationCap,
                                        color: AppColors.primary,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schoolName,
                                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentLight.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          user.yearLevel,
                                          style: AppTextStyles.caption.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Nursing Student', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Extra space at bottom
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
