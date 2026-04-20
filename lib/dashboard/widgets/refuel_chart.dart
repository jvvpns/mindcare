import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../providers/refuel_provider.dart';
import '../../shared/widgets/hilway_card.dart';

class RefuelChart extends ConsumerWidget {
  const RefuelChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refuelLog = ref.watch(refuelProvider);
    final notifier = ref.read(refuelProvider.notifier);

    if (refuelLog == null) return const SizedBox.shrink();

    return HilwayCard(
      isGlass: true,
      glowColor: Colors.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PhosphorIcon(PhosphorIconsFill.coffee, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Clinical Refuel Chart',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              if (notifier.shouldNudge())
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nudge',
                    style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RefuelButton(
                label: 'Breakfast',
                time: '7:00 AM',
                icon: PhosphorIconsRegular.egg,
                isActive: refuelLog.hasBreakfast,
                onTap: () => notifier.logRefuel(breakfast: !refuelLog.hasBreakfast),
              ),
              _RefuelButton(
                label: 'Lunch',
                time: '11:30 AM',
                icon: PhosphorIconsRegular.bowlFood,
                isActive: refuelLog.hasLunch,
                onTap: () => notifier.logRefuel(lunch: !refuelLog.hasLunch),
              ),
              _RefuelButton(
                label: 'Dinner',
                time: '7:00 PM',
                icon: PhosphorIconsRegular.cookingPot,
                isActive: refuelLog.hasDinner,
                onTap: () => notifier.logRefuel(dinner: !refuelLog.hasDinner),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Keep your physical vitals stable for better clinical focus.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _RefuelButton extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _RefuelButton({
    required this.label,
    required this.time,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            PhosphorIcon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              time,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary.withValues(alpha: 0.7) : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
