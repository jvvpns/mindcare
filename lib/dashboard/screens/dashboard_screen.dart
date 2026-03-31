import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/widgets/hilway_card.dart';
import '../../mood_tracking/providers/mood_provider.dart';
import '../../mood_tracking/widgets/mood_bottom_sheet.dart';
import '../../progress/providers/progress_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final userName = user?.email?.split('@').first ?? 'Guiding Star';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(userName),
                  const SizedBox(height: 32),
                  
                  // Swipeable Highlight Carousel
                  const DashboardCarousel(),
                  const SizedBox(height: 24),

                  _buildMoodCheckerRow(context, ref),
                  const SizedBox(height: 32),

                  _buildDashboardGrid(context, ref),
                  const SizedBox(height: 48), // Bottom padding
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_capitalize(name)} 👋',
                style: AppTextStyles.displayMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                "Take a deep breath, you've got this.",
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8), // Align slightly with the name line
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const PhosphorIcon(
            PhosphorIconsRegular.bell,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMoodCheckerRow(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayMoodProvider);

    return HilwayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todayLog == null ? "How are you feeling today?" : "You're feeling ${todayLog.moodLabel}",
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(AppConstants.moodEmojis.length, (index) {
              final isSelected = todayLog != null && todayLog.moodIndex == index;
              
              return GestureDetector(
                onTap: () {
                  if (todayLog == null) {
                    MoodBottomSheet.show(context, index);
                  }
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.moodEmojis[index],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.moodLabels[index],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, WidgetRef ref) {
    final weeklyProgress = ref.watch(weeklyProgressProvider);
    
    // Map data to chart spots. If no rating is found, fallback to 3 (neutral) or connect dots?
    // Let's fallback to previous day's rating or a baseline of 1 to keep the line continuous.
    int lastVal = 1;
    final spots = List.generate(7, (i) {
      if (weeklyProgress.length > i) {
        final val = weeklyProgress[i].stressRating;
        if (val != null) {
          lastVal = val;
          return FlSpot(i.toDouble(), val.toDouble());
        }
      }
      return FlSpot(i.toDouble(), lastVal.toDouble());
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Activity", style: AppTextStyles.headingMedium),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: Tasks
            Expanded(
              flex: 5,
              child: HilwayCard(
                color: AppColors.secondary.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(16),
                onTap: () => context.go(AppRoutes.planner),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.checkCircle, color: AppColors.secondary, size: 20),
                        const SizedBox(width: 8),
                        Text("Next Duty", style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text("Return Demo", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    Text("Foley Catheter", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text("Today, 8:00 AM", style: AppTextStyles.caption.copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Right column: Stress Graph
            Expanded(
              flex: 6,
              child: HilwayCard(
                color: AppColors.accent.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(16),
                onTap: () => context.go(AppRoutes.progress),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsRegular.trendUp, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Text("Stress Trend", style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 70,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0, maxX: 6, minY: 0, maxY: 5,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.accent,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.accent.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class DashboardCarousel extends StatefulWidget {
  const DashboardCarousel({super.key});

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 112,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            physics: const BouncingScrollPhysics(),
            children: const [
              _CarouselCard(
                key: ValueKey('carousel_kelly'),
                title: "Kelly is here",
                subtitle: "It looks like you had a long shift. Want to debrief?",
                iconData: PhosphorIconsRegular.firstAid,
                route: AppRoutes.chatbot,
              ),
              _CarouselCard(
                key: ValueKey('carousel_burnout'),
                title: "Burnout Check",
                subtitle: "Take 2 minutes to assess your current stress levels.",
                iconData: PhosphorIconsRegular.clipboardText,
                route: '/burnout-assessment',
              ),
              _CarouselCard(
                key: ValueKey('carousel_journal'),
                title: "Daily Reflection",
                subtitle: "Write down one good thing that happened today.",
                iconData: PhosphorIconsRegular.bookOpenText,
                route: AppRoutes.journal,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final active = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: active ? 24 : 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final String route;

  const _CarouselCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return HilwayCard(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(horizontal: 4), // Small margin to prevent clipping shadow
      onTap: () {
        if (route == AppRoutes.journal) {
          // Journal route may not exist yet, just a toast or basic nav
          try {
            context.push(route);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Journal module coming soon!')),
            );
          }
        } else {
          context.push(route);
        }
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: PhosphorIcon(iconData, color: AppColors.accent, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}