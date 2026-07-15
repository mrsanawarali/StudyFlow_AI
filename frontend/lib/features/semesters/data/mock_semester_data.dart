import 'package:flutter/material.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Semester mock models
// ─────────────────────────────────────────────────────────────────────────────

class MockSemester {
  const MockSemester({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.subjects,
    required this.totalNotes,
    required this.totalAssignments,
    required this.totalQuizzes,
    required this.gpa,
    required this.progress,
    required this.color,
    required this.isActive,
    required this.startDate,
    required this.endDate,
  });

  final String id;
  final String name;
  final String academicYear;
  final List<MockSemesterSubject> subjects;
  final int totalNotes;
  final int totalAssignments;
  final int totalQuizzes;
  final double gpa;
  final double progress; // 0.0 – 1.0
  final Color color;
  final bool isActive;
  final String startDate;
  final String endDate;
}

class MockSemesterSubject {
  const MockSemesterSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.professor,
    required this.color,
    required this.progress,
    required this.creditHours,
    required this.notesCount,
    required this.grade,
  });

  final String id;
  final String name;
  final String code;
  final String professor;
  final Color color;
  final double progress;
  final int creditHours;
  final int notesCount;
  final String? grade; // null = not graded yet
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockSemesterData {
  MockSemesterData._();

  static const List<MockSemesterSubject> _sem5Subjects = [
    MockSemesterSubject(
      id: 'sub-s5-1',
      name: 'Data Structures',
      code: 'CS-301',
      professor: 'Dr. Ahmed Khan',
      color: Color(0xFF4A90E2),
      progress: 0.72,
      creditHours: 3,
      notesCount: 14,
      grade: null,
    ),
    MockSemesterSubject(
      id: 'sub-s5-2',
      name: 'Operating Systems',
      code: 'CS-321',
      professor: 'Dr. Sara Malik',
      color: Color(0xFF50E3C2),
      progress: 0.55,
      creditHours: 3,
      notesCount: 9,
      grade: null,
    ),
    MockSemesterSubject(
      id: 'sub-s5-3',
      name: 'Database Systems',
      code: 'CS-341',
      professor: 'Prof. Tariq Aziz',
      color: Color(0xFFFFA726),
      progress: 0.88,
      creditHours: 3,
      notesCount: 22,
      grade: null,
    ),
    MockSemesterSubject(
      id: 'sub-s5-4',
      name: 'Software Engineering',
      code: 'CS-311',
      professor: 'Dr. Hina Rao',
      color: Color(0xFFAB47BC),
      progress: 0.40,
      creditHours: 3,
      notesCount: 7,
      grade: null,
    ),
    MockSemesterSubject(
      id: 'sub-s5-5',
      name: 'Computer Networks',
      code: 'CS-351',
      professor: 'Dr. Imran Shah',
      color: Color(0xFFEF5350),
      progress: 0.63,
      creditHours: 3,
      notesCount: 11,
      grade: null,
    ),
  ];

  static const List<MockSemesterSubject> _sem4Subjects = [
    MockSemesterSubject(
      id: 'sub-s4-1',
      name: 'Discrete Mathematics',
      code: 'CS-201',
      professor: 'Dr. Farida Haq',
      color: Color(0xFF4A90E2),
      progress: 1.0,
      creditHours: 3,
      notesCount: 18,
      grade: 'A',
    ),
    MockSemesterSubject(
      id: 'sub-s4-2',
      name: 'Digital Logic Design',
      code: 'EE-211',
      professor: 'Prof. Kamran Ali',
      color: Color(0xFF66BB6A),
      progress: 1.0,
      creditHours: 3,
      notesCount: 12,
      grade: 'B+',
    ),
    MockSemesterSubject(
      id: 'sub-s4-3',
      name: 'Object Oriented Programming',
      code: 'CS-221',
      professor: 'Dr. Nadia Siddiqui',
      color: Color(0xFFFFA726),
      progress: 1.0,
      creditHours: 3,
      notesCount: 25,
      grade: 'A',
    ),
    MockSemesterSubject(
      id: 'sub-s4-4',
      name: 'Computer Architecture',
      code: 'CS-231',
      professor: 'Dr. Zubair Awan',
      color: Color(0xFFEF5350),
      progress: 1.0,
      creditHours: 3,
      notesCount: 16,
      grade: 'A-',
    ),
  ];

  static const List<MockSemesterSubject> _sem3Subjects = [
    MockSemesterSubject(
      id: 'sub-s3-1',
      name: 'Calculus & Analytical Geometry',
      code: 'MATH-101',
      professor: 'Dr. Asif Raza',
      color: Color(0xFF26C6DA),
      progress: 1.0,
      creditHours: 3,
      notesCount: 20,
      grade: 'B+',
    ),
    MockSemesterSubject(
      id: 'sub-s3-2',
      name: 'Programming Fundamentals',
      code: 'CS-101',
      professor: 'Dr. Rabia Batool',
      color: Color(0xFF66BB6A),
      progress: 1.0,
      creditHours: 3,
      notesCount: 30,
      grade: 'A',
    ),
    MockSemesterSubject(
      id: 'sub-s3-3',
      name: 'Applied Physics',
      code: 'PHY-101',
      professor: 'Prof. Amjad Hussain',
      color: Color(0xFFAB47BC),
      progress: 1.0,
      creditHours: 3,
      notesCount: 14,
      grade: 'A-',
    ),
  ];

  static final List<MockSemester> semesters = [
    MockSemester(
      id: 'sem-5',
      name: '5th Semester',
      academicYear: '2024 – 2025',
      subjects: _sem5Subjects,
      totalNotes: 63,
      totalAssignments: 12,
      totalQuizzes: 8,
      gpa: 0.0, // in progress
      progress: 0.64,
      color: const Color(0xFF4A90E2),
      isActive: true,
      startDate: 'Sep 2024',
      endDate: 'Jan 2025',
    ),
    MockSemester(
      id: 'sem-4',
      name: '4th Semester',
      academicYear: '2023 – 2024',
      subjects: _sem4Subjects,
      totalNotes: 71,
      totalAssignments: 18,
      totalQuizzes: 14,
      gpa: 3.65,
      progress: 1.0,
      color: const Color(0xFF50E3C2),
      isActive: false,
      startDate: 'Feb 2024',
      endDate: 'Jun 2024',
    ),
    MockSemester(
      id: 'sem-3',
      name: '3rd Semester',
      academicYear: '2023',
      subjects: _sem3Subjects,
      totalNotes: 64,
      totalAssignments: 15,
      totalQuizzes: 10,
      gpa: 3.55,
      progress: 1.0,
      color: const Color(0xFFFFA726),
      isActive: false,
      startDate: 'Sep 2023',
      endDate: 'Jan 2024',
    ),
    MockSemester(
      id: 'sem-2',
      name: '2nd Semester',
      academicYear: '2022 – 2023',
      subjects: const [],
      totalNotes: 42,
      totalAssignments: 11,
      totalQuizzes: 7,
      gpa: 3.40,
      progress: 1.0,
      color: const Color(0xFFAB47BC),
      isActive: false,
      startDate: 'Feb 2023',
      endDate: 'Jun 2023',
    ),
    MockSemester(
      id: 'sem-1',
      name: '1st Semester',
      academicYear: '2022',
      subjects: const [],
      totalNotes: 35,
      totalAssignments: 8,
      totalQuizzes: 5,
      gpa: 3.30,
      progress: 1.0,
      color: const Color(0xFF66BB6A),
      isActive: false,
      startDate: 'Sep 2022',
      endDate: 'Jan 2023',
    ),
  ];

  // Reuse dashboard deadlines for semester detail
  static List<MockAssignment> get semesterDeadlines =>
      MockDashboardData.upcomingAssignments;

  // Reuse dashboard notes for semester detail
  static List<MockNote> get semesterRecentNotes =>
      MockDashboardData.recentNotes;
}
