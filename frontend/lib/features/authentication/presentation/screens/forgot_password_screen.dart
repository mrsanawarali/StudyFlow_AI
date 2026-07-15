import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

/// Phase 2B — Forgot Password Screen.
///
/// UI only. Accepts an email and shows a simulated "sent" confirmation.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: _sent ? _SuccessState() : _FormState(
            controller: _emailController,
            isLoading: _isLoading,
            onSend: _onSend,
          ),
        ),
      ),
    );
  }
}

// ── Form state ────────────────────────────────────────────────────────────────

class _FormState extends StatelessWidget {
  const _FormState({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Icon ────────────────────────────────────────────────────────
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppColors.secondary, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Title ───────────────────────────────────────────────────────
        Text(
          'Forgot password?',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          'Enter the email address linked to your account and '
          'we\'ll send a reset link.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // ── Email field ──────────────────────────────────────────────────
        AuthTextField(
          label: 'Email address',
          hint: 'you@example.com',
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── Send button ──────────────────────────────────────────────────
        AuthPrimaryButton(
          label: 'Send reset link',
          onPressed: onSend,
          isLoading: isLoading,
          icon: Icons.send_rounded,
        ),
      ],
    );
  }
}

// ── Sent confirmation state ───────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Checkmark icon ───────────────────────────────────────────────
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppColors.success, size: 40),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Text(
          'Check your inbox',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),

        Text(
          'A password reset link has been sent. '
          'Check your spam folder if you don\'t see it.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxl),

        AuthPrimaryButton(
          label: 'Back to sign in',
          onPressed: () => context.pop(),
          icon: Icons.arrow_back_rounded,
        ),
      ],
    );
  }
}
