import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/services/hive_service.dart';
import '../../shared/widgets/responsive_wrapper.dart';
import '../../chatbot/widgets/kelly_orb_mascot.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = AppConstants.tutorialSteps.length;

  final List<IconData> _icons = [
    Icons.favorite_rounded,
    Icons.pets_rounded, // Not used anymore for Kelly
    Icons.mood_rounded,
    Icons.calendar_today_rounded,
    Icons.support_agent_rounded,
  ];

  final List<Color> _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
    AppColors.primary,
    AppColors.secondary,
  ];

  // ── Orb Animation State ────────────────────────────────────────────────
  Timer? _emotionTimer;
  int _emotionIndex = 0;
  
  List<String> get _orbEmotions => [
    AppConstants.kellyDefault,
    AppConstants.kellyHappy,
    AppConstants.kellyCalm,
    AppConstants.kellyConcerned,
  ];

  @override
  void initState() {
    super.initState();
    _emotionTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (mounted && _currentPage == 1) {
        setState(() {
          _emotionIndex = (_emotionIndex + 1) % _orbEmotions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _emotionTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await HiveService.settingsBox.put('tutorial_seen', true);
    if (!mounted) return;
    context.go(AppRoutes.dashboard);
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveWrapper(
          child: Column(
            children: [
              // ── Skip Button ─────────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 20),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
  
              // ── Pages ───────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _totalPages,
                  itemBuilder: (context, index) {
                    final step = AppConstants.tutorialSteps[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Illustration placeholder
                          if (index == 1)
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Center(
                                child: KellyOrbMascot(
                                  emotion: _orbEmotions[_emotionIndex],
                                  size: 100,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: index == 0 ? Colors.white : _colors[index].withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                boxShadow: index == 0 ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ] : null,
                              ),
                              child: index == 0 
                                ? Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Image.asset(
                                      'assets/images/hilway_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Icon(
                                    _icons[index],
                                    size: 64,
                                    color: _colors[index],
                                  ),
                            ),
                          const SizedBox(height: 36),
                          Text(
                            step['title']!,
                            style: AppTextStyles.headingLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step['subtitle']!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: _colors[index],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            step['body']!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
  
              // ── Dots indicator ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalPages, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.borderMedium,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
  
              const SizedBox(height: 32),
  
              // ── Next / Done Button ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(
                    _currentPage == _totalPages - 1 ? "Let's go!" : 'Next',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}