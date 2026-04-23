import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../core/providers/debug_provider.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/notification_permission_provider.dart';
import '../../shared/widgets/hilway_background.dart';
import '../../shared/widgets/responsive_wrapper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final isDebugMode = ref.watch(debugModeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.headingSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: HilwayBackground(
        child: SafeArea(
          child: ResponsiveWrapper(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
  
                  // Preferences
                  const Text('Preferences', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  if (!kIsWeb) ...[
                    _buildSettingsTile(
                      icon: Theme.of(context).platform == TargetPlatform.iOS ? PhosphorIconsRegular.heartbeat : PhosphorIconsRegular.pulse,
                      title: Theme.of(context).platform == TargetPlatform.iOS ? 'Sync Apple Health' : 'Sync Health Connect',
                      subtitle: 'Connect sleep & mindfulness data',
                      onTap: () async {
                        final authorized = await ref.read(sleepDurationProvider.notifier).authorizeAndFetch();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authorized ? 'Health Data Synced!' : 'Sync failed or denied.'),
                              backgroundColor: authorized ? AppColors.success : AppColors.error,
                            ),
                          );
                        }
                      },
                      trailing: const Icon(PhosphorIconsRegular.caretRight, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _buildSettingsTile(
                    icon: PhosphorIconsRegular.bell,
                    title: 'Notifications',
                    subtitle: 'Reminders for duty & reflection',
                    onTap: () => ref.read(notificationPermissionProvider.notifier).toggle(!ref.read(notificationPermissionProvider)),
                    trailing: Switch(
                      value: ref.watch(notificationPermissionProvider),
                      onChanged: (val) => ref.read(notificationPermissionProvider.notifier).toggle(val),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: PhosphorIconsRegular.moon,
                    title: 'Dark Mode',
                    subtitle: 'System Default',
                    onTap: () {},
                    trailing: const Icon(PhosphorIconsRegular.caretRight, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: PhosphorIconsRegular.bug,
                    title: 'Debug Mode',
                    subtitle: 'Developer diagnostic tools',
                    onTap: () => ref.read(debugModeProvider.notifier).state = !isDebugMode,
                    trailing: Switch(
                      value: isDebugMode,
                      onChanged: (val) => ref.read(debugModeProvider.notifier).state = val,
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
  
                  const SizedBox(height: 32),
                  
                  // Support
                  const Text('Support', style: AppTextStyles.labelLarge),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: PhosphorIconsRegular.question,
                    title: 'Help & FAQ',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildSettingsTile(
                    icon: PhosphorIconsRegular.shieldCheck,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
  
                  const SizedBox(height: 40),
  
                  // Sign Out
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: () => _showSignOutConfirmation(context, ref),
                      icon: const PhosphorIcon(PhosphorIconsRegular.signOut, color: AppColors.error),
                      label: Text('Sign Out', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'HILWAY v1.2.2',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary.withValues(alpha: 0.5),
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Made with',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              PhosphorIconsFill.heart,
                              color: AppColors.error,
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'for student nurses in',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Roxas City, Capiz',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out?', style: AppTextStyles.headingSmall),
        content: const Text(
          'Are you sure you want to sign out? Your clinical data is safely synced to the cloud.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(icon, color: AppColors.textPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}