import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Premium text field for authentication screens.
///
/// Wraps [TextFormField] with the StudyFlow AI design tokens.
/// Supports password toggle, prefix icon, and a floating label.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool showToggle = widget.isPassword;

    return Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedLg,
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.isPassword
              ? TextInputType.visiblePassword
              : widget.keyboardType,
          obscureText: widget.isPassword && _obscure,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurface),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            labelStyle: AppTypography.bodyMedium.copyWith(
              color: _isFocused
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            hintStyle: AppTypography.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surfaceVariant
                : AppColors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  )
                : null,
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: AppRadius.roundedLg,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedLg,
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedLg,
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.roundedLg,
              borderSide: const BorderSide(
                  color: AppColors.outlineVariant),
            ),
          ),
        ),
      ),
    );
  }
}
