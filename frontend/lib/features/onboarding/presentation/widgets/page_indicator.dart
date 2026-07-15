import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';

/// Animated page indicator for the onboarding flow.
///
/// Accepts [currentPage] as a raw [double] from [PageController.page],
/// using `.round()` to determine the active dot so that the active dot
/// switches at the midpoint of a swipe gesture while [AnimatedContainer]
/// provides smooth width/colour transitions throughout.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;

  /// Raw double from [PageController.page]. Uses `.round()` internally
  /// to determine which dot is active.
  final double currentPage;

  static const double _dotHeight = AppSpacing.sm; // 8 dp
  static const double _activeDotWidth = 24.0;
  static const double _inactiveDotWidth = AppSpacing.sm; // 8 dp
  static const Duration _dotAnimDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage.round();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AnimatedContainer(
            duration: _dotAnimDuration,
            width: isActive ? _activeDotWidth : _inactiveDotWidth,
            height: _dotHeight,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.secondary.withValues(alpha: 1.0)
                  : AppColors.outline.withValues(alpha: 0.4),
              borderRadius: AppRadius.roundedFull,
            ),
          ),
        );
      }),
    );
  }
}
