import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';

/// A data class describing a single floating particle dot.
class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.driftAmount,
    required this.cycleMs,
    required this.phaseOffset,
  });

  final double x;           // 0.0–1.0 normalised
  final double y;           // 0.0–1.0 normalised (start position)
  final double radius;      // dp
  final double opacity;     // 0.10–0.35
  final double driftAmount; // dp upward travel
  final double cycleMs;     // full cycle duration in ms
  final double phaseOffset; // 0.0–1.0 fraction
}

/// Pre-built stable list of 15 particles, generated once with a fixed seed.
final List<_Particle> _kParticles = _buildParticles();

List<_Particle> _buildParticles() {
  final rng = math.Random(42);
  return List.generate(15, (_) {
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      radius: 1.0 + rng.nextDouble() * 2.0,
      opacity: 0.10 + rng.nextDouble() * 0.25,
      driftAmount: 20 + rng.nextDouble() * 20,
      cycleMs: 4000 + rng.nextDouble() * 4000,
      phaseOffset: rng.nextDouble(),
    );
  });
}

/// A full-screen [CustomPaint] widget that renders 15 pseudo-randomly placed
/// light dots that drift upward continuously, wrapping back when they reach
/// the top of their travel range.
///
/// The animation is driven by the [controller] passed in. When [controller]
/// is disposed the widget simply stops repainting — no exceptions are thrown.
class ParticleLayer extends StatelessWidget {
  const ParticleLayer({
    super.key,
    required this.controller,
  });

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _kParticles,
            progress: controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress; // 0.0–1.0, loops continuously

  @override
  void paint(Canvas canvas, Size size) {
    // We need wall-clock millis to compute each particle's independent phase.
    // We use the looping controller value (0.0→1.0) as a proxy for "time".
    // The controller itself loops at ~6 s (particle controller duration),
    // but each particle has its own cycleMs, so we pass a shared timestamp
    // derived from DateTime for true independence.
    final double nowMs =
        DateTime.now().millisecondsSinceEpoch.toDouble();

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Phase within this particle's own cycle, accounting for phase offset.
      final double phase =
          ((nowMs / p.cycleMs) + p.phaseOffset) % 1.0;

      // Upward drift: particle moves from y → (y - driftAmount).
      // When phase reaches 1.0, it wraps back to y (instant teleport).
      final double driftY = p.driftAmount * phase;

      final double px = p.x * size.width;
      final double py = (p.y * size.height) - driftY;

      // Skip dots that have drifted off-screen (they'll reappear next frame).
      if (py < 0) continue;

      paint.color =
          AppColors.secondaryLight.withValues(alpha: p.opacity);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(Offset(px, py), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
