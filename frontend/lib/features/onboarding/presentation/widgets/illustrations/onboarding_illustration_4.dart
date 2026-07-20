import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Premium animated productivity dashboard for onboarding page 4.
///
/// Floating glass cards arranged around a central progress ring:
///   • Circular progress ring (centre) — animated fill
///   • Weekly chart card (top-left) — bar heights animate
///   • GPA card (top-right) — floating
///   • Timetable card (mid-left) — floating
///   • Assignment card (mid-right) — animated progress bar
///   • Calendar widget (bottom-left) — floating
///   • Achievement badge (bottom-right) — pulse glow
///   • Study streak counter (bottom-centre) — floating
///
/// Drop-in replacement — same class name, same constructor.
class OnboardingIllustration4 extends StatefulWidget {
  const OnboardingIllustration4({super.key});

  @override
  State<OnboardingIllustration4> createState() =>
      _OnboardingIllustration4State();
}

class _OnboardingIllustration4State extends State<OnboardingIllustration4>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;    // 3.0 s reverse
  late final AnimationController _progressCtrl; // 2.4 s reverse (ring + bar)
  late final AnimationController _pulseCtrl;    // 1.8 s reverse (badge glow)
  late final AnimationController _sparkCtrl;    // 2.0 s reverse
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _sparkCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance
        .addPostFrameCallback((_) { if (mounted) _enterCtrl.forward(); });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    _sparkCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: SizedBox(
        height: AppSpacing.xxxl * 3,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_floatCtrl, _progressCtrl, _pulseCtrl, _sparkCtrl]),
          builder: (_, __) => CustomPaint(
            painter: _DashboardPainter(
              floatT: _floatCtrl.value,
              progressT: _progressCtrl.value,
              pulseT: _pulseCtrl.value,
              sparkT: _sparkCtrl.value,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardPainter extends CustomPainter {
  const _DashboardPainter({
    required this.floatT,
    required this.progressT,
    required this.pulseT,
    required this.sparkT,
  });

  final double floatT;
  final double progressT;
  final double pulseT;
  final double sparkT;

  double _fy(double phase, {double amp = 5.5}) =>
      amp * math.sin(((floatT + phase) % 1.0) * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.50;
    final cy = h * 0.46;

    // Background glows
    _glow(canvas, Offset(cx, cy), w * 0.26,
        AppColors.secondary.withValues(alpha: 0.10));
    _glow(canvas, Offset(w * 0.18, h * 0.22), w * 0.16,
        AppColors.tertiary.withValues(alpha: 0.08));
    _glow(canvas, Offset(w * 0.84, h * 0.72), w * 0.14,
        AppColors.secondaryLight.withValues(alpha: 0.07));

    // ── Weekly chart — top-left (phase 0.20) ────────────────────────────
    canvas.save();
    canvas.translate(w * 0.13, h * 0.16 + _fy(0.20));
    canvas.rotate(-0.14);
    _drawWeeklyChart(canvas, w, h);
    canvas.restore();

    // ── GPA card — top-right (phase 0.60) ────────────────────────────────
    canvas.save();
    canvas.translate(w * 0.87, h * 0.14 + _fy(0.60));
    canvas.rotate(0.16);
    _drawGpaCard(canvas, w, h);
    canvas.restore();

    // ── Timetable card — mid-left (phase 0.40) ───────────────────────────
    canvas.save();
    canvas.translate(w * 0.10, h * 0.50 + _fy(0.40));
    canvas.rotate(-0.10);
    _drawTimetableCard(canvas, w, h);
    canvas.restore();

    // ── Assignment card — mid-right (phase 0.75) ─────────────────────────
    canvas.save();
    canvas.translate(w * 0.90, h * 0.46 + _fy(0.75));
    canvas.rotate(0.12);
    _drawAssignmentCard(canvas, w, h);
    canvas.restore();

    // ── Calendar widget — bottom-left (phase 0.55) ───────────────────────
    canvas.save();
    canvas.translate(w * 0.14, h * 0.78 + _fy(0.55));
    canvas.rotate(-0.16);
    _drawCalendarCard(canvas, w, h);
    canvas.restore();

    // ── Achievement badge — bottom-right (pulse) ─────────────────────────
    canvas.save();
    canvas.translate(w * 0.86, h * 0.78 + _fy(0.85));
    canvas.rotate(0.18);
    _drawAchievementBadge(canvas, w, h);
    canvas.restore();

    // ── Study streak — bottom-centre (phase 0.30) ───────────────────────
    canvas.save();
    canvas.translate(cx, h * 0.88 + _fy(0.30, amp: 3.5));
    _drawStreakCounter(canvas, w, h);
    canvas.restore();

    // ── Central progress ring (drawn last, on top) ───────────────────────
    _drawProgressRing(canvas, w, h, cx, cy);

    // Sparkles
    final sr = 0.010 + sparkT * 0.005;
    _sparkle(canvas, Offset(w * 0.58, h * 0.06),
        w * sr, AppColors.tertiary.withValues(alpha: 0.85));
    _sparkle(canvas, Offset(w * 0.25, h * 0.08),
        w * sr * 0.70, AppColors.secondaryLight.withValues(alpha: 0.75));
    _sparkle(canvas, Offset(w * 0.92, h * 0.32),
        w * sr * 0.65, AppColors.tertiary.withValues(alpha: 0.70));
    _sparkle(canvas, Offset(w * 0.06, h * 0.62),
        w * sr * 0.55, AppColors.secondaryLight.withValues(alpha: 0.60));
  }

  // ── Central progress ring ────────────────────────────────────────────────

  void _drawProgressRing(
      Canvas canvas, double w, double h, double cx, double cy) {
    final r = w * 0.105;
    final sweepAngle = (0.45 + progressT * 0.40) * 2 * math.pi;

    // Outer pulse halo
    canvas.drawCircle(Offset(cx, cy), r * (1.25 + pulseT * 0.12),
        Paint()
          ..color =
              AppColors.tertiary.withValues(alpha: 0.08 + pulseT * 0.06)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Track ring
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.022);

    // Filled arc
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi,
        colors: [AppColors.tertiary, AppColors.secondary, AppColors.tertiary],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.022
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -math.pi / 2,
        sweepAngle,
        false,
        arcPaint);

    // Glass card background
    canvas.drawCircle(Offset(cx, cy), r * 0.80,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.75)
          ..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), r * 0.80,
        Paint()
          ..color = AppColors.tertiary.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    // Percentage text
    final pct = (45 + progressT * 40).round();
    final tp = TextPainter(
      text: TextSpan(
        text: '$pct%',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: r * 0.55,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  // ── Weekly chart card ────────────────────────────────────────────────────

  void _drawWeeklyChart(Canvas canvas, double w, double h) {
    final cw = w * 0.28;
    final ch = h * 0.28;
    _glassRect(canvas, cw, ch, 10,
        AppColors.secondary.withValues(alpha: 0.18),
        AppColors.secondaryLight.withValues(alpha: 0.28));

    // Bars (Mon-Fri)
    final barW = cw * 0.10;
    final maxBarH = ch * 0.42;
    final animated = [0.60, 0.80, 0.50, 0.90 + progressT * 0.10, 0.68];
    for (int i = 0; i < 5; i++) {
      final bh = maxBarH * animated[i];
      final bx = -cw * 0.34 + i * (barW + cw * 0.04);
      final by = ch * 0.10;
      final isActive = i == 3;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by - bh, barW, bh),
          Radius.circular(barW / 2),
        ),
        Paint()
          ..color = isActive
              ? AppColors.tertiary.withValues(alpha: 0.90)
              : AppColors.secondary.withValues(alpha: 0.55)
          ..style = PaintingStyle.fill,
      );
      if (isActive) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(bx, by - bh, barW, bh),
            Radius.circular(barW / 2),
          ),
          Paint()
            ..color = AppColors.tertiary.withValues(alpha: 0.30)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }
    // Label
    _label(canvas, 'Weekly', cw * 0.40, -ch * 0.38, 9.0, AppColors.secondaryLight);
  }

  // ── GPA card ─────────────────────────────────────────────────────────────

  void _drawGpaCard(Canvas canvas, double w, double h) {
    final cw = w * 0.20;
    final ch = h * 0.20;
    _glassRect(canvas, cw, ch, 10,
        AppColors.tertiary.withValues(alpha: 0.16),
        AppColors.tertiaryLight.withValues(alpha: 0.30));

    _label(canvas, 'GPA', 0, -ch * 0.22, 9.0, AppColors.tertiaryLight);

    // Big GPA number
    final gpa = (3.4 + progressT * 0.45).toStringAsFixed(1);
    final tp = TextPainter(
      text: TextSpan(
        text: gpa,
        style: TextStyle(
          color: AppColors.tertiary,
          fontSize: cw * 0.45,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, ch * 0.04));
  }

  // ── Timetable card ────────────────────────────────────────────────────────

  void _drawTimetableCard(Canvas canvas, double w, double h) {
    final cw = w * 0.22;
    final ch = h * 0.26;
    _glassRect(canvas, cw, ch, 10,
        AppColors.secondary.withValues(alpha: 0.18),
        AppColors.secondaryLight.withValues(alpha: 0.26));

    _label(canvas, 'Timetable', 0, -ch * 0.38, 8.5, AppColors.secondaryLight);

    // 3 time slots
    final slotColors = [
      AppColors.secondary.withValues(alpha: 0.65),
      AppColors.tertiary.withValues(alpha: 0.60),
      AppColors.secondary.withValues(alpha: 0.45),
    ];
    for (int i = 0; i < 3; i++) {
      final sy = -ch * 0.14 + i * ch * 0.23;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-cw * 0.38, sy, cw * 0.76, ch * 0.16),
          const Radius.circular(4),
        ),
        Paint()..color = slotColors[i]..style = PaintingStyle.fill,
      );
    }
  }

  // ── Assignment progress card ──────────────────────────────────────────────

  void _drawAssignmentCard(Canvas canvas, double w, double h) {
    final cw = w * 0.22;
    final ch = h * 0.24;
    _glassRect(canvas, cw, ch, 10,
        AppColors.tertiary.withValues(alpha: 0.14),
        AppColors.tertiaryLight.withValues(alpha: 0.26));

    _label(canvas, 'Assignments', 0, -ch * 0.36, 8.0, AppColors.tertiaryLight);

    // Progress bar track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-cw * 0.38, ch * 0.06, cw * 0.76, ch * 0.12),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );
    // Fill
    final fillW = cw * 0.76 * (0.30 + progressT * 0.50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-cw * 0.38, ch * 0.06, fillW, ch * 0.12),
        const Radius.circular(4),
      ),
      Paint()
        ..shader = LinearGradient(
          colors: [AppColors.secondary, AppColors.tertiary],
        ).createShader(Rect.fromLTWH(-cw * 0.38, 0, cw * 0.76, 1)),
    );
    // Percent text
    final pct = (30 + progressT * 50).round();
    _label(canvas, '$pct%', cw * 0.28, ch * 0.04, 9.0, AppColors.tertiary);
  }

  // ── Calendar card ─────────────────────────────────────────────────────────

  void _drawCalendarCard(Canvas canvas, double w, double h) {
    final cw = w * 0.20;
    final ch = h * 0.22;
    _glassRect(canvas, cw, ch, 10,
        AppColors.secondary.withValues(alpha: 0.16),
        AppColors.secondaryLight.withValues(alpha: 0.26));

    // Header strip
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-cw / 2 + 3, -ch / 2 + 3, cw - 6, ch * 0.26),
        const Radius.circular(8),
      ),
      Paint()..color = AppColors.secondary.withValues(alpha: 0.55),
    );

    // Dot grid
    final dp = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    final ap = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        final ox = -cw * 0.32 + c * cw * 0.21;
        final oy = -ch * 0.04 + r * ch * 0.18;
        canvas.drawCircle(
            Offset(ox, oy), cw * 0.055, r == 1 && c == 2 ? ap : dp);
      }
    }
  }

  // ── Achievement badge ─────────────────────────────────────────────────────

  void _drawAchievementBadge(Canvas canvas, double w, double h) {
    final r = w * 0.080;
    // Pulse glow
    canvas.drawCircle(Offset.zero, r * (1.3 + pulseT * 0.18),
        Paint()
          ..color = AppColors.tertiary.withValues(alpha: 0.18 + pulseT * 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    // Hexagon shape
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 3 * i - math.pi / 2;
      final x = r * math.cos(a);
      final y = r * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tertiary.withValues(alpha: 0.70),
              AppColors.secondary.withValues(alpha: 0.55),
            ],
          ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)));
    canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.tertiary.withValues(alpha: 0.60)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);

    // Trophy icon
    final ip = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final trophy = Path()
      ..moveTo(-r * 0.28, -r * 0.42)
      ..lineTo(-r * 0.28, r * 0.08)
      ..quadraticBezierTo(-r * 0.28, r * 0.36, 0, r * 0.36)
      ..quadraticBezierTo(r * 0.28, r * 0.36, r * 0.28, r * 0.08)
      ..lineTo(r * 0.28, -r * 0.42)
      ..close();
    canvas.drawPath(trophy, ip);
    canvas.drawLine(Offset(-r * 0.18, r * 0.42), Offset(r * 0.18, r * 0.42),
        ip..strokeWidth = r * 0.14);
  }

  // ── Study streak counter ──────────────────────────────────────────────────

  void _drawStreakCounter(Canvas canvas, double w, double h) {
    final cw = w * 0.30;
    final ch = h * 0.12;
    _glassRect(canvas, cw, ch, 16,
        AppColors.tertiary.withValues(alpha: 0.16),
        AppColors.tertiaryLight.withValues(alpha: 0.30));

    // Flame icon
    final flamePaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final flame = Path()
      ..moveTo(-cw * 0.28, ch * 0.20)
      ..quadraticBezierTo(-cw * 0.30, -ch * 0.22, -cw * 0.16, -ch * 0.30)
      ..quadraticBezierTo(-cw * 0.08, ch * 0.04, -cw * 0.10, ch * 0.20)
      ..quadraticBezierTo(-cw * 0.10, -ch * 0.10, -cw * 0.22, -ch * 0.10)
      ..quadraticBezierTo(-cw * 0.22, ch * 0.10, -cw * 0.28, ch * 0.20)
      ..close();
    canvas.drawPath(flame, flamePaint);

    // "14 Day Streak" label area
    final tp = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '14',
            style: TextStyle(
              color: AppColors.tertiary,
              fontSize: ch * 0.55,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: ' Day Streak',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: ch * 0.38,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-cw * 0.14, -tp.height / 2));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _glassRect(Canvas canvas, double cw, double ch, double cr,
      Color fill, Color border) {
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
        Radius.circular(cr));
    canvas.drawRRect(rr, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.0)
            ],
          ).createShader(
              Rect.fromCenter(center: Offset.zero, width: cw, height: ch)));
    canvas.drawRRect(
        rr,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
  }

  void _label(Canvas canvas, String text, double x, double y,
      double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: fontSize, fontWeight: FontWeight.w600)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  void _glow(Canvas canvas, Offset c, double r, Color color) =>
      canvas.drawCircle(c, r,
          Paint()
            ..shader = RadialGradient(
                colors: [color, color.withValues(alpha: 0.0)])
                .createShader(Rect.fromCircle(center: c, radius: r)));

  void _sparkle(Canvas canvas, Offset c, double r, Color color) {
    const arms = 4;
    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final a = (i * math.pi / arms) - math.pi / 2;
      final rad = i.isEven ? r : r * 0.32;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(c, r * 1.6,
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  @override
  bool shouldRepaint(_DashboardPainter old) =>
      old.floatT != floatT || old.progressT != progressT ||
      old.pulseT != pulseT || old.sparkT != sparkT;
}
