import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/burnout_risk.dart';

class WellnessGauge extends StatefulWidget {
  final double score; // 0.0 to 1.0
  final BurnoutLevel level;
  final String label;
  final bool isLocked;

  const WellnessGauge({
    super.key,
    required this.score,
    required this.level,
    required this.label,
    this.isLocked = false,
  });

  @override
  State<WellnessGauge> createState() => _WellnessGaugeState();
}

class _WellnessGaugeState extends State<WellnessGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void didUpdateWidget(WellnessGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: oldWidget.score,
        end: widget.score,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90,
          width: 160,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _GaugePainter(
                    score: _scoreAnimation.value,
                    level: widget.level,
                    isLocked: widget.isLocked,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'AI Resilience Scan',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final BurnoutLevel level;
  final bool isLocked;

  _GaugePainter({
    required this.score, 
    required this.level, 
    this.isLocked = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // ── Background Arc (With Inner Shadow depth) ──────────────────────────
    final bgPaint = Paint()
      ..color = AppColors.surfaceSecondary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // Draw the main background
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );
    
    // Draw a subtle "inner depth" highlight
    final depthPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      math.pi,
      math.pi,
      false,
      depthPaint,
    );

    // ── Active Gradient Arc ──────────────────────────────────────────────────
    List<Color> colors = [
      AppColors.crisis,          // Left
      AppColors.moodConcerned,   // Mid
      AppColors.moodHappy,       // Right
    ];

    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: math.pi * 2,
      colors: colors,
      stops: const [0.1, 0.5, 0.9],
    );

    final rect = Rect.fromCircle(center: center, radius: radius);

    final activePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi * score,
      false,
      activePaint,
    );

    // ── Needle Indicator ─────────────────────────────────────────────────────
    final needleAngle = math.pi + (math.pi * score);
    final needleRadius = radius + 4;
    final needlePos = Offset(
      center.dx + needleRadius * math.cos(needleAngle),
      center.dy + needleRadius * math.sin(needleAngle),
    );

    // Needle shadow/glow
    final glowColor = _getLevelColor(level).withValues(alpha: 0.4);

    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(needlePos, 8, glowPaint);

    final needlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(needlePos, 5, needlePaint);

    // Inner circle (cap) - Cleaner pivot
    final pivotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, pivotPaint);
    canvas.drawCircle(center, 3, Paint()..color = Colors.white);
  }

  Color _getLevelColor(BurnoutLevel level) {
    switch (level) {
      case BurnoutLevel.low:
        return AppColors.moodHappy;
      case BurnoutLevel.medium:
        return AppColors.moodConcerned;
      case BurnoutLevel.high:
        return AppColors.crisis;
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.score != score;
}
