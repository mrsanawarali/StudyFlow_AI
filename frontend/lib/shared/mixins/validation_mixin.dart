import '../../core/utils/validators.dart';

/// Mixin providing field validation helpers for form widgets.
/// Delegates to the [Validators] utility class.
///
/// Usage:
/// ```dart
/// class LoginState extends State<LoginScreen> with ValidationMixin {
///   String? _validateEmail(String? value) => validateEmail(value);
/// }
/// ```
mixin ValidationMixin {
  /// Validates an email address.
  /// Returns an error string or [null] if valid.
  String? validateEmail(String? value) => Validators.email(value);

  /// Validates a password (minimum 8 characters).
  /// Returns an error string or [null] if valid.
  String? validatePassword(String? value) => Validators.password(value);

  /// Validates that a required field is not empty.
  /// Returns an error string or [null] if valid.
  String? validateRequired(String? value, String fieldName) =>
      Validators.required(value, fieldName);

  /// Validates a name field.
  /// Returns an error string or [null] if valid.
  String? validateName(String? value) => Validators.name(value);
}
