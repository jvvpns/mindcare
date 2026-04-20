import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// A premium, minimalist abstract orb mascot for Kelly.
///
/// Features:
/// - Organic blob shape morphing via sinusoidal path deformation
/// - Dual-layer gradient rendering (inner glow + outer halo)
/// - Emotion-driven color transitions with smooth crossfades
/// - Thinking-state shimmer with accelerated pulse
/// - Pure orb — no icons, no text
class KellyOrbMascot extends StatefulWidget {
  final String emotion;
  final bool isThinking;
  final double size;

  const KellyOrbMascot({
    super.key,
    required this.emotion,
    this.isThinking = false,
    this.size = 120,
  });

  @override
  State<KellyOrbMascot> createState() => _KellyOrbMascotState();
}

class _KellyOrbMascotState extends State<KellyOrbMascot>
    with TickerProviderStateMixin {
  // ── Animation Controllers ─────────────────────────────────────────────────
  late AnimationController _breatheController;
  late AnimationController _morphController;
  late AnimationController _shimmerController;

  // ── Color Transition ──────────────────────────────────────────────────────
  late _OrbColors _currentColors;
  late _OrbColors _targetColors;
  double _colorTransition = 1.0;
  String _lastEmotion = '';

  @override
  void initState() {
    super.initState();

    // Breathing: slow, meditative scale pulse
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // Morphing: continuous blob deformation
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // Shimmer: faster pulse for thinking state
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _lastEmotion = widget.emotion;
    _currentColors = _getColorsForEmotion(widget.emotion);
    _targetColors = _currentColors;
  }

  @override
  void didUpdateWidget(covariant KellyOrbMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ── Emotion changed: start color crossfade ───────────────────────────────
    if (widget.emotion != _lastEmotion) {
      _currentColors = _OrbColors.lerp(
        _currentColors,
        _targetColors,
        _colorTransition,
      );
      _targetColors = _getColorsForEmotion(widget.emotion);
      _colorTransition = 0.0;
      _lastEmotion = widget.emotion;
    }

    // ── Thinking state: adjust breathing speed ───────────────────────────────
    if (widget.isThinking != oldWidget.isThinking) {
      _breatheController.duration = Duration(
        milliseconds: widget.isThinking ? 1600 : 3200,
      );
      if (_breatheController.isAnimating) {
        _breatheController
          ..stop()
          ..repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _morphController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size + 40, // Extra space for glow bleed
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _breatheController,
          _morphController,
          _shimmerController,
        ]),
        builder: (context, _) {
          // Advance the color crossfade
          if (_colorTransition < 1.0) {
            _colorTransition = (_colorTransition + 0.016).clamp(0.0, 1.0);
          }

          final colors = _OrbColors.lerp(
            _currentColors,
            _targetColors,
            Curves.easeInOut.transform(_colorTransition),
          );

          final breatheT = CurvedAnimation(
            parent: _breatheController,
            curve: Curves.easeInOutSine,
          ).value;

          final morphT = _morphController.value;
          final shimmerT = _shimmerController.value;

          return CustomPaint(
            painter: _KellyOrbPainter(
              breatheT: breatheT,
              morphT: morphT,
              shimmerT: shimmerT,
              colors: colors,
              isThinking: widget.isThinking,
              orbSize: widget.size,
            ),
            size: Size(double.infinity, widget.size + 40),
          );
        },
      ),
    );
  }

  // ── Emotion → Color Mapping ─────────────────────────────────────────────
  static _OrbColors _getColorsForEmotion(String emotion) {
    switch (emotion) {
      case AppConstants.kellyHappy:
        return _OrbColors(
          core: const Color(0xFFE1F5FE),      // Light sky blue
          mid: const Color(0xFF4FC3F7),       // Sky blue core
          halo: const Color(0xFFB3E5FC),      // Soft blue glow
          shimmer: Colors.white,
        );
      case AppConstants.kellyExcited:
        return _OrbColors(
          core: const Color(0xFFFFF9C4),       // Pale gold
          mid: const Color(0xFFFFD54F),        // Electric gold
          halo: const Color(0xFFFFF176),       // Bright yellow halo
          shimmer: Colors.white,
        );
      case AppConstants.kellySad:
        return _OrbColors(
          core: const Color(0xFFF3E5F5),       // Light lavender
          mid: const Color(0xFFB39DDB),        // Muted purple
          halo: const Color(0xFFD1C4E9),       // Soft purple haze
          shimmer: const Color(0xFFEDE7F6),    // Cool shimmer
        );
      case AppConstants.kellyConcerned:
        return _OrbColors(
          core: const Color(0xFFFFF3E0),       // Pale peach
          mid: const Color(0xFFFFAB91),        // Soft coral
          halo: const Color(0xFFFFCCBC),       // Warm amber glow
          shimmer: const Color(0xFFFFFDE7),    // Warm shimmer
        );
      case AppConstants.kellySurprised:
        return _OrbColors(
          core: Colors.white,
          mid: const Color(0xFFF06292),        // Bright pink
          halo: const Color(0xFFFCE4EC),       // Soft pink halo
          shimmer: Colors.white,
        );
      case AppConstants.kellyCalm:
        return _OrbColors(
          core: const Color(0xFFE0F2F1),       // Pale mint
          mid: const Color(0xFF4DB6AC),        // Deep teal
          halo: const Color(0xFFB2DFDB),       // Soft teal glow
          shimmer: const Color(0xFFE0F7FA),    // Cool shimmer
        );
      default: // kellyDefault
        return _OrbColors(
          core: const Color(0xFFF9F8F6),       // Off-white
          mid: const Color(0xFFE1E8F0),        // Soft blue-grey
          halo: const Color(0xFFECEFF1),       // Neutral glow
          shimmer: Colors.white,
        );
    }
  }
}

// ── Orb Color Set ───────────────────────────────────────────────────────────
class _OrbColors {
  final Color core;
  final Color mid;
  final Color halo;
  final Color shimmer;

  const _OrbColors({
    required this.core,
    required this.mid,
    required this.halo,
    required this.shimmer,
  });

  static _OrbColors lerp(_OrbColors a, _OrbColors b, double t) {
    return _OrbColors(
      core: Color.lerp(a.core, b.core, t)!,
      mid: Color.lerp(a.mid, b.mid, t)!,
      halo: Color.lerp(a.halo, b.halo, t)!,
      shimmer: Color.lerp(a.shimmer, b.shimmer, t)!,
    );
  }
}

// ── Custom Painter ──────────────────────────────────────────────────────────
class _KellyOrbPainter extends CustomPainter {
  final double breatheT;
  final double morphT;
  final double shimmerT;
  final _OrbColors colors;
  final bool isThinking;
  final double orbSize;

  const _KellyOrbPainter({
    required this.breatheT,
    required this.morphT,
    required this.shimmerT,
    required this.colors,
    required this.isThinking,
    required this.orbSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = orbSize / 2;

    // ── Scale: breathing ──────────────────────────────────────────────────
    final breatheScale = 0.92 + (breatheT * 0.16); // 0.92 → 1.08
    final radius = baseRadius * breatheScale;

    // ── Layer 1: Outer halo glow ─────────────────────────────────────────
    final haloRadius = radius * 1.6;
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.halo.withValues(alpha: 0.25 + (breatheT * 0.15)),
          colors.halo.withValues(alpha: 0.08),
          colors.halo.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: haloRadius));
    canvas.drawCircle(center, haloRadius, haloPaint);

    // ── Layer 2: Morphing blob shape ─────────────────────────────────────
    final blobPath = _buildBlobPath(center, radius, morphT);

    // Inner gradient fill
    final blobPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.core.withValues(alpha: 0.95),
          colors.mid.withValues(alpha: 0.75),
          colors.mid.withValues(alpha: 0.3),
        ],
        stops: const [0.0, 0.55, 1.0],
        center: Alignment(0.0, -0.2 + breatheT * 0.1),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(blobPath, blobPaint);

    // ── Layer 3: Glass border highlight ──────────────────────────────────
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.5),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.05),
          Colors.white.withValues(alpha: 0.5),
        ],
        startAngle: morphT * math.pi * 2,
        endAngle: morphT * math.pi * 2 + math.pi * 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawPath(blobPath, borderPaint);

    // ── Layer 4: Inner light spot (specular highlight) ───────────────────
    final highlightCenter = Offset(
      center.dx - radius * 0.22,
      center.dy - radius * 0.28,
    );
    final highlightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45 + (breatheT * 0.15)),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: highlightCenter, radius: radius * 0.45),
      );
    canvas.drawCircle(highlightCenter, radius * 0.45, highlightPaint);

    // ── Layer 5: Thinking shimmer particles ──────────────────────────────
    if (isThinking) {
      _drawShimmerParticles(canvas, center, radius, shimmerT);
    }
  }

  /// Builds an organic blob path using sinusoidal deformation.
  Path _buildBlobPath(Offset center, double radius, double t) {
    final path = Path();
    const int points = 80; // Smooth curve resolution

    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * math.pi * 2;

      // 3 overlapping sine waves for organic shape
      final deform = 1.0 +
          math.sin(angle * 3 + t * math.pi * 2) * 0.06 +
          math.sin(angle * 5 - t * math.pi * 4) * 0.03 +
          math.sin(angle * 7 + t * math.pi * 6) * 0.02;

      final r = radius * deform;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// Draws small shimmer particles orbiting the blob during thinking.
  void _drawShimmerParticles(
    Canvas canvas,
    Offset center,
    double radius,
    double t,
  ) {
    const int particleCount = 5;
    final rng = math.Random(42); // Fixed seed for deterministic positions

    for (int i = 0; i < particleCount; i++) {
      final baseAngle = (i / particleCount) * math.pi * 2;
      final angle = baseAngle + t * math.pi * 2;
      final particleRadius = radius * (1.15 + rng.nextDouble() * 0.25);
      final particleSize = 2.0 + rng.nextDouble() * 2.5;

      final px = center.dx + particleRadius * math.cos(angle);
      final py = center.dy + particleRadius * math.sin(angle);

      final opacity = (0.3 + t * 0.5).clamp(0.0, 0.8);
      final paint = Paint()
        ..color = colors.shimmer.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(px, py), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_KellyOrbPainter old) =>
      old.breatheT != breatheT ||
      old.morphT != morphT ||
      old.shimmerT != shimmerT ||
      old.colors != colors ||
      old.isThinking != isThinking;
}

// ── Mini Orb for Dashboard ──────────────────────────────────────────────────
/// A compact version of the Kelly orb for use in the Dashboard header.
/// Now uses the same organic morphing logic as the main mascot.
class KellyMiniOrb extends StatefulWidget {
  final String emotion;
  final double size;

  const KellyMiniOrb({
    super.key,
    required this.emotion,
    this.size = 36,
  });

  @override
  State<KellyMiniOrb> createState() => _KellyMiniOrbState();
}

class _KellyMiniOrbState extends State<KellyMiniOrb>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _morphController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _morphController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _KellyOrbMascotState._getColorsForEmotion(widget.emotion);

    return AnimatedBuilder(
      animation: Listenable.merge([_breatheController, _morphController, _floatController]),
      builder: (context, _) {
        // Gentle float: -3px to +3px
        final floatY = -3.0 + (_floatController.value * 6.0);
        
        return Transform.translate(
          offset: Offset(0, floatY),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _KellyOrbPainter(
                breatheT: _breatheController.value,
                morphT: _morphController.value,
                shimmerT: 0,
                colors: colors,
                isThinking: false,
                orbSize: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

