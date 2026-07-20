import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';

/// Three animated glowing dots that act as a loading indicator.
///
/// Each dot pulses its opacity (1.0 → 0.3 → 1.0) over 900 ms in a staggered
/// "wave" pattern — each successive dot is delayed by 300 ms.
///
/// All three [AnimationController]s are created and disposed internally.
/// No [CircularProgressIndicator] or platform spinner is used.
class LoadingDotsWidget extends StatefulWidget {
  const LoadingDotsWidget({super.key});

  @override
  State<LoadingDotsWidget> createState() => _LoadingDotsWidgetState();
}

class _LoadingDotsWidgetState extends State<LoadingDotsWidget>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _opacities;

  static const int _dotCount = 3;
  static const double _dotDiameter = 8.0;
  static const double _dotSpacing = 10.0;
  static const double _glowRadius = 6.0;
  static const Duration _cycleDuration = Duration(milliseconds: 900);
  static const Duration _stagger = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(_dotCount, (i) {
      return AnimationController(vsync: this, duration: _cycleDuration);
    });

    _opacities = _controllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 50),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
    }).toList();

    // Start each controller after its stagger delay, then loop.
    for (int i = 0; i < _dotCount; i++) {
      Future.delayed(_stagger * i, () {
        if (mounted) {
          _controllers[i].repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: _dotSpacing / 2),
          child: AnimatedBuilder(
            animation: _opacities[i],
            builder: (context, _) {
              return Opacity(
                opacity: _opacities[i].value,
                child: Container(
                  width: _dotDiameter,
                  height: _dotDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary,
                    boxShadow: [
                      // Inner glow
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        blurRadius: _glowRadius,
                        spreadRadius: 1,
                      ),
                      // Outer soft halo
                      BoxShadow(
                        color: AppColors.secondaryLight.withValues(alpha: 0.4),
                        blurRadius: _glowRadius * 2.5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
