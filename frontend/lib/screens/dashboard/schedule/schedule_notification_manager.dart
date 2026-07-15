import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import 'models/schedule_item_local.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class ScheduleNotificationManager {
  static const _idOffsetClass = 10000;
  static const _idOffsetTasks = 20000;
  static const _idOffsetOther = 30000;



  // ------------------------------------------------------------
  // MAIN ENTRY: Reschedule all notifications from Hive safely
  // MAIN ENTRY: Reschedule all notifications from Hive safely
  // ------------------------------------------------------------
  static Future<void> rescheduleAll() async {
    await NotificationService.cancelAll();

    final box = Hive.box<ScheduleItemLocal>("schedule_items");
    final items = box.values.where((e) => !e.isDeleted).toList();
    final now = DateTime.now();

    for (final item in items) {
      // Check if the item has a future date for notifications
      final hasFutureTime = _hasFutureSchedule(item, now);
      if (!hasFutureTime) {
        debugPrint("Skipping past item: ${item.title}");
        continue;
      }

      try {
        await scheduleItem(item);
      } catch (e) {
        debugPrint("Failed to schedule item ${item.title}: $e");
      }
    }
  }

  // ------------------------------------------------------------
  // CHOOSE THE CORRECT NOTIFICATION LOGIC
  // ------------------------------------------------------------
  static Future<void> scheduleItem(ScheduleItemLocal item) async {
    final type = item.type.toLowerCase().trim();

    if (type == "classes") {
      await _scheduleClass(item);
    } else if (type == "quizzes" || type == "assignments") {
      await _scheduleDeadline(item);
    } else {
      await _scheduleOther(item);
    }
  }

  // ------------------------------------------------------------
  // CLASS NOTIFICATION — weekly, 1 hr before
  // ------------------------------------------------------------
  static Future<void> _scheduleClass(ScheduleItemLocal item, {bool testMode = false}) async {
    if (item.day == null || item.startTime == null) return;

    final weekday = _weekdayFromName(item.day!);
    final time = _parseTime(item.startTime!);
    final id = item.localId.hashCode + _idOffsetClass;

    final now = tz.TZDateTime.now(tz.local);

    // Build the next class datetime for this week
    tz.TZDateTime nextClass = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Move forward until it's the correct weekday
    while (nextClass.weekday != weekday || nextClass.subtract(const Duration(hours: 1)).isBefore(now)) {
      nextClass = nextClass.add(const Duration(days: 1));
    }

    // 1️⃣ Schedule first notification (1 hour before class)
    tz.TZDateTime notifTime = nextClass.subtract(const Duration(hours: 1));

    if (testMode) {
      // Fire 5 seconds from now for testing
      notifTime = now.add(const Duration(seconds: 5));
      await NotificationService.scheduleNotification(
        id: id,
        title: item.title,
        body: item.details ?? "Your class is starting soon.",
        dateTime: notifTime,
        repeatPattern: null,
      );
      return;
    }

    await NotificationService.scheduleNotification(
      id: id,
      title: item.title,
      body: item.details ?? "Your class is starting soon.",
      dateTime: notifTime,
      repeatPattern: DateTimeComponents.dayOfWeekAndTime, // weekly repeat starting from first fire
    );

    debugPrint(
        "Scheduled '${item.title}' at ${notifTime.toLocal()} and will repeat weekly (class at ${nextClass.toLocal()})"
    );

    debugPrint("TIMEZONE LOCATION: ${notifTime.location}");
  }

  // ------------------------------------------------------------
  // QUIZ / ASSIGNMENT — 2 hrs before + daily warnings
  // ------------------------------------------------------------
  static Future<void> _scheduleDeadline(ScheduleItemLocal item) async {
    if (item.startDate == null || item.startTime == null) {
      // No date/time → treat like "other"
      return _scheduleOther(item);
    }

    final date = item.startDate!;
    final time = _parseTime(item.startTime!);

    final id = item.localId.hashCode + _idOffsetTasks;

    await NotificationService.scheduleDeadlineTask(
      id: id,
      title: item.title,
      body: item.details ?? "",
      date: date,
      time: time,
    );
  }

  // ------------------------------------------------------------
  // OTHER — flexible rules
  // ------------------------------------------------------------
  static Future<void> _scheduleOther(ScheduleItemLocal item) async {
    final date = item.startDate;
    final time = item.startTime != null ? _parseTime(item.startTime!) : null;

    final id = item.localId.hashCode + _idOffsetOther;

    await NotificationService.scheduleOther(
      id: id,
      title: item.title,
      body: item.details ?? "",
      date: date,
      time: time,
    );
  }

  // ------------------------------------------------------------
  // CANCEL A SINGLE NOTIFICATION
  // ------------------------------------------------------------
  static Future<void> cancelItem(ScheduleItemLocal item) async {
    final type = item.type.toLowerCase().trim();
    int id;

    if (type == "classes") {
      id = item.localId.hashCode + _idOffsetClass;
    } else if (type == "quizzes" || type == "assignments") {
      id = item.localId.hashCode + _idOffsetTasks;
      // Also cancel the secondary daily reminder
      await NotificationService.cancel(id + 9999);
    } else {
      id = item.localId.hashCode + _idOffsetOther;
    }

    await NotificationService.cancel(id);
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  /// Convert "Monday", "mon", "tuesday" → weekday number (1–7)
  static int _weekdayFromName(String name) {
    final n = name.toLowerCase();

    if (n.contains("mon")) return DateTime.monday;
    if (n.contains("tue")) return DateTime.tuesday;
    if (n.contains("wed")) return DateTime.wednesday;
    if (n.contains("thu")) return DateTime.thursday;
    if (n.contains("fri")) return DateTime.friday;
    if (n.contains("sat")) return DateTime.saturday;
    return DateTime.sunday;
  }

  /// Convert "hh:mm AM/PM" → TimeOfDay
  static TimeOfDay _parseTime(String value) {
    // Split by ":" and " " to separate hour, minute, period
    final parts = value.split(RegExp(r'[: ]')); // e.g., ["10", "30", "PM"]
    if (parts.length != 3) {
      throw FormatException("Invalid time format: $value");
    }

    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    final period = parts[2].toUpperCase(); // AM or PM

    if (period == "PM" && hour < 12) hour += 12;
    if (period == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  static bool _hasFutureSchedule(ScheduleItemLocal item, DateTime now) {
    // If it's a class, compute the next class datetime for this week
    if (item.type.toLowerCase().trim() == "classes" &&
        item.day != null &&
        item.startTime != null) {

      final weekday = _weekdayFromName(item.day!);
      final time = _parseTime(item.startTime!);

      // Start from today
      tz.TZDateTime nextClass = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Move forward until the correct weekday
      while (nextClass.weekday != weekday) {
        nextClass = nextClass.add(const Duration(days: 1));
      }

      // If already passed this week, move to next week
      if (nextClass.isBefore(tz.TZDateTime.from(now, tz.local))) {
        nextClass = nextClass.add(const Duration(days: 7));
      }

      return nextClass.isAfter(tz.TZDateTime.from(now, tz.local));
    }

    // If startDate exists (for tasks, deadlines)
    if (item.startDate != null) {
      DateTime scheduled = item.startDate!;
      if (item.startTime != null) {
        final parts = item.startTime!.split(RegExp(r'[: ]'));
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = parts[2].toUpperCase();
        if (period == "PM" && hour < 12) hour += 12;
        if (period == "AM" && hour == 12) hour = 0;
        scheduled = DateTime(scheduled.year, scheduled.month, scheduled.day, hour, minute);
      }
      return scheduled.isAfter(now);
    }

    // Items without a date are always considered future
    return true;
  }


}
