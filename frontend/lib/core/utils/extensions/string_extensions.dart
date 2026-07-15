/// Extension methods on [String] for StudyFlow AI.
extension StringX on String {
  /// Returns the string with its first character capitalised.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Returns [true] if this string is a valid email address.
  bool get isValidEmail {
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(trim());
  }

  /// Trims and collapses inner whitespace to a single space.
  String get normalized => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Returns [true] if the string is null or empty after trimming.
  bool get isBlank => trim().isEmpty;
}
