import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';

/// Animated brand logo for StudyFlow AI.
///
/// Wraps the [CustomPaint] logo graphic in three independently looping
/// animation layers:
///
/// - **Pulse** – scales the logo between 0.95× and 1.05× over 1800 ms.
/// - **Float** – translates the logo vertically ±8 dp over 3000 ms.
/// - **Rotating light** – sweeps a conic gradient around the background
///   circle, completing 360 ° every 6000 ms.
///
/// All three [AnimationController]s are owned by this widget and disposed
/// in [dispose].
///
/// **Rive / Lottie swap ready**: pass a [child] to replace the built-in
/// [CustomPaint] logo. The glow, pulse, float, and rotating-light effects
/// continue to apply unchanged.
///
/// **Reduced-motion**: when [MediaQuery.disableAnimations] is `true` all
/// looping animations are skipped and the widget renders at its static state
/// (scale 1.0, offset 0 dp, rotation 0 °).
class AppLogoWidget extends StatefulWidget {
  const AppLogoWidget({super.key, this.child});

  /// Optional replacement graphic (e.g., a Rive/Lottie widget).
  /// When null the built-in [CustomPaint] book-and-bolt mark is used.
  final Widget? child;

  @override
  State<AppLogoWidget> createState() => _AppLogoWidgetState();
}

class _AppLogoWidgetState extends State<AppLogoWidget>
    with TickerProviderStateMixin {
  // Pulse: 0.95 → 1.05 → 0.95 over 1800 ms
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  // Float: -8 dp → +8 dp → -8 dp over 3000 ms
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // Rotating light: 0 → 2π over 6000 ms
  late final AnimationController _rotateCtrl;
  late final Animation<double> _rotateAnim;

  static const double _logoSize = 100.0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _rotateAnim = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      _rotateCtrl,
    );

    // Animations start after the first frame so that
    // MediaQuery is available in didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAnimationsIfAllowed();
  }

  void _startAnimationsIfAllowed() {
    final bool reduced = MediaQuery.of(context).disableAnimations;
    if (reduced) return;

    if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    if (!_floatCtrl.isAnimating) _floatCtrl.repeat(reverse: true);
    if (!_rotateCtrl.isAnimating) _rotateCtrl.repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduced = MediaQuery.of(context).disableAnimations;

    if (reduced) {
      return _buildLogoStack(
        scale: 1.0,
        translateY: 0.0,
        rotation: 0.0,
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _floatAnim, _rotateAnim]),
      builder: (context, _) {
        return _buildLogoStack(
          scale: _pulseAnim.value,
          translateY: _floatAnim.value,
          rotation: _rotateAnim.value,
        );
      },
    );
  }

  Widget _buildLogoStack({
    required double scale,
    required double translateY,
    required double rotation,
  }) {
    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: SizedBox(
          width: _logoSize,
          height: _logoSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Outer glow halo ──────────────────────────────────────────
              Container(
                width: _logoSize * 1.6,
                height: _logoSize * 1.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.40),
                      AppColors.secondary.withValues(alpha: 0.18),
                      AppColors.secondary.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),

              // ── Rotating light sweep ─────────────────────────────────────
              Transform.rotate(
                angle: rotation,
                child: Container(
                  width: _logoSize * 1.15,
                  height: _logoSize * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.secondaryLight.withValues(alpha: 0.0),
                        AppColors.secondaryLight.withValues(alpha: 0.30),
                        AppColors.secondaryLight.withValues(alpha: 0.0),
                        AppColors.secondaryLight.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.25, 0.50, 1.0],
                    ),
                  ),
                ),
              ),

              // ── Logo graphic ─────────────────────────────────────────────
              SizedBox(
                width: _logoSize,
                height: _logoSize,
                child: widget.child ?? CustomPaint(painter: _AppLogoPainter()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Internal logo painter ─────────────────────────────────────────────────────

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Background circle ──────────────────────────────────────────────────
    final Paint bgPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

    // Subtle border ring
    final Paint ringPaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.47, ringPaint);

    // ── Left page of open book ─────────────────────────────────────────────
    final Paint leftPagePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final Path leftPage = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.42, h * 0.37, w * 0.20, h * 0.38, w * 0.18, h * 0.42)
      ..lineTo(w * 0.18, h * 0.72)
      ..cubicTo(w * 0.20, h * 0.68, w * 0.42, h * 0.67, w * 0.50, h * 0.70)
      ..close();
    canvas.drawPath(leftPage, leftPagePaint);

    final Paint leftLinePaint = Paint()
      ..color = AppColors.onPrimary.withValues(alpha: 0.35)
      ..strokeWidth = h * 0.022
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final double y = h * (0.50 + i * 0.065);
      canvas.drawLine(Offset(w * 0.24, y), Offset(w * 0.46, y), leftLinePaint);
    }

    // ── Right page of open book ────────────────────────────────────────────
    final Paint rightPagePaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final Path rightPage = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.58, h * 0.37, w * 0.80, h * 0.38, w * 0.82, h * 0.42)
      ..lineTo(w * 0.82, h * 0.72)
      ..cubicTo(w * 0.80, h * 0.68, w * 0.58, h * 0.67, w * 0.50, h * 0.70)
      ..close();
    canvas.drawPath(rightPage, rightPagePaint);

    final Paint rightLinePaint = Paint()
      ..color = AppColors.onTertiary.withValues(alpha: 0.35)
      ..strokeWidth = h * 0.022
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 3; i++) {
      final double y = h * (0.50 + i * 0.065);
      canvas.drawLine(
          Offset(w * 0.54, y), Offset(w * 0.76, y), rightLinePaint);
    }

    // ── Spine shadow ───────────────────────────────────────────────────────
    final Paint spinePaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.20)
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.50, h * 0.40), Offset(w * 0.50, h * 0.70), spinePaint);

    // ── Lightning bolt ─────────────────────────────────────────────────────
    final Paint boltGlowPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    final Paint boltPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final Path bolt = Path()
      ..moveTo(w * 0.555, h * 0.16)
      ..lineTo(w * 0.460, h * 0.30)
      ..lineTo(w * 0.520, h * 0.30)
      ..lineTo(w * 0.445, h * 0.44)
      ..lineTo(w * 0.540, h * 0.30)
      ..lineTo(w * 0.480, h * 0.30)
      ..lineTo(w * 0.575, h * 0.16)
      ..close();

    canvas.drawPath(bolt, boltGlowPaint);
    canvas.drawPath(bolt, boltPaint);

    // Sparkle dots
    final Paint sparklePaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.38, h * 0.22), w * 0.025, sparklePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.20), w * 0.018, sparklePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.30), w * 0.013, sparklePaint);
  }

  @override
  bool shouldRepaint(_AppLogoPainter old) => false;
}
