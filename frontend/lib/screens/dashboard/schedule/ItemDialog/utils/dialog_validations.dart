// dialog_validations.dart

import 'package:flutter/material.dart';

/// --- Helper Functions --- ///
DateTime? combineDateTime(DateTime? date, TimeOfDay? time) {
  if (date == null) return null;
  if (time == null) return date;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  return date.toLocal().toString().split(' ')[0];
}

String formatTime(TimeOfDay? time) {
  if (time == null) return '';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period.name.toUpperCase();
  return '$hour:$minute $period';
}

TimeOfDay parseTimeOfDay(String timeStr) {
  try {
    if (timeStr.contains(RegExp(r'AM|PM', caseSensitive: false))) {
      final parts = timeStr.split(RegExp(r'[: ]'));
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final isPM = parts[2].toLowerCase() == 'pm';
      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } else {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  } catch (_) {
    return TimeOfDay.now();
  }
}

/// --- Unified Validator --- ///
String? validateSchedule({
  required String type,
  String? title,
  DateTime? startDate,
  TimeOfDay? startTime,
  DateTime? endDate,
  TimeOfDay? endTime,
  String? day,
}) {
  if (title == null || title.trim().isEmpty) return 'Title is required';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startDT = combineDateTime(startDate, startTime);
  final endDT = combineDateTime(endDate, endTime);

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool isEndAfterStart(TimeOfDay start, TimeOfDay end) =>
      (end.hour * 60 + end.minute) > (start.hour * 60 + start.minute);

  bool endBeforeStart(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return end.isBefore(start);
  }

  /// --- Type-specific validations --- ///
  if (type == 'Classes') {
    if (day == null) return 'Please select a day';
    if (startTime == null) return 'Start time is required';
    if (endTime == null) return 'End time is required';
    if (!isEndAfterStart(startTime, endTime)) return 'End time must be after start time';

    if (startDT != null && isSameDay(startDT, today) && startDT.isBefore(now)) {
      return 'Start time cannot be in the past';
    }
  } else if (type == 'Quizzes' || type == 'Assignments') {
    if (startDate == null) return 'Date is required';
    if (startTime == null) return 'Time is required';

    if (startDT != null && isSameDay(startDT, today) && startDT.isBefore(now)) {
      return 'Date & time cannot be in the past';
    }
  } else { // Others
    if (startDT != null && isSameDay(startDT, today) && startDT.isBefore(now)) {
      return 'Start datetime cannot be in the past';
    }

    if (endDT != null) {
      if (startDT != null && !endDT.isAfter(startDT)) {
        return 'End datetime must be after start datetime';
      }

      if (isSameDay(endDT, today) && endDT.isBefore(now)) {
        return 'End datetime cannot be in the past';
      }
    }

    if (startDate != null && endDate != null && endBeforeStart(startDate, endDate)) {
      return 'End date cannot be before start date';
    }
  }

  return null; // all validations passed
}

/// --- Snack Helper ---
void showErrorSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
  );
}
