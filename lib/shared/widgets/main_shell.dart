import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/providers/update_provider.dart';
import '../../core/constants/app_constants.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    const routes = [
      AppRoutes.dashboard,
      AppRoutes.progress,
      AppRoutes.planner,
      AppRoutes.profile,
    ];
    final idx = routes.indexWhere((r) => location.startsWith(r));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _selectedIndex(context);
    final hasUpdate = ref.watch(updateProvider);

    return Scaffold(
      body: Column(
        children: [
          if (hasUpdate)
            MaterialBanner(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(PhosphorIconsFill.sparkle, color: Colors.white),
              content: Text(
                'A new version of HILWAY is available!',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              actions: [
                TextButton(
                  onPressed: () => ref.read(updateProvider.notifier).updateApp(),
                  child: Text(
                    'UPDATE NOW',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          Expanded(child: child),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            context.push(AppRoutes.chatbot);
          },
          customBorder: const CircleBorder(),
          child: Hero(
            tag: 'kelly_orb_hero',
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: PhosphorIcon(PhosphorIconsFill.firstAid, color: Colors.white, size: 28),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomAppBar(
          color: AppColors.surface,
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          elevation: 0,
          padding: EdgeInsets.zero,
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    label: 'Home',
                    icon: PhosphorIconsRegular.house,
                    activeIcon: PhosphorIconsFill.house,
                    route: AppRoutes.dashboard,
                    isActive: selectedIndex == 0,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Mood',
                    icon: PhosphorIconsRegular.smiley,
                    activeIcon: PhosphorIconsFill.smiley,
                    route: AppRoutes.progress,
                    isActive: selectedIndex == 1,
                  ),
                  const SizedBox(width: 56), // FAB space
                  _buildNavItem(
                    context,
                    label: 'Planner',
                    icon: PhosphorIconsRegular.calendarBlank,
                    activeIcon: PhosphorIconsFill.calendarBlank,
                    route: AppRoutes.planner,
                    isActive: selectedIndex == 2,
                  ),
                  _buildNavItem(
                    context,
                    label: 'Profile',
                    icon: PhosphorIconsRegular.user,
                    activeIcon: PhosphorIconsFill.user,
                    route: AppRoutes.profile,
                    isActive: selectedIndex == 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required String route,
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          context.go(route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}