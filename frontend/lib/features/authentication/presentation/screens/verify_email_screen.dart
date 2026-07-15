import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import '../widgets/auth_primary_button.dart';

/// Phase 2B — Verify Email Placeholder Screen.
///
/// Shown after sign-up. Prompts the user to check their inbox.
/// The "I've verified" button simulates success and navigates to
/// [RoutePaths.accountSuccess].
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  bool _isChecking = false;

  // Simple pulsing animation for the envelope icon.
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
    lowerBound: 0.94,
    upperBound: 1.06,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isChecking = false);
    context.go(RoutePaths.accountSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(),

              // ── Animated envelope ──────────────────────────────────────
              ScaleTransition(
                scale: _pulseController,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppColors.secondary,
                    size: 52,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Title ─────────────────────────────────────────────────
              Text(
                'Verify your email',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              Text(
                'We\'ve sent a verification link to your email address. '
                'Open the link to activate your account.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Steps ─────────────────────────────────────────────────
              _StepRow(
                icon: Icons.inbox_outlined,
                text: 'Open your email inbox',
                done: false,
              ),
              const SizedBox(height: AppSpacing.md),
              _StepRow(
                icon: Icons.touch_app_outlined,
                text: 'Tap the verification link',
                done: false,
              ),
              const SizedBox(height: AppSpacing.md),
              _StepRow(
                icon: Icons.check_circle_outline_rounded,
                text: 'Return here to continue',
                done: false,
              ),

              const Spacer(),

              // ── Continue button ────────────────────────────────────────
              AuthPrimaryButton(
                label: "I've verified my email",
                onPressed: _onContinue,
                isLoading: _isChecking,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Resend link ────────────────────────────────────────────
              TextButton(
                onPressed: () {}, // UI placeholder
                child: Text(
                  "Didn't receive it? Resend email",
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Back to login ──────────────────────────────────────────
              TextButton(
                onPressed: () => context.go(RoutePaths.login),
                child: Text(
                  'Back to sign in',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step row widget ────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.text,
    required this.done,
  });

  final IconData icon;
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done
                ? AppColors.success.withValues(alpha: 0.12)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            done ? Icons.check_rounded : icon,
            color: done ? AppColors.success : AppColors.onSurfaceVariant,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: done
                  ? AppColors.onSurfaceVariant
                  : AppColors.onSurface,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}
