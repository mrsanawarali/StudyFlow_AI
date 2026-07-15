import 'package:flutter/material.dart';

/// Extension methods on [BuildContext] for StudyFlow AI.
extension BuildContextX on BuildContext {
  /// Shorthand for [Theme.of(context)].
  ThemeData get theme => Theme.of(this);

  /// Shorthand for [Theme.of(context).colorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shorthand for [Theme.of(context).textTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Shorthand for [MediaQuery.of(context).size].
  Size get screenSize => MediaQuery.of(this).size;

  /// Shorthand for [MediaQuery.of(context).size.width].
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Shorthand for [MediaQuery.of(this).size.height].
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Returns [true] if the screen width is >= 600dp (tablet breakpoint).
  bool get isTablet => MediaQuery.of(this).size.width >= 600;

  /// Shows a floating SnackBar with [message].
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
