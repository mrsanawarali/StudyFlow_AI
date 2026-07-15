import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock models  (pure Dart, no Hive / Firebase / backend)
// ─────────────────────────────────────────────────────────────────────────────

class MockUser {
  const MockUser({
    required this.name,
    required this.university,
    required this.semester,
    required this.avatarInitials,
  });
  final String name;
  final String university;
  final String semester;
  final String avatarInitials;
}

class MockSubject {
  const MockSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.professor,
    required this.color,
    required this.progress,
    required this.totalNotes,
  });
  final String id;
  final String name;
  final String code;
  final String professor;
  final Color color;
  final double progress; // 0.0 – 1.0
  final int totalNotes;
}

class MockNote {
  const MockNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.updatedAt,
    required this.isFavorite,
    required this.previewText,
  });
  final String id;
  final String title;
  final String subject;
  final DateTime updatedAt;
  final bool isFavorite;
  final String previewText;
}

class MockAssignment {
  const MockAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
  });
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final AssignmentPriority priority;
  final bool isCompleted;
}

enum AssignmentPriority { high, medium, low }

class MockTimetableEntry {
  const MockTimetableEntry({
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.color,
    this.isNext = false,
  });
  final String subject;
  final String startTime;
  final String endTime;
  final String room;
  final Color color;
  final bool isNext;
}

class MockActivityEntry {
  const MockActivityEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockDashboardData {
  MockDashboardData._();

  static const MockUser user = MockUser(
    name: 'Sanawar Ali',
    university: 'COMSATS University',
    semester: '5th Semester',
    avatarInitials: 'SA',
  );

  static const List<MockSubject> subjects = [
    MockSubject(
      id: 's1',
      name: 'Data Structures',
      code: 'CS-301',
      professor: 'Dr. Ahmed Khan',
      color: Color(0xFF4A90E2),
      progress: 0.72,
      totalNotes: 14,
    ),
    MockSubject(
      id: 's2',
      name: 'Operating Systems',
      code: 'CS-321',
      professor: 'Dr. Sara Malik',
      color: Color(0xFF50E3C2),
      progress: 0.55,
      totalNotes: 9,
    ),
    MockSubject(
      id: 's3',
      name: 'Database Systems',
      code: 'CS-341',
      professor: 'Prof. Tariq Aziz',
      color: Color(0xFFFFA726),
      progress: 0.88,
      totalNotes: 22,
    ),
    MockSubject(
      id: 's4',
      name: 'Software Engineering',
      code: 'CS-311',
      professor: 'Dr. Hina Rao',
      color: Color(0xFFAB47BC),
      progress: 0.40,
      totalNotes: 7,
    ),
    MockSubject(
      id: 's5',
      name: 'Computer Networks',
      code: 'CS-351',
      professor: 'Dr. Imran Shah',
      color: Color(0xFFEF5350),
      progress: 0.63,
      totalNotes: 11,
    ),
  ];

  static final List<MockNote> recentNotes = [
    MockNote(
      id: 'n1',
      title: 'AVL Trees & Rotations',
      subject: 'Data Structures',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      isFavorite: true,
      previewText:
          'An AVL tree is a self-balancing BST where the height difference...',
    ),
    MockNote(
      id: 'n2',
      title: 'Process Scheduling Algorithms',
      subject: 'Operating Systems',
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      isFavorite: false,
      previewText:
          'FCFS, SJF, Round Robin and Priority scheduling comparison...',
    ),
    MockNote(
      id: 'n3',
      title: 'SQL Joins & Normalisation',
      subject: 'Database Systems',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      isFavorite: true,
      previewText: 'INNER JOIN vs OUTER JOIN, 1NF, 2NF, 3NF, BCNF...',
    ),
    MockNote(
      id: 'n4',
      title: 'SDLC Models Overview',
      subject: 'Software Engineering',
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      isFavorite: false,
      previewText: 'Waterfall, Agile, Spiral, and RAD models compared...',
    ),
  ];

  static final List<MockAssignment> upcomingAssignments = [
    MockAssignment(
      id: 'a1',
      title: 'Binary Search Tree Implementation',
      subject: 'Data Structures',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: AssignmentPriority.high,
      isCompleted: false,
    ),
    MockAssignment(
      id: 'a2',
      title: 'ER Diagram — Library System',
      subject: 'Database Systems',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      priority: AssignmentPriority.medium,
      isCompleted: false,
    ),
    MockAssignment(
      id: 'a3',
      title: 'SRS Document Submission',
      subject: 'Software Engineering',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      priority: AssignmentPriority.high,
      isCompleted: false,
    ),
    MockAssignment(
      id: 'a4',
      title: 'TCP/IP Protocol Analysis',
      subject: 'Computer Networks',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: AssignmentPriority.low,
      isCompleted: false,
    ),
  ];

  static const List<MockTimetableEntry> todayTimetable = [
    MockTimetableEntry(
      subject: 'Data Structures',
      startTime: '08:00',
      endTime: '09:30',
      room: 'CS-Lab 3',
      color: Color(0xFF4A90E2),
    ),
    MockTimetableEntry(
      subject: 'Database Systems',
      startTime: '10:00',
      endTime: '11:30',
      room: 'Room 204',
      color: Color(0xFFFFA726),
      isNext: true,
    ),
    MockTimetableEntry(
      subject: 'Software Engineering',
      startTime: '13:00',
      endTime: '14:30',
      room: 'Room 112',
      color: Color(0xFFAB47BC),
    ),
    MockTimetableEntry(
      subject: 'Computer Networks',
      startTime: '15:00',
      endTime: '16:30',
      room: 'CS-Lab 1',
      color: Color(0xFFEF5350),
    ),
  ];

  // Weekly study hours — Mon to Sun
  static const List<double> weeklyHours = [2.0, 4.5, 3.0, 5.0, 1.5, 6.0, 2.5];
  static const List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static final List<MockActivityEntry> recentActivity = [
    const MockActivityEntry(
      icon: Icons.note_add_outlined,
      title: 'Added note',
      subtitle: 'AVL Trees & Rotations',
      time: '2h ago',
      color: Color(0xFF4A90E2),
    ),
    const MockActivityEntry(
      icon: Icons.assignment_turned_in_outlined,
      title: 'Completed assignment',
      subtitle: 'Linked List Problems',
      time: '5h ago',
      color: Color(0xFF4CAF50),
    ),
    const MockActivityEntry(
      icon: Icons.quiz_outlined,
      title: 'Took a quiz',
      subtitle: 'OS Chapter 3 — 85%',
      time: 'Yesterday',
      color: Color(0xFFFFA726),
    ),
    const MockActivityEntry(
      icon: Icons.auto_awesome_outlined,
      title: 'AI Summary generated',
      subtitle: 'SQL Joins & Normalisation',
      time: 'Yesterday',
      color: Color(0xFF50E3C2),
    ),
    const MockActivityEntry(
      icon: Icons.bookmark_added_outlined,
      title: 'Bookmarked note',
      subtitle: 'SRS Document Template',
      time: '2 days ago',
      color: Color(0xFFAB47BC),
    ),
  ];

  // Stats
  static const int totalSubjects = 5;
  static const int totalNotes = 63;
  static const int totalAssignments = 12;
  static const int totalQuizzes = 8;
  static const double overallProgress = 0.64;
}
