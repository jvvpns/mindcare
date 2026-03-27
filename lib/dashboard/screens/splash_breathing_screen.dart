import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';

class SplashBreathingScreen extends StatefulWidget {
  const SplashBreathingScreen({super.key});

  @override
  State<SplashBreathingScreen> createState() => _SplashBreathingScreenState();
}

class _SplashBreathingScreenState extends State<SplashBreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
       vsync: this, 
       duration: const Duration(milliseconds: 3000), // 3-second breathing cycle
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.6).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.6, end: 1.0).chain(CurveTween(curve: Curves.easeInOutSine)), weight: 50),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _fadingOut = true);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go(AppRoutes.dashboard);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedOpacity(
        opacity: _fadingOut ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 64),
              Text(
                "Take a deep breath...",
                style: AppTextStyles.headingSmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
