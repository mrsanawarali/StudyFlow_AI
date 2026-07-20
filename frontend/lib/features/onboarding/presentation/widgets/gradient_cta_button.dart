import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Gradient CTA button for the onboarding flow.
///
/// Features:
/// - Left-to-right gradient (secondary → tertiary)
/// - Glow box shadow in the secondary brand colour
/// - Fully rounded pill shape
/// - Scale-down animation on press (0.96×)
/// - Ripple via [InkWell]
class GradientCtaButton extends StatefulWidget {
  const GradientCtaButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  State<GradientCtaButton> createState() => _GradientCtaButtonState();
}

class _GradientCtaButtonState extends State<GradientCtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null) _scaleCtrl.reverse();
  }

  void _onTapUp(TapUpDetails _) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [AppColors.secondary, AppColors.tertiary],
                  )
                : null,
            color: enabled ? null : AppColors.outline.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(27),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(27),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: Text(
                  widget.text,
                  style: AppTypography.labelLarge.copyWith(
                    color: enabled
                        ? AppColors.onPrimary
                        : AppColors.onPrimary.withValues(alpha: 0.40),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
