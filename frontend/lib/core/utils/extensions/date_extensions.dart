import '../date_formatter.dart';

/// Extension methods on [DateTime] for StudyFlow AI.
extension DateTimeX on DateTime {
  /// Returns a display-friendly date string: "Jan 1, 2025".
  String get toDisplayString => DateFormatter.toDisplayDate(this);

  /// Returns "Today", "Yesterday", or the display date.
  String get toRelativeString => DateFormatter.toRelativeDate(this);

  /// Returns [true] if this date falls on today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns [true] if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns [true] if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());
}
