import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';

/// Phase 2B — Premium Login Screen.
///
/// UI only. No Firebase calls. All controllers are local state.
/// Navigation uses GoRouter.
class FeatureLoginScreen extends StatefulWidget {
  const FeatureLoginScreen({super.key});

  @override
  State<FeatureLoginScreen> createState() => _FeatureLoginScreenState();
}

class _FeatureLoginScreenState extends State<FeatureLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // UI-only: simulates a loading state for 1.5 s then navigates to home.
  // Replace with real auth logic in Phase 3.
  Future<void> _onLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Header ──────────────────────────────────────────────────
              const AuthHeader(subtitle: 'Welcome back to StudyFlow AI'),
              const SizedBox(height: AppSpacing.xxl),

              // ── Email ────────────────────────────────────────────────────
              AuthTextField(
                label: 'Email address',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Password ─────────────────────────────────────────────────
              AuthTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Forgot password ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(RoutePaths.forgotPassword),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Sign in button ────────────────────────────────────────────
              AuthPrimaryButton(
                label: 'Sign in',
                onPressed: _onLogin,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Divider ───────────────────────────────────────────────────
              const AuthDivider(),
              const SizedBox(height: AppSpacing.lg),

              // ── Social buttons ────────────────────────────────────────────
              const GoogleSignInButton(),
              const SizedBox(height: AppSpacing.sm),
              const AppleSignInButton(),
              const SizedBox(height: AppSpacing.sm),
              const MicrosoftSignInButton(),
              const SizedBox(height: AppSpacing.xl),

              // ── Sign up link ──────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RoutePaths.signup),
                    child: Text(
                      'Sign up',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
