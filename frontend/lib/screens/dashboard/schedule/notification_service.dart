
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = 'schedule_channel';
  static const String _channelName = 'Schedule Notifications';
  static const String _channelDesc = 'Notifications for classes and tasks';



  // ------------------------------------------------------------
  // INITIALIZATION
  // ------------------------------------------------------------
  static Future<void> init() async {


    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification tapped: ${response.payload}");
      },
    );
  }

  // ------------------------------------------------------------
  // CANCEL HELPERS
  // ------------------------------------------------------------
  static Future<void> cancel(int id) async => _plugin.cancel(id);

  static Future<void> cancelAll() async => _plugin.cancelAll();

  // ------------------------------------------------------------
  // BASE SCHEDULE FUNCTION
  // ------------------------------------------------------------
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime dateTime,
    DateTimeComponents? repeatPattern,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      dateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatPattern,
      payload: payload,
    );
  }

  // ------------------------------------------------------------
  // UTILITY HELPERS
  // ------------------------------------------------------------
  static tz.TZDateTime _nextTime(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static tz.TZDateTime combineDateTime(DateTime date, TimeOfDay? time) {
    return tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time?.hour ?? 9,
      time?.minute ?? 0,
    );
  }

  // ------------------------------------------------------------
  // CLASS NOTIFICATION — 1hr BEFORE — WEEKLY
  // ------------------------------------------------------------
  static Future<void> scheduleClass({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required TimeOfDay classTime,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    // Find the next occurrence of this weekday
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      classTime.hour,
      classTime.minute,
    );

    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // Fire 1 hour before
    scheduled = scheduled.subtract(const Duration(hours: 1));

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      dateTime: scheduled,
      // Remove exact weekly pattern to avoid exact alarms
      repeatPattern: null,
    );
  }

  // ------------------------------------------------------------
  // QUIZ / ASSIGNMENT — 2hrs BEFORE — AND DAILY UNTIL DEADLINE
  // ------------------------------------------------------------
  static Future<void> scheduleDeadlineTask({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required TimeOfDay time,
  }) async {
    // --- 2 HOURS BEFORE ---
    final mainAlert = combineDateTime(date, time).subtract(const Duration(hours: 2));

    await scheduleNotification(
      id: id,
      title: title,
      body: body,
      dateTime: mainAlert,
    );

    // --- DAILY REMINDER ---
    TimeOfDay dailyTime = const TimeOfDay(hour: 10, minute: 0);

    final dailyStart = _nextTime(dailyTime);

    await scheduleNotification(
      id: id + 9999, // secondary repeated id
      title: title,
      body: "Deadline approaching: $title",
      dateTime: dailyStart,
      repeatPattern: DateTimeComponents.time, // DAILY
    );
  }

  // ------------------------------------------------------------
  // OTHER TYPE — flexible logic
  // ------------------------------------------------------------
  static Future<void> scheduleOther({
    required int id,
    required String title,
    required String body,
    DateTime? date,
    TimeOfDay? time,
  }) async {
    // CASE 1 — both present (same as deadline rule)
    if (date != null && time != null) {
      return scheduleDeadlineTask(
        id: id,
        title: title,
        body: body,
        date: date,
        time: time,
      );
    }

    // CASE 2 — only time present → fire today/tomorrow 2 hrs before
    if (date == null && time != null) {
      final t = _nextTime(time).subtract(const Duration(hours: 2));

      return scheduleNotification(
        id: id,
        title: title,
        body: body,
        dateTime: t,
      );
    }

    // CASE 3 — only date present → daily at 10 AM
    if (date != null && time == null) {
      final dailyTime = const TimeOfDay(hour: 10, minute: 0);

      final first = _nextTime(dailyTime);

      return scheduleNotification(
        id: id,
        title: title,
        body: body,
        dateTime: first,
        repeatPattern: DateTimeComponents.time,
      );
    }

    // CASE 4 — nothing present → daily at 9 AM
    final defaultTime = const TimeOfDay(hour: 9, minute: 0);
    final first = _nextTime(defaultTime);

    return scheduleNotification(
      id: id,
      title: title,
      body: body,
      dateTime: first,
      repeatPattern: DateTimeComponents.time,
    );
  }

}
