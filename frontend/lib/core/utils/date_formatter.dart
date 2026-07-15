import 'package:intl/intl.dart';

/// Date and time formatting utilities for StudyFlow AI.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortFormat = DateFormat('d MMM');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _fullFormat = DateFormat('EEEE, MMM d, yyyy');

  /// Formats [dateTime] as "Jan 1, 2025".
  static String toDisplayDate(DateTime dateTime) =>
      _displayFormat.format(dateTime);

  /// Formats [dateTime] as "1 Jan".
  static String toShortDate(DateTime dateTime) =>
      _shortFormat.format(dateTime);

  /// Formats [dateTime] as "10:30 AM".
  static String toTime(DateTime dateTime) => _timeFormat.format(dateTime);

  /// Formats [dateTime] as "Monday, Jan 1, 2025".
  static String toFullDate(DateTime dateTime) => _fullFormat.format(dateTime);

  /// Returns "Today", "Yesterday", or the display date.
  static String toRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return toDisplayDate(dateTime);
  }
}
