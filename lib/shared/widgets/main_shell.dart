import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home',    icon: Icons.home_outlined,           activeIcon: Icons.home,              route: AppRoutes.dashboard),
    _NavItem(label: 'Mood',    icon: Icons.mood_outlined,           activeIcon: Icons.mood,              route: AppRoutes.moodTracking),
    _NavItem(label: 'Planner', icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today,    route: AppRoutes.planner),
    _NavItem(label: 'Profile', icon: Icons.person_outline,          activeIcon: Icons.person,            route: AppRoutes.settings),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _items.indexWhere((item) => location.startsWith(item.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Hero(
        tag: 'kelly_chat_fab',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(AppRoutes.chatbot), // Use push to allow back navigation
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.pets, color: Colors.white, size: 32),
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
          notchMargin: 8,
          elevation: 0,
          padding: EdgeInsets.zero,
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(context, _items[0], selectedIndex == 0),
                  _buildNavItem(context, _items[1], selectedIndex == 1),
                  const SizedBox(width: 64), // Space for FAB
                  _buildNavItem(context, _items[2], selectedIndex == 2),
                  _buildNavItem(context, _items[3], selectedIndex == 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item, bool isActive) {
    return Expanded(
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}