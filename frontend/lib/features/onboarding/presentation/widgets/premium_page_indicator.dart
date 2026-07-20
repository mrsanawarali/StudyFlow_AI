import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

/// Premium animated page indicator for the onboarding flow.
///
/// Active dot: elongated pill with gradient + glow.
/// Inactive dots: small dim circles.
///
/// Accepts the same [pageCount] / [currentPage] contract as the old
/// [PageIndicator] so the host screen can swap it in with zero API changes.
class PremiumPageIndicator extends StatelessWidget {
  const PremiumPageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  final int pageCount;

  /// Raw double from [PageController.page]. Uses `.round()` internally.
  final double currentPage;

  static const double _dotH = 8.0;
  static const double _activePillW = 28.0;
  static const double _inactiveDotW = 8.0;
  static const Duration _animDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage.round();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: _DotItem(
            isActive: isActive,
            animDuration: _animDuration,
            dotH: _dotH,
            activePillW: _activePillW,
            inactiveDotW: _inactiveDotW,
          ),
        );
      }),
    );
  }
}

class _DotItem extends StatelessWidget {
  const _DotItem({
    required this.isActive,
    required this.animDuration,
    required this.dotH,
    required this.activePillW,
    required this.inactiveDotW,
  });

  final bool isActive;
  final Duration animDuration;
  final double dotH;
  final double activePillW;
  final double inactiveDotW;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeInOut,
      width: isActive ? activePillW : inactiveDotW,
      height: dotH,
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [AppColors.secondaryLight, AppColors.secondary],
              )
            : null,
        color: isActive ? null : AppColors.outline.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(dotH / 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.55),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
