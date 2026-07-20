import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Premium animated 3-D study scene for onboarding page 1 — "Study Smarter".
///
/// Replaces the old static [CustomPaint] with an animated composition:
///   • Book stack (3 perspective-skewed books) — floats up/down
///   • Glassmorphism note card    — floats with a 500 ms phase offset
///   • Calendar glass card        — floats with a 900 ms phase offset
///   • Assignment document card   — floats with a 300 ms phase offset
///   • Flashcard pair             — floats with a 700 ms phase offset
///   • Sparkle dots               — subtle ambient pulse
///
/// All animation controllers are owned here and disposed in [dispose].
/// The widget is a drop-in replacement — same class name, same constructor.
class OnboardingIllustration1 extends StatefulWidget {
  const OnboardingIllustration1({super.key});

  @override
  State<OnboardingIllustration1> createState() =>
      _OnboardingIllustration1State();
}

class _OnboardingIllustration1State extends State<OnboardingIllustration1>
    with TickerProviderStateMixin {
  // Main float controller — used by all floating elements at different phases
  late final AnimationController _floatCtrl;
  // Sparkle pulse controller
  late final AnimationController _sparkleCtrl;
  // Entrance fade
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _sparkleCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: SizedBox(
        height: AppSpacing.xxxl * 3, // 192 dp — same as old widget
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge([_floatCtrl, _sparkleCtrl]),
          builder: (context, _) {
            return CustomPaint(
              painter: _PremiumStudyScenePainter(
                floatT: _floatCtrl.value,
                sparkleT: _sparkleCtrl.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumStudyScenePainter extends CustomPainter {
  const _PremiumStudyScenePainter({
    required this.floatT,
    required this.sparkleT,
  });

  /// 0.0 → 1.0, looping (reverse=true), drives vertical float offsets.
  final double floatT;

  /// 0.0 → 1.0, looping (reverse=true), drives sparkle size.
  final double sparkleT;

  // ── Float helpers ────────────────────────────────────────────────────────

  /// Returns a vertical offset in dp for an element with [phaseOffset] (0–1).
  /// The amplitude is ±[amplitude] dp.
  double _floatY(double phaseOffset, {double amplitude = 6.0}) {
    final phase = (floatT + phaseOffset) % 1.0;
    // Smooth sine wave: -amplitude to +amplitude
    return amplitude * math.sin(phase * math.pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Soft background glow circles ────────────────────────────────────────
    _drawGlowCircle(canvas, Offset(w * 0.20, h * 0.20), w * 0.18,
        AppColors.secondary.withValues(alpha: 0.12));
    _drawGlowCircle(canvas, Offset(w * 0.82, h * 0.72), w * 0.14,
        AppColors.tertiary.withValues(alpha: 0.10));
    _drawGlowCircle(canvas, Offset(w * 0.75, h * 0.15), w * 0.10,
        AppColors.secondaryLight.withValues(alpha: 0.08));

    // ── Book stack (centred, floats with phase 0.0) ──────────────────────
    final bookFloat = _floatY(0.0, amplitude: 5.0);
    canvas.save();
    canvas.translate(0, bookFloat);
    _drawBookStack(canvas, w, h);
    canvas.restore();

    // ── Flashcard pair — top-right (phase 0.7) ───────────────────────────
    final fcFloat = _floatY(0.7, amplitude: 7.0);
    canvas.save();
    canvas.translate(w * 0.76, h * 0.10 + fcFloat);
    canvas.rotate(0.20);
    _drawFlashcard(canvas, w, h, isBack: true);
    canvas.restore();

    canvas.save();
    canvas.translate(w * 0.80, h * 0.08 + fcFloat);
    canvas.rotate(0.08);
    _drawFlashcard(canvas, w, h, isBack: false);
    canvas.restore();

    // ── Calendar card — top-left (phase 0.9) ─────────────────────────────
    final calFloat = _floatY(0.9, amplitude: 8.0);
    canvas.save();
    canvas.translate(w * 0.14, h * 0.10 + calFloat);
    canvas.rotate(-0.18);
    _drawCalendarCard(canvas, w, h);
    canvas.restore();

    // ── Assignment document — lower-right (phase 0.3) ────────────────────
    final assFloat = _floatY(0.3, amplitude: 6.0);
    canvas.save();
    canvas.translate(w * 0.84, h * 0.54 + assFloat);
    canvas.rotate(0.22);
    _drawAssignmentCard(canvas, w, h);
    canvas.restore();

    // ── Note card — lower-left (phase 0.5) ───────────────────────────────
    final noteFloat = _floatY(0.5, amplitude: 7.0);
    canvas.save();
    canvas.translate(w * 0.10, h * 0.58 + noteFloat);
    canvas.rotate(-0.20);
    _drawNoteCard(canvas, w, h);
    canvas.restore();

    // ── Sparkle accents ────────────────────────────────────────────────────
    final sparkleR = 0.012 + sparkleT * 0.006;
    _drawSparkle(canvas, Offset(w * 0.60, h * 0.06),
        w * sparkleR, AppColors.tertiary.withValues(alpha: 0.85));
    _drawSparkle(canvas, Offset(w * 0.22, h * 0.04),
        w * (sparkleR * 0.7), AppColors.secondaryLight.withValues(alpha: 0.75));
    _drawSparkle(canvas, Offset(w * 0.90, h * 0.34),
        w * (sparkleR * 0.65), AppColors.tertiary.withValues(alpha: 0.70));
    _drawSparkle(canvas, Offset(w * 0.06, h * 0.40),
        w * (sparkleR * 0.55), AppColors.secondaryLight.withValues(alpha: 0.65));
    _drawSparkle(canvas, Offset(w * 0.50, h * 0.95),
        w * (sparkleR * 0.5), AppColors.tertiary.withValues(alpha: 0.60));
  }

  // ── Book stack ────────────────────────────────────────────────────────────

  void _drawBookStack(Canvas canvas, double w, double h) {
    // Book 3 — bottom, widest, dark blue
    _drawBook(
      canvas: canvas, w: w, h: h,
      left: 0.14, top: 0.60, right: 0.86, bottom: 0.80,
      spineW: 0.058, skew: 0.012,
      coverColor: AppColors.secondaryDark,
    );
    // Book 2 — middle, secondary blue
    _drawBook(
      canvas: canvas, w: w, h: h,
      left: 0.18, top: 0.42, right: 0.82, bottom: 0.62,
      spineW: 0.052, skew: 0.010,
      coverColor: AppColors.secondary,
    );
    // Book 1 — top, teal accent
    _drawBook(
      canvas: canvas, w: w, h: h,
      left: 0.22, top: 0.24, right: 0.78, bottom: 0.44,
      spineW: 0.046, skew: 0.008,
      coverColor: AppColors.tertiary,
    );
  }

  void _drawBook({
    required Canvas canvas,
    required double w, required double h,
    required double left, required double top,
    required double right, required double bottom,
    required double spineW, required double skew,
    required Color coverColor,
  }) {
    final l = w * left;
    final t = h * top;
    final r = w * right;
    final b = h * bottom;
    final sw = w * spineW;
    final sk = w * skew;
    final bookH = b - t;

    // Shadow
    final shadowPaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    canvas.drawRRect(
      RRect.fromLTRBR(l + sw - sk, b - 2, r - sk, b + 10,
          const Radius.circular(4)),
      shadowPaint,
    );

    // Cover with subtle gradient
    final coverGrad = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          coverColor.withValues(alpha: 1.0),
          coverColor.withValues(alpha: 0.75),
        ],
      ).createShader(Rect.fromLTRB(l, t, r, b));

    final coverPath = Path()
      ..moveTo(l + sw + sk, t)
      ..lineTo(r + sk, t)
      ..lineTo(r - sk, b)
      ..lineTo(l + sw - sk, b)
      ..close();
    canvas.drawPath(coverPath, coverGrad);

    // Glossy sheen
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(l + sw + sk, t, r + sk, b));
    canvas.drawPath(coverPath, sheenPaint);

    // Spine
    final spinePaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    final spinePath = Path()
      ..moveTo(l + sk * 0.5, t + bookH * 0.03)
      ..lineTo(l + sw + sk, t)
      ..lineTo(l + sw - sk, b)
      ..lineTo(l - sk * 0.5, b - bookH * 0.03)
      ..close();
    canvas.drawPath(spinePath, spinePaint);

    // Cover stroke
    final strokePaint = Paint()
      ..color = coverColor.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003;
    canvas.drawPath(coverPath, strokePaint);

    // Text-row hints
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.0022
      ..strokeCap = StrokeCap.round;
    final coverL = l + sw + sk + w * 0.028;
    final coverR = r + sk - w * 0.038;
    final rowSpacing = bookH / 4.5;
    for (int i = 1; i <= 3; i++) {
      final ly = t + rowSpacing * (i + 0.2);
      final rowR = i.isEven ? coverL + (coverR - coverL) * 0.60 : coverR;
      canvas.drawLine(Offset(coverL, ly), Offset(rowR, ly), linePaint);
    }
  }

  // ── Glassmorphism note card ───────────────────────────────────────────────

  void _drawNoteCard(Canvas canvas, double w, double h) {
    final cw = w * 0.22;
    final ch = h * 0.26;
    _drawGlassCard(canvas, cw, ch, AppColors.secondary.withValues(alpha: 0.18),
        AppColors.secondaryLight.withValues(alpha: 0.30));
    // Lines
    final lp = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ch * 0.030
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final ly = -ch / 2 + ch * (0.30 + i * 0.17);
      final lx2 = i == 1 ? cw * 0.25 : cw * 0.42;
      canvas.drawLine(Offset(-cw * 0.40, ly), Offset(lx2, ly), lp);
    }
    // Small dot header
    final dp = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(-cw * 0.32, -ch * 0.35), cw * 0.055, dp);
  }

  // ── Calendar card ─────────────────────────────────────────────────────────

  void _drawCalendarCard(Canvas canvas, double w, double h) {
    final cw = w * 0.20;
    final ch = h * 0.24;
    _drawGlassCard(canvas, cw, ch, AppColors.tertiary.withValues(alpha: 0.16),
        AppColors.tertiaryLight.withValues(alpha: 0.28));

    // Header bar
    final headerPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final headerRect = RRect.fromLTRBR(
      -cw / 2 + 3, -ch / 2 + 3, cw / 2 - 3, -ch / 2 + ch * 0.28,
      const Radius.circular(5),
    );
    canvas.drawRRect(headerRect, headerPaint);

    // Grid of day dots
    final dotP = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final activeDotP = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;
    final dotR = cw * 0.065;
    final cols = 4;
    final rows = 3;
    final startX = -cw * 0.32;
    final startY = -ch * 0.10;
    final spacingX = cw * 0.22;
    final spacingY = ch * 0.22;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final ox = startX + c * spacingX;
        final oy = startY + r * spacingY;
        final isActive = r == 1 && c == 2;
        canvas.drawCircle(Offset(ox, oy), dotR, isActive ? activeDotP : dotP);
      }
    }
  }

  // ── Assignment document ───────────────────────────────────────────────────

  void _drawAssignmentCard(Canvas canvas, double w, double h) {
    final cw = w * 0.18;
    final ch = h * 0.22;
    final fold = cw * 0.20;

    // Dog-eared card
    final fillPaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final glassPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final cr = cw * 0.08;
    final cardPath = Path()
      ..moveTo(-cw / 2 + cr, -ch / 2)
      ..lineTo(cw / 2 - fold, -ch / 2)
      ..lineTo(cw / 2, -ch / 2 + fold)
      ..lineTo(cw / 2, ch / 2 - cr)
      ..quadraticBezierTo(cw / 2, ch / 2, cw / 2 - cr, ch / 2)
      ..lineTo(-cw / 2 + cr, ch / 2)
      ..quadraticBezierTo(-cw / 2, ch / 2, -cw / 2, ch / 2 - cr)
      ..lineTo(-cw / 2, -ch / 2 + cr)
      ..quadraticBezierTo(-cw / 2, -ch / 2, -cw / 2 + cr, -ch / 2)
      ..close();

    // Blur frosted glass
    canvas.saveLayer(null, Paint());
    canvas.drawPath(cardPath, fillPaint);
    canvas.drawPath(cardPath, glassPaint);
    canvas.restore();
    canvas.drawPath(cardPath, borderPaint);

    // Fold triangle
    final foldPath = Path()
      ..moveTo(cw / 2 - fold, -ch / 2)
      ..lineTo(cw / 2, -ch / 2 + fold)
      ..lineTo(cw / 2 - fold, -ch / 2 + fold)
      ..close();
    canvas.drawPath(foldPath, borderPaint);

    // Coloured check mark / assignment label
    final checkPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cw * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final checkPath = Path()
      ..moveTo(-cw * 0.28, -ch * 0.05)
      ..lineTo(-cw * 0.10, ch * 0.12)
      ..lineTo(cw * 0.28, -ch * 0.20);
    canvas.drawPath(checkPath, checkPaint);

    // Lines
    final lp = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ch * 0.030
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final ly = ch * (0.18 + i * 0.20);
      canvas.drawLine(Offset(-cw * 0.38, ly), Offset(cw * 0.34, ly), lp);
    }
  }

  // ── Flashcard ─────────────────────────────────────────────────────────────

  void _drawFlashcard(Canvas canvas, double w, double h,
      {required bool isBack}) {
    final cw = w * 0.18;
    final ch = h * 0.14;
    final color = isBack
        ? AppColors.secondary.withValues(alpha: 0.20)
        : AppColors.tertiary.withValues(alpha: 0.22);
    final borderColor = isBack
        ? AppColors.secondaryLight.withValues(alpha: 0.35)
        : AppColors.tertiaryLight.withValues(alpha: 0.40);

    _drawGlassCard(canvas, cw, ch, color, borderColor);

    if (!isBack) {
      // Question mark icon
      final qPaint = Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.90)
        ..style = PaintingStyle.stroke
        ..strokeWidth = cw * 0.08
        ..strokeCap = StrokeCap.round;
      final qPath = Path()
        ..moveTo(-cw * 0.08, -ch * 0.22)
        ..quadraticBezierTo(cw * 0.22, -ch * 0.40, cw * 0.14, -ch * 0.05)
        ..quadraticBezierTo(cw * 0.08, ch * 0.12, 0, ch * 0.18);
      canvas.drawPath(qPath, qPaint);
      canvas.drawCircle(
        Offset(0, ch * 0.32),
        cw * 0.06,
        Paint()..color = AppColors.tertiary.withValues(alpha: 0.90),
      );
    }
  }

  // ── Glass card helper ─────────────────────────────────────────────────────

  void _drawGlassCard(
      Canvas canvas, double cw, double ch, Color fill, Color border) {
    final rr = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
      const Radius.circular(10),
    );
    // Glass fill
    canvas.drawRRect(
        rr, Paint()..color = fill..style = PaintingStyle.fill);
    // Subtle white sheen
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCenter(
              center: Offset.zero, width: cw, height: ch)));
    // Border
    canvas.drawRRect(
        rr,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
  }

  // ── Glow circle ───────────────────────────────────────────────────────────

  void _drawGlowCircle(
      Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  // ── Sparkle ───────────────────────────────────────────────────────────────

  void _drawSparkle(Canvas canvas, Offset centre, double radius, Color color) {
    const arms = 4;
    const innerRatio = 0.32;
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * math.pi / arms) - math.pi / 2;
      final r = i.isEven ? radius : radius * innerRatio;
      final x = centre.dx + r * math.cos(angle);
      final y = centre.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    // Soft glow
    canvas.drawCircle(
      centre,
      radius * 1.5,
      Paint()
        ..color = color.withValues(alpha: 0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_PremiumStudyScenePainter old) =>
      old.floatT != floatT || old.sparkleT != sparkleT;
}
