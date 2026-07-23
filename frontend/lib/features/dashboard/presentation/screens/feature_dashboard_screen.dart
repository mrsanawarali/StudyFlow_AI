// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'calculator_tab.dart';
import 'explore_tab.dart';
import 'home_tab.dart';
import 'profile_tab.dart';
import 'timetable_tab.dart';

/// Phase 2C — Feature Dashboard Shell.
///
/// Hosts exactly 5 tabs:
///   0 — Home (🏠)
///   1 — Timetable (📅)
///   2 — Explore (🔍)
///   3 — Calculator (🧮)
///   4 — Profile (👤)
///
/// Legacy [DashboardScreen] is preserved and untouched.
class FeatureDashboardScreen extends StatefulWidget {
  const FeatureDashboardScreen({super.key});

  @override
  State<FeatureDashboardScreen> createState() =>
      _FeatureDashboardScreenState();
}

class _FeatureDashboardScreenState extends State<FeatureDashboardScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;

  // Keep pages alive while switching tabs.
  late final List<Widget> _pages = const [
    HomeTab(),
    TimetableTab(),
    ExploreTab(),
    CalculatorTab(),
    ProfileTab(),
  ];

  // Subtle entrance animation for each tab switch.
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1,
  );

  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;
    await _fadeController.reverse();
    setState(() => _currentIndex = index);
    await _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// StudyFlow AI — Premium Dark-Navy Floating Navigation Dock
// Complete rebuild. Navigation logic, routes and pages are UNCHANGED.
// ─────────────────────────────────────────────────────────────────────────────

// ── Design tokens ─────────────────────────────────────────────────────────────
// Surface: deep navy that matches dashboard "Continue Studying" card
const Color _kSurface    = Color(0xFF131F3D);
// Slightly lighter navy used for the selected pill
const Color _kPill       = Color(0xFF1E2E52);
// Inner highlight rim on the selected pill (top edge glint)
const Color _kPillRim    = Color(0xFF2A3F6B);
// Accent: electric blue for icon, label and glow on selected tab
const Color _kAccent     = Color(0xFF2563EB);
// Container border — a faint navy-blue rim
const Color _kBorder     = Color(0xFF1F2E50);
// Unselected icon / label colour
const Color _kMuted      = Color(0xFF6B7A9C);
// ─────────────────────────────────────────────────────────────────────────────

// ── Nav item data class ───────────────────────────────────────────────────────
class _NavItem {
  const _NavItem({
    required this.painter,
    required this.label,
  });
  /// Factory that returns the right [CustomPainter] for this tab.
  final _IconPainter Function(Color color, double strokeWidth) painter;
  final String label;
}

// ── Floating dock shell ───────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static final _items = <_NavItem>[
    _NavItem(label: 'Home',
        painter: (c, sw) => _HomeIconPainter(color: c, strokeWidth: sw)),
    _NavItem(label: 'Timetable',
        painter: (c, sw) => _CalendarIconPainter(color: c, strokeWidth: sw)),
    _NavItem(label: 'Explore',
        painter: (c, sw) => _CompassIconPainter(color: c, strokeWidth: sw)),
    _NavItem(label: 'Calculator',
        painter: (c, sw) => _CalcIconPainter(color: c, strokeWidth: sw)),
    _NavItem(label: 'Profile',
        painter: (c, sw) => _ProfileIconPainter(color: c, strokeWidth: sw)),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomPad > 0 ? bottomPad + 6 : 16,
      ),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(38),
          border: Border.all(color: _kBorder, width: 1.0),
          boxShadow: [
            // Deep drop shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            // Soft ambient blue glow
            BoxShadow(
              color: _kAccent.withOpacity(0.14),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: Row(
            children: List.generate(
              _items.length,
              (i) => _NavButton(
                item: _items[i],
                isSelected: i == currentIndex,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(i);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Individual animated tab button ────────────────────────────────────────────
class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Pill scale — springs from 0.72 → 1.0 with iOS-style overshoot
  late final Animation<double> _scaleAnim;
  // Whole column lifts upward when selected
  late final Animation<double> _liftAnim;
  // Glow opacity pulses in behind the pill
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const _IosSpring()),
    );

    _liftAnim = Tween<double>(begin: 0.0, end: -3.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );

    if (widget.isSelected) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.isSelected && old.isSelected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(38),
            // Very soft ripple on the dark surface
            splashColor: _kAccent.withOpacity(0.06),
            highlightColor: _kAccent.withOpacity(0.03),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon pill / bare icon ──────────────────────
                    Transform.translate(
                      offset: Offset(0, _liftAnim.value),
                      child: widget.isSelected
                          ? _buildSelectedPill()
                          : _buildBareIcon(),
                    ),

                    const SizedBox(height: 5),

                    // ── Label ─────────────────────────────────────
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: AppTypography.labelSmall.copyWith(
                        color: widget.isSelected
                            ? Colors.white
                            : _kMuted,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                      child: Text(widget.item.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Selected state: dark navy pill with inner glint + accent glow behind it
  Widget _buildSelectedPill() {
    return Transform.scale(
      scale: _scaleAnim.value,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft blue glow halo behind the pill
          Container(
            width: 56,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _kAccent.withOpacity(0.30 * _glowAnim.value),
                  blurRadius: 14,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
          // Pill itself
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _kPill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kPillRim, width: 1.0),
            ),
            child: CustomPaint(
              size: const Size(20, 20),
              painter: widget.item.painter(Colors.white, 1.6),
            ),
          ),
        ],
      ),
    );
  }

  // Unselected state: bare icon, no pill, muted colour
  Widget _buildBareIcon() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: CustomPaint(
        size: const Size(20, 20),
        painter: widget.item.painter(_kMuted, 1.5),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS-style spring curve: 1 − e^(−damping·t) · cos(frequency·t)
// ─────────────────────────────────────────────────────────────────────────────
class _IosSpring extends Curve {
  const _IosSpring();

  @override
  double transformInternal(double t) =>
      1.0 - math.exp(-10.0 * t) * math.cos(18.0 * t);
}

// ─────────────────────────────────────────────────────────────────────────────
// Abstract base for all custom icon painters
// ─────────────────────────────────────────────────────────────────────────────
abstract class _IconPainter extends CustomPainter {
  const _IconPainter({required this.color, required this.strokeWidth});
  final Color color;
  final double strokeWidth;

  Paint get _p => Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  @override
  bool shouldRepaint(covariant _IconPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}

// ── Home — clean house outline (HouseSimple) ─────────────────────────────────
class _HomeIconPainter extends _IconPainter {
  const _HomeIconPainter({required super.color, required super.strokeWidth});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final p = _p;

    // Roof
    final roof = Path()
      ..moveTo(w * 0.50, h * 0.06)
      ..lineTo(w * 0.94, h * 0.46)
      ..lineTo(w * 0.06, h * 0.46)
      ..close();
    canvas.drawPath(roof, p);

    // Walls
    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, h * 0.46, w * 0.64, h * 0.48),
      p,
    );

    // Door
    final door = Path()
      ..moveTo(w * 0.40, h * 0.94)
      ..lineTo(w * 0.40, h * 0.68)
      ..arcToPoint(Offset(w * 0.60, h * 0.68),
          radius: Radius.circular(w * 0.10), clockwise: false)
      ..lineTo(w * 0.60, h * 0.94);
    canvas.drawPath(door, p);
  }
}

// ── Timetable — calendar with dots (CalendarDots) ────────────────────────────
class _CalendarIconPainter extends _IconPainter {
  const _CalendarIconPainter(
      {required super.color, required super.strokeWidth});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final p = _p;

    // Outer rounded rect
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.14, w * 0.88, h * 0.80),
        Radius.circular(w * 0.14),
      ),
      p,
    );

    // Header divider
    canvas.drawLine(
        Offset(w * 0.06, h * 0.38), Offset(w * 0.94, h * 0.38), p);

    // Hook lines (top)
    canvas.drawLine(
        Offset(w * 0.32, h * 0.06), Offset(w * 0.32, h * 0.24), p);
    canvas.drawLine(
        Offset(w * 0.68, h * 0.06), Offset(w * 0.68, h * 0.24), p);

    // Dot grid (2×3)
    final dotP = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotR = w * 0.055;
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 3; col++) {
        canvas.drawCircle(
          Offset(w * (0.24 + col * 0.26), h * (0.57 + row * 0.20)),
          dotR,
          dotP,
        );
      }
    }
  }
}

// ── Explore — compass rose (Compass) ─────────────────────────────────────────
class _CompassIconPainter extends _IconPainter {
  const _CompassIconPainter(
      {required super.color, required super.strokeWidth});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w / 2;
    final cy = h / 2;
    final p = _p;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), w * 0.44, p);

    // Inner ring (subtle)
    canvas.drawCircle(Offset(cx, cy), w * 0.12,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill);

    // North-East needle (filled solid triangle)
    final needleN = Path()
      ..moveTo(cx, cy - w * 0.30)
      ..lineTo(cx - w * 0.09, cy)
      ..lineTo(cx + w * 0.09, cy)
      ..close();
    canvas.drawPath(
      needleN,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // South-West needle (stroke only, muted)
    final needleS = Path()
      ..moveTo(cx, cy + w * 0.30)
      ..lineTo(cx - w * 0.09, cy)
      ..lineTo(cx + w * 0.09, cy)
      ..close();
    canvas.drawPath(
      needleS,
      Paint()
        ..color = color.withOpacity(0.35)
        ..style = PaintingStyle.fill,
    );
  }
}

// ── Calculator — grid of keys ─────────────────────────────────────────────────
class _CalcIconPainter extends _IconPainter {
  const _CalcIconPainter({required super.color, required super.strokeWidth});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final p = _p;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.04, w * 0.80, h * 0.92),
        Radius.circular(w * 0.14),
      ),
      p,
    );

    // Display bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.20, h * 0.12, w * 0.60, h * 0.20),
        Radius.circular(w * 0.05),
      ),
      p,
    );

    // Key dots — 2×3 grid
    final dotP = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final dotR = w * 0.060;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 2; col++) {
        canvas.drawCircle(
          Offset(w * (0.30 + col * 0.40), h * (0.52 + row * 0.16)),
          dotR,
          dotP,
        );
      }
    }
  }
}

// ── Profile — person circle (UserCircle) ────────────────────────────────────
class _ProfileIconPainter extends _IconPainter {
  const _ProfileIconPainter(
      {required super.color, required super.strokeWidth});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final cx = w / 2;
    final cy = h / 2;
    final p = _p;

    // Outer circle
    canvas.drawCircle(Offset(cx, cy), w * 0.44, p);

    // Head circle
    canvas.drawCircle(Offset(cx, cy * 0.72), w * 0.18, p);

    // Shoulders arc
    final shoulderPath = Path()
      ..moveTo(w * 0.10, h * 0.92)
      ..quadraticBezierTo(
        w * 0.18, h * 0.62,
        cx, h * 0.62,
      )
      ..quadraticBezierTo(
        w * 0.82, h * 0.62,
        w * 0.90, h * 0.92,
      );
    canvas.drawPath(shoulderPath, p);
  }
}
