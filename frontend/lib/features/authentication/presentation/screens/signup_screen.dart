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

/// Phase 2B — Premium Sign Up Screen.
///
/// UI only. No Firebase / backend calls. GoRouter navigation.
class FeatureSignupScreen extends StatefulWidget {
  const FeatureSignupScreen({super.key});

  @override
  State<FeatureSignupScreen> createState() => _FeatureSignupScreenState();
}

class _FeatureSignupScreenState extends State<FeatureSignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // UI-only: simulates signup flow, navigates to verify email.
  Future<void> _onSignUp() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(RoutePaths.verifyEmail);
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
              // ── Back button ──────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.onSurface),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Header ───────────────────────────────────────────────────
              const AuthHeader(subtitle: 'Create your StudyFlow AI account'),
              const SizedBox(height: AppSpacing.xxl),

              // ── Full name ─────────────────────────────────────────────────
              AuthTextField(
                label: 'Full name',
                hint: 'Jane Smith',
                controller: _nameController,
                keyboardType: TextInputType.name,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Email ─────────────────────────────────────────────────────
              AuthTextField(
                label: 'Email address',
                hint: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Password ──────────────────────────────────────────────────
              AuthTextField(
                label: 'Password',
                hint: 'Min 8 characters',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Confirm password ──────────────────────────────────────────
              AuthTextField(
                label: 'Confirm password',
                hint: 'Repeat your password',
                controller: _confirmController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Terms checkbox ────────────────────────────────────────────
              _TermsCheckbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Sign up button ────────────────────────────────────────────
              AuthPrimaryButton(
                label: 'Create account',
                onPressed: _agreedToTerms ? _onSignUp : null,
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

              // ── Login link ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Sign in',
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

// ── Terms & Conditions checkbox ──────────────────────────────────────────────

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: AppColors.outline, width: 1.5),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
