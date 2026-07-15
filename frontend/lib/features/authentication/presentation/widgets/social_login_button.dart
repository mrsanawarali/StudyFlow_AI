import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// A single social login button (Google / Apple / Microsoft).
///
/// UI-only placeholder — no OAuth logic attached.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconWidget,
    this.onPressed,
  });

  final String label;

  /// Typically an [Image] or [Icon] widget for the provider logo.
  final Widget iconWidget;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.roundedLg,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22, height: 22, child: iconWidget),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Convenience factory widgets ────────────────────────────────────────────

/// Placeholder Google sign-in button.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SocialLoginButton(
        label: 'Continue with Google',
        onPressed: onPressed,
        iconWidget: _GoogleLogoIcon(),
      );
}

/// Placeholder Apple sign-in button.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SocialLoginButton(
        label: 'Continue with Apple',
        onPressed: onPressed,
        iconWidget: const Icon(Icons.apple_rounded,
            color: AppColors.onSurface, size: 22),
      );
}

/// Placeholder Microsoft sign-in button.
class MicrosoftSignInButton extends StatelessWidget {
  const MicrosoftSignInButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SocialLoginButton(
        label: 'Continue with Microsoft',
        onPressed: onPressed,
        iconWidget: const _MicrosoftLogoIcon(),
      );
}

// ── Micro icon painters ────────────────────────────────────────────────────

class _GoogleLogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width * 0.46;

    final colors = [
      const Color(0xFF4285F4), // blue
      const Color(0xFF34A853), // green
      const Color(0xFFFBBC05), // yellow
      const Color(0xFFEA4335), // red
    ];
    final sweeps = [90.0, 90.0, 90.0, 90.0];
    double start = -90.0;

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        _deg(start),
        _deg(sweeps[i]),
        false,
        paint,
      );
      start += sweeps[i];
    }

    // White cutout for the "G" gap / bar
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - size.height * 0.12, r + size.width * 0.1,
          size.height * 0.24),
      whitePaint,
    );
  }

  static double _deg(double d) => d * 3.14159265 / 180;

  @override
  bool shouldRepaint(_GooglePainter old) => false;
}

class _MicrosoftLogoIcon extends StatelessWidget {
  const _MicrosoftLogoIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MsPainter());
  }
}

class _MsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double half = size.width * 0.46;
    final double gap = size.width * 0.08;
    final double offset = (size.width - (half * 2 + gap)) / 2;
    final double top = (size.height - (half * 2 + gap)) / 2;

    final quads = [
      [const Color(0xFFF25022), offset, top],
      [const Color(0xFF7FBA00), offset + half + gap, top],
      [const Color(0xFF00A4EF), offset, top + half + gap],
      [const Color(0xFFFFB900), offset + half + gap, top + half + gap],
    ];

    for (final q in quads) {
      canvas.drawRect(
        Rect.fromLTWH(
            (q[1] as double), (q[2] as double), half, half),
        Paint()..color = q[0] as Color,
      );
    }
  }

  @override
  bool shouldRepaint(_MsPainter old) => false;
}
