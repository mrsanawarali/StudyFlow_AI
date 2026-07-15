import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../config/theme/app_typography.dart';

/// Consistent Material 3 text input for StudyFlow AI.
///
/// Usage:
/// ```dart
/// AppTextField(
///   controller: _emailController,
///   label: 'Email',
///   validator: Validators.email,
///   keyboardType: TextInputType.emailAddress,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.semanticsLabel,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final String? semanticsLabel;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.obscureText;

    return Semantics(
      label: widget.semanticsLabel ?? widget.label,
      child: TextFormField(
        controller: widget.controller,
        obscureText: isPassword && _obscured,
        maxLines: isPassword ? 1 : widget.maxLines,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofocus: widget.autofocus,
        validator: widget.validator,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          prefixIcon:
              widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                  tooltip:
                      _obscured ? 'Show password' : 'Hide password',
                )
              : (widget.suffixIcon != null
                  ? Icon(widget.suffixIcon)
                  : null),
          filled: true,
          fillColor: widget.enabled
              ? AppColors.surfaceVariant
              : AppColors.surfaceContainerHigh,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.roundedMd,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.roundedMd,
            borderSide: const BorderSide(color: AppColors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.roundedMd,
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.roundedMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppRadius.roundedMd,
            borderSide:
                const BorderSide(color: AppColors.error, width: 2),
          ),
          labelStyle: AppTypography.labelMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          errorStyle: AppTypography.labelSmall.copyWith(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
