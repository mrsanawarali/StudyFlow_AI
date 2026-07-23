// ignore_for_file: deprecated_member_use
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
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
// Premium Floating Bottom Navigation Bar
// Navigation logic, routes and tab pages are completely unchanged.
// Only the visual / animation layer is replaced.
// ─────────────────────────────────────────────────────────────────────────────

// Nav item data
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// Floating shell — adds bottom margin + rounded card, owns no state
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Timetable',
    ),
    _NavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    _NavItem(
      icon: Icons.calculate_outlined,
      activeIcon: Icons.calculate_rounded,
      label: 'Calculator',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // SafeArea bottom padding so the bar clears the home indicator on iOS
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: (bottomPad > 0 ? bottomPad : AppSpacing.md),
      ),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFE8EAED),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.07),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
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

// Individual animated tab button
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

  // Spring-like scale curve for the pill pop
  late final Animation<double> _scaleAnim;
  // Icon vertical lift when selected
  late final Animation<double> _liftAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        // Mimics iOS spring: overshoot then settle
        curve: const _SpringCurve(),
      ),
    );

    _liftAnim = Tween<double>(begin: 0.0, end: -2.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
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
            borderRadius: BorderRadius.circular(30),
            splashColor: AppColors.secondary.withOpacity(0.08),
            highlightColor: AppColors.secondary.withOpacity(0.04),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Icon area ──────────────────────────────────
                      Transform.translate(
                        offset: Offset(0, _liftAnim.value),
                        child: widget.isSelected
                            // Selected: blue pill with white icon, spring-scales in
                            ? Transform.scale(
                                scale: _scaleAnim.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.secondary,
                                        Color(0xFF6BB8FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary
                                            .withOpacity(
                                                0.38 * _scaleAnim.value),
                                        blurRadius: 10,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    widget.item.activeIcon,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              )
                            // Unselected: plain icon, no pill
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                child: Icon(
                                  widget.item.icon,
                                  color: const Color(0xFF6B7280),
                                  size: 20,
                                ),
                              ),
                      ),

                      const SizedBox(height: 3),

                      // ── Label ──────────────────────────────────────
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        style: AppTypography.labelSmall.copyWith(
                          color: widget.isSelected
                              ? AppColors.secondary
                              : const Color(0xFF9CA3AF),
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 10,
                          letterSpacing: widget.isSelected ? 0.1 : 0,
                        ),
                        child: Text(widget.item.label),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS-style spring curve — damped oscillation overshoot then settle
// Uses dart:math imported as [math] at the top of the file.
// ─────────────────────────────────────────────────────────────────────────────

class _SpringCurve extends Curve {
  const _SpringCurve();

  @override
  double transformInternal(double t) {
    // Damped spring: 1 - e^(-damping·t) · cos(frequency·t)
    const double damping   = 12.0;
    const double frequency = 20.0;
    return 1.0 - math.exp(-damping * t) * math.cos(frequency * t);
  }
}
