import 'package:flutter/material.dart';

/// Mixin for managing a boolean loading state in [StatefulWidget]s.
///
/// Usage:
/// ```dart
/// class LoginState extends State<LoginScreen> with LoadingStateMixin {
///   Future<void> _submit() async {
///     setLoading(true);
///     try {
///       await _authenticate();
///     } finally {
///       setLoading(false);
///     }
///   }
/// }
///
/// // In build:
/// PrimaryButton(
///   text: 'Login',
///   isLoading: isLoading,
///   onPressed: isLoading ? null : _submit,
/// )
/// ```
mixin LoadingStateMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  /// Whether an async operation is currently in progress.
  bool get isLoading => _isLoading;

  /// Updates [isLoading] and triggers a rebuild if the value changes.
  void setLoading(bool value) {
    if (_isLoading != value && mounted) {
      setState(() => _isLoading = value);
    }
  }

  /// Executes [operation] with loading state management.
  /// Sets [isLoading] to [true] before the call and [false] after,
  /// even if an exception is thrown.
  Future<R?> withLoading<R>(Future<R> Function() operation) async {
    setLoading(true);
    try {
      return await operation();
    } finally {
      setLoading(false);
    }
  }
}
