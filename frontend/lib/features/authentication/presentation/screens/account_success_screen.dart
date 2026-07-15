import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import '../widgets/auth_primary_button.dart';

/// Phase 2B — Account Created Success Screen.
///
/// Shown after email verification. Celebrates the new account
/// and routes the user to the login screen.
class AccountSuccessScreen extends StatefulWidget {
  const AccountSuccessScreen({super.key});

  @override
  State<AccountSuccessScreen> createState() => _AccountSuccessScreenState();
}

class _AccountSuccessScreenState extends State<AccountSuccessScreen>
    with TickerProviderStateMixin {
  // Scale-in entrance animation for the checkmark badge.
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _scaleAnim = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.elasticOut,
  );

  // Fade-in for the text content.
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  late final Animation<double> _fadeAnim = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    // Start text fade after icon settles.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
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

              // ── Animated checkmark badge ──────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow ring
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Mid ring
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Icon container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Text content (fades in) ───────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      'Account created!',
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.onSurface,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Welcome to StudyFlow AI.\n'
                      'Your learning journey starts now.',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // ── Feature highlights ─────────────────────────────
                    _HighlightRow(
                      icon: Icons.layers_outlined,
                      color: AppColors.secondary,
                      text: 'Organize semesters, subjects & notes',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _HighlightRow(
                      icon: Icons.psychology_outlined,
                      color: AppColors.tertiary,
                      text: 'AI-powered summaries & quizzes',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _HighlightRow(
                      icon: Icons.offline_bolt_outlined,
                      color: AppColors.info,
                      text: 'Works offline, syncs automatically',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── CTA ───────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthPrimaryButton(
                      label: 'Go to sign in',
                      onPressed: () => context.go(RoutePaths.login),
                      icon: Icons.login_rounded,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Text(
                        'Transform Your Study Journey',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature highlight row ──────────────────────────────────────────────────────

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
