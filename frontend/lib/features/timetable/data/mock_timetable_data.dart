import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Timetable mock models
// ─────────────────────────────────────────────────────────────────────────────

class MockClass {
  const MockClass({
    required this.id,
    required this.subject,
    required this.code,
    required this.professor,
    required this.room,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.color,
    required this.weekdays, // 1=Mon…7=Sun
    required this.type,
  });

  final String id;
  final String subject;
  final String code;
  final String professor;
  final String room;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final Color color;
  final List<int> weekdays;
  final ClassType type;

  String get startTime =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endTime =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  int get startMinutes => startHour * 60 + startMinute;
  int get endMinutes => endHour * 60 + endMinute;
  int get durationMinutes => endMinutes - startMinutes;
}

enum ClassType { lecture, lab, tutorial }

class MockAttendanceRecord {
  const MockAttendanceRecord({
    required this.subjectId,
    required this.subject,
    required this.color,
    required this.totalClasses,
    required this.attended,
    required this.required, // minimum % required
  });

  final String subjectId;
  final String subject;
  final Color color;
  final int totalClasses;
  final int attended;
  final double required;

  double get percentage => totalClasses == 0 ? 0 : (attended / totalClasses) * 100;
  bool get isSafe => percentage >= required;
}

class MockDeadline {
  const MockDeadline({
    required this.id,
    required this.title,
    required this.subject,
    required this.color,
    required this.dueDate,
    required this.type,
  });

  final String id;
  final String title;
  final String subject;
  final Color color;
  final DateTime dueDate;
  final String type; // 'assignment' | 'quiz' | 'project'
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockTimetableData {
  MockTimetableData._();

  static const List<MockClass> classes = [
    // Monday + Wednesday + Friday — Data Structures
    MockClass(
      id: 'cls-ds',
      subject: 'Data Structures',
      code: 'CS-301',
      professor: 'Dr. Ahmed Khan',
      room: 'CS-Lab 3',
      startHour: 8, startMinute: 0,
      endHour: 9, endMinute: 30,
      color: Color(0xFF4A90E2),
      weekdays: [1, 3, 5],
      type: ClassType.lecture,
    ),
    // Monday + Wednesday — Operating Systems
    MockClass(
      id: 'cls-os',
      subject: 'Operating Systems',
      code: 'CS-321',
      professor: 'Dr. Sara Malik',
      room: 'Room 105',
      startHour: 10, startMinute: 0,
      endHour: 11, endMinute: 30,
      color: Color(0xFF50E3C2),
      weekdays: [1, 3],
      type: ClassType.lecture,
    ),
    // Tuesday + Thursday — Database Systems
    MockClass(
      id: 'cls-db',
      subject: 'Database Systems',
      code: 'CS-341',
      professor: 'Prof. Tariq Aziz',
      room: 'Room 204',
      startHour: 10, startMinute: 0,
      endHour: 11, endMinute: 30,
      color: Color(0xFFFFA726),
      weekdays: [2, 4],
      type: ClassType.lecture,
    ),
    // Tuesday + Thursday — Software Engineering
    MockClass(
      id: 'cls-se',
      subject: 'Software Engineering',
      code: 'CS-311',
      professor: 'Dr. Hina Rao',
      room: 'Room 112',
      startHour: 13, startMinute: 0,
      endHour: 14, endMinute: 30,
      color: Color(0xFFAB47BC),
      weekdays: [2, 4],
      type: ClassType.lecture,
    ),
    // Monday + Wednesday + Friday — Computer Networks
    MockClass(
      id: 'cls-cn',
      subject: 'Computer Networks',
      code: 'CS-351',
      professor: 'Dr. Imran Shah',
      room: 'CS-Lab 1',
      startHour: 15, startMinute: 0,
      endHour: 16, endMinute: 30,
      color: Color(0xFFEF5350),
      weekdays: [1, 3, 5],
      type: ClassType.lecture,
    ),
    // Wednesday — DS Lab
    MockClass(
      id: 'cls-ds-lab',
      subject: 'Data Structures Lab',
      code: 'CS-301L',
      professor: 'Mr. Bilal Ahmed',
      room: 'CS-Lab 2',
      startHour: 14, startMinute: 0,
      endHour: 16, endMinute: 0,
      color: Color(0xFF4A90E2),
      weekdays: [3],
      type: ClassType.lab,
    ),
  ];

  // Returns classes for a given weekday (1=Mon, 7=Sun)
  static List<MockClass> forDay(int weekday) {
    final list = classes
        .where((c) => c.weekdays.contains(weekday))
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return list;
  }

  // Returns today's classes
  static List<MockClass> get todayClasses =>
      forDay(DateTime.now().weekday);

  // Next upcoming class today
  static MockClass? get nextClass {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    return todayClasses
        .where((c) => c.startMinutes > nowMins)
        .firstOrNull;
  }

  // Currently running class
  static MockClass? get currentClass {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    return todayClasses
        .where((c) => c.startMinutes <= nowMins && c.endMinutes > nowMins)
        .firstOrNull;
  }

  // Attendance records
  static const List<MockAttendanceRecord> attendance = [
    MockAttendanceRecord(
      subjectId: 'sub-s5-1',
      subject: 'Data Structures',
      color: Color(0xFF4A90E2),
      totalClasses: 24,
      attended: 21,
      required: 75,
    ),
    MockAttendanceRecord(
      subjectId: 'sub-s5-2',
      subject: 'Operating Systems',
      color: Color(0xFF50E3C2),
      totalClasses: 18,
      attended: 15,
      required: 75,
    ),
    MockAttendanceRecord(
      subjectId: 'sub-s5-3',
      subject: 'Database Systems',
      color: Color(0xFFFFA726),
      totalClasses: 20,
      attended: 19,
      required: 75,
    ),
    MockAttendanceRecord(
      subjectId: 'sub-s5-4',
      subject: 'Software Engineering',
      color: Color(0xFFAB47BC),
      totalClasses: 16,
      attended: 12,
      required: 75,
    ),
    MockAttendanceRecord(
      subjectId: 'sub-s5-5',
      subject: 'Computer Networks',
      color: Color(0xFFEF5350),
      totalClasses: 22,
      attended: 20,
      required: 75,
    ),
  ];

  // Weekly study hours (Mon–Sun)
  static const List<double> weeklyStudyHours = [
      4.5, 3.0, 5.5, 2.5, 4.0, 6.0, 1.5];
  static const List<String> weekDayLabels = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Upcoming deadlines
  static final List<MockDeadline> upcomingDeadlines = [
    MockDeadline(
      id: 'd1',
      title: 'BST Implementation',
      subject: 'Data Structures',
      color: const Color(0xFF4A90E2),
      dueDate: DateTime.now().add(const Duration(days: 1)),
      type: 'assignment',
    ),
    MockDeadline(
      id: 'd2',
      title: 'Quiz 3 — Graphs',
      subject: 'Data Structures',
      color: const Color(0xFF4A90E2),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      type: 'quiz',
    ),
    MockDeadline(
      id: 'd3',
      title: 'ER Diagram Submission',
      subject: 'Database Systems',
      color: const Color(0xFFFFA726),
      dueDate: DateTime.now().add(const Duration(days: 3)),
      type: 'assignment',
    ),
    MockDeadline(
      id: 'd4',
      title: 'SRS Document',
      subject: 'Software Engineering',
      color: const Color(0xFFAB47BC),
      dueDate: DateTime.now().add(const Duration(days: 5)),
      type: 'assignment',
    ),
  ];

  // Stats
  static const int totalClassesThisWeek = 12;
  static const double overallAttendance = 87.0;
  static const double totalStudyHoursThisWeek = 27.0;
  static const int pendingAssignments = 4;
}
