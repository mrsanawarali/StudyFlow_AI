import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
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

// ── Custom bottom navigation bar ──────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    _NavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'Timetable'),
    _NavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Explore'),
    _NavItem(
        icon: Icons.calculate_outlined,
        activeIcon: Icons.calculate_rounded,
        label: 'Calculator'),
    _NavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(
              _items.length,
              (i) => _NavButton(
                item: _items[i],
                isSelected: i == currentIndex,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pill indicator behind active icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isSelected ? 48 : 0,
                height: isSelected ? 28 : 0,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: AppRadius.roundedFull,
                ),
                child: isSelected
                    ? Icon(item.activeIcon,
                        color: AppColors.primary, size: 20)
                    : const SizedBox.shrink(),
              ),
              if (!isSelected) ...[
                Icon(item.icon, color: AppColors.onSurfaceVariant, size: 22),
              ],
              const SizedBox(height: 2),
              Text(
                item.label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
