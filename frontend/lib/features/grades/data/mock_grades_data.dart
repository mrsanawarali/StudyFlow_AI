import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Grade mock models
// ─────────────────────────────────────────────────────────────────────────────

class MockSubjectGrade {
  const MockSubjectGrade({
    required this.id,
    required this.name,
    required this.code,
    required this.creditHours,
    required this.color,
    required this.midMarks,
    required this.midTotal,
    required this.assignmentMarks,
    required this.assignmentTotal,
    required this.quizMarks,
    required this.quizTotal,
    required this.finalMarks,
    required this.finalTotal,
    required this.letterGrade,
    required this.gradePoints,
  });

  final String id;
  final String name;
  final String code;
  final int creditHours;
  final Color color;
  final double midMarks;
  final double midTotal;
  final double assignmentMarks;
  final double assignmentTotal;
  final double quizMarks;
  final double quizTotal;
  final double? finalMarks;   // null = not yet taken
  final double finalTotal;
  final String? letterGrade;  // null = in progress
  final double? gradePoints;  // null = in progress

  double get currentPercentage {
    final earned = midMarks + assignmentMarks + quizMarks +
        (finalMarks ?? 0);
    final possible = midTotal + assignmentTotal + quizTotal +
        (finalMarks != null ? finalTotal : 0);
    return possible == 0 ? 0 : (earned / possible) * 100;
  }
}

class MockSemesterRecord {
  const MockSemesterRecord({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.creditHours,
    required this.gpa,
    required this.color,
  });

  final String id;
  final String name;
  final String academicYear;
  final int creditHours;
  final double gpa;
  final Color color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockGradesData {
  MockGradesData._();

  // Current semester subjects
  static const List<MockSubjectGrade> currentSubjects = [
    MockSubjectGrade(
      id: 'sg-1',
      name: 'Data Structures',
      code: 'CS-301',
      creditHours: 3,
      color: Color(0xFF4A90E2),
      midMarks: 22, midTotal: 30,
      assignmentMarks: 17, assignmentTotal: 20,
      quizMarks: 8, quizTotal: 10,
      finalMarks: null, finalTotal: 40,
      letterGrade: null, gradePoints: null,
    ),
    MockSubjectGrade(
      id: 'sg-2',
      name: 'Operating Systems',
      code: 'CS-321',
      creditHours: 3,
      color: Color(0xFF50E3C2),
      midMarks: 19, midTotal: 30,
      assignmentMarks: 18, assignmentTotal: 20,
      quizMarks: 7, quizTotal: 10,
      finalMarks: null, finalTotal: 40,
      letterGrade: null, gradePoints: null,
    ),
    MockSubjectGrade(
      id: 'sg-3',
      name: 'Database Systems',
      code: 'CS-341',
      creditHours: 3,
      color: Color(0xFFFFA726),
      midMarks: 27, midTotal: 30,
      assignmentMarks: 19, assignmentTotal: 20,
      quizMarks: 9, quizTotal: 10,
      finalMarks: null, finalTotal: 40,
      letterGrade: null, gradePoints: null,
    ),
    MockSubjectGrade(
      id: 'sg-4',
      name: 'Software Engineering',
      code: 'CS-311',
      creditHours: 3,
      color: Color(0xFFAB47BC),
      midMarks: 16, midTotal: 30,
      assignmentMarks: 15, assignmentTotal: 20,
      quizMarks: 6, quizTotal: 10,
      finalMarks: null, finalTotal: 40,
      letterGrade: null, gradePoints: null,
    ),
    MockSubjectGrade(
      id: 'sg-5',
      name: 'Computer Networks',
      code: 'CS-351',
      creditHours: 3,
      color: Color(0xFFEF5350),
      midMarks: 21, midTotal: 30,
      assignmentMarks: 17, assignmentTotal: 20,
      quizMarks: 8, quizTotal: 10,
      finalMarks: null, finalTotal: 40,
      letterGrade: null, gradePoints: null,
    ),
  ];

  // Past semester records (for CGPA)
  static const List<MockSemesterRecord> semesterRecords = [
    MockSemesterRecord(
      id: 'sem-1',
      name: '1st Semester',
      academicYear: '2022',
      creditHours: 15,
      gpa: 3.30,
      color: Color(0xFF66BB6A),
    ),
    MockSemesterRecord(
      id: 'sem-2',
      name: '2nd Semester',
      academicYear: '2022–23',
      creditHours: 15,
      gpa: 3.40,
      color: Color(0xFFAB47BC),
    ),
    MockSemesterRecord(
      id: 'sem-3',
      name: '3rd Semester',
      academicYear: '2023',
      creditHours: 15,
      gpa: 3.55,
      color: Color(0xFFFFA726),
    ),
    MockSemesterRecord(
      id: 'sem-4',
      name: '4th Semester',
      academicYear: '2023–24',
      creditHours: 18,
      gpa: 3.65,
      color: Color(0xFF50E3C2),
    ),
    // 5th semester — in progress, estimated
    MockSemesterRecord(
      id: 'sem-5',
      name: '5th Semester',
      academicYear: '2024–25',
      creditHours: 15,
      gpa: 3.50, // projected
      color: Color(0xFF4A90E2),
    ),
  ];

  // Grade scale (Pakistan HEC)
  static const List<_GradeScale> gradeScale = [
    _GradeScale('A+', 4.00, 90, 100, Color(0xFF4CAF50)),
    _GradeScale('A',  4.00, 85, 89,  Color(0xFF66BB6A)),
    _GradeScale('A-', 3.70, 80, 84,  Color(0xFF81C784)),
    _GradeScale('B+', 3.30, 75, 79,  Color(0xFF4A90E2)),
    _GradeScale('B',  3.00, 70, 74,  Color(0xFF64B5F6)),
    _GradeScale('B-', 2.70, 65, 69,  Color(0xFF90CAF9)),
    _GradeScale('C+', 2.30, 60, 64,  Color(0xFFFFA726)),
    _GradeScale('C',  2.00, 55, 59,  Color(0xFFFFB74D)),
    _GradeScale('D',  1.00, 50, 54,  Color(0xFFEF9A9A)),
    _GradeScale('F',  0.00, 0,  49,  Color(0xFFEF5350)),
  ];

  static double get cgpa {
    int totalCredits = 0;
    double weightedSum = 0;
    for (final s in semesterRecords) {
      weightedSum += s.gpa * s.creditHours;
      totalCredits += s.creditHours;
    }
    return totalCredits == 0 ? 0 : weightedSum / totalCredits;
  }

  static int get totalCreditHours =>
      semesterRecords.fold(0, (s, r) => s + r.creditHours);

  static String letterGradeFrom(double pct) {
    for (final g in gradeScale) {
      if (pct >= g.minPct) return g.letter;
    }
    return 'F';
  }

  static double gradePointsFrom(double pct) {
    for (final g in gradeScale) {
      if (pct >= g.minPct) return g.points;
    }
    return 0;
  }
}

class _GradeScale {
  const _GradeScale(this.letter, this.points, this.minPct, this.maxPct, this.color);
  final String letter;
  final double points;
  final int minPct;
  final int maxPct;
  final Color color;
}
