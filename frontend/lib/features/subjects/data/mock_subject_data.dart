import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Subject-level mock models
// ─────────────────────────────────────────────────────────────────────────────

class MockSubjectDetail {
  const MockSubjectDetail({
    required this.id,
    required this.semesterId,
    required this.name,
    required this.code,
    required this.professor,
    required this.color,
    required this.progress,
    required this.creditHours,
    required this.attendancePercent,
    required this.currentGrade,
    required this.notes,
    required this.assignments,
    required this.quizzes,
    required this.recentTopics,
    required this.studyGoalHours,
    required this.studiedHours,
  });

  final String id;
  final String semesterId;
  final String name;
  final String code;
  final String professor;
  final Color color;
  final double progress;
  final int creditHours;
  final double attendancePercent;
  final String? currentGrade;
  final List<MockSubjectNote> notes;
  final List<MockSubjectAssignment> assignments;
  final List<MockSubjectQuiz> quizzes;
  final List<String> recentTopics;
  final double studyGoalHours;
  final double studiedHours;
}

class MockSubjectNote {
  const MockSubjectNote({
    required this.id,
    required this.title,
    required this.updatedAt,
    required this.isFavorite,
    required this.preview,
    required this.pageCount,
  });
  final String id;
  final String title;
  final DateTime updatedAt;
  final bool isFavorite;
  final String preview;
  final int pageCount;
}

class MockSubjectAssignment {
  const MockSubjectAssignment({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isSubmitted,
    required this.marks,
    required this.totalMarks,
    required this.priority,
  });
  final String id;
  final String title;
  final DateTime dueDate;
  final bool isSubmitted;
  final int? marks;
  final int totalMarks;
  final String priority; // 'high' | 'medium' | 'low'
}

class MockSubjectQuiz {
  const MockSubjectQuiz({
    required this.id,
    required this.title,
    required this.date,
    required this.score,
    required this.totalScore,
    required this.isDone,
  });
  final String id;
  final String title;
  final DateTime date;
  final int? score;
  final int totalScore;
  final bool isDone;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data keyed by subject id
// ─────────────────────────────────────────────────────────────────────────────

class MockSubjectData {
  MockSubjectData._();

  static final Map<String, MockSubjectDetail> _details = {
    'sub-s5-1': MockSubjectDetail(
      id: 'sub-s5-1',
      semesterId: 'sem-5',
      name: 'Data Structures',
      code: 'CS-301',
      professor: 'Dr. Ahmed Khan',
      color: const Color(0xFF4A90E2),
      progress: 0.72,
      creditHours: 3,
      attendancePercent: 88,
      currentGrade: null,
      recentTopics: [
        'AVL Trees & Rotations',
        'B-Trees & B+ Trees',
        'Graph Traversals (BFS/DFS)',
        'Heap & Priority Queue',
        'Hashing Techniques',
      ],
      studyGoalHours: 40,
      studiedHours: 28.5,
      notes: [
        MockSubjectNote(
          id: 'n-ds-1',
          title: 'AVL Trees & Rotations',
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          isFavorite: true,
          preview:
              'An AVL tree is a self-balancing BST where the height difference between left and right subtrees is at most 1.',
          pageCount: 5,
        ),
        MockSubjectNote(
          id: 'n-ds-2',
          title: 'Graph Traversal Algorithms',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFavorite: false,
          preview:
              'BFS uses a queue and explores neighbours level by level. DFS uses a stack or recursion.',
          pageCount: 4,
        ),
        MockSubjectNote(
          id: 'n-ds-3',
          title: 'Hashing & Collision Resolution',
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          isFavorite: true,
          preview:
              'Open addressing: linear probing, quadratic probing. Chaining: linked list per bucket.',
          pageCount: 6,
        ),
      ],
      assignments: [
        MockSubjectAssignment(
          id: 'a-ds-1',
          title: 'BST Implementation in C++',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isSubmitted: false,
          marks: null,
          totalMarks: 20,
          priority: 'high',
        ),
        MockSubjectAssignment(
          id: 'a-ds-2',
          title: 'Dijkstra\'s Algorithm Report',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isSubmitted: false,
          marks: null,
          totalMarks: 15,
          priority: 'medium',
        ),
        MockSubjectAssignment(
          id: 'a-ds-3',
          title: 'Sorting Analysis Lab',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          isSubmitted: true,
          marks: 18,
          totalMarks: 20,
          priority: 'low',
        ),
      ],
      quizzes: [
        MockSubjectQuiz(
          id: 'q-ds-1',
          title: 'Quiz 1 — Arrays & Linked Lists',
          date: DateTime.now().subtract(const Duration(days: 14)),
          score: 9,
          totalScore: 10,
          isDone: true,
        ),
        MockSubjectQuiz(
          id: 'q-ds-2',
          title: 'Quiz 2 — Trees',
          date: DateTime.now().subtract(const Duration(days: 7)),
          score: 8,
          totalScore: 10,
          isDone: true,
        ),
        MockSubjectQuiz(
          id: 'q-ds-3',
          title: 'Quiz 3 — Graphs',
          date: DateTime.now().add(const Duration(days: 3)),
          score: null,
          totalScore: 10,
          isDone: false,
        ),
      ],
    ),

    'sub-s5-2': MockSubjectDetail(
      id: 'sub-s5-2',
      semesterId: 'sem-5',
      name: 'Operating Systems',
      code: 'CS-321',
      professor: 'Dr. Sara Malik',
      color: const Color(0xFF50E3C2),
      progress: 0.55,
      creditHours: 3,
      attendancePercent: 82,
      currentGrade: null,
      recentTopics: [
        'Process Scheduling',
        'Memory Management',
        'Deadlocks',
        'File Systems',
        'Virtual Memory',
      ],
      studyGoalHours: 35,
      studiedHours: 19,
      notes: [
        MockSubjectNote(
          id: 'n-os-1',
          title: 'Process Scheduling Algorithms',
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          isFavorite: false,
          preview:
              'FCFS, SJF, Round Robin and Priority scheduling algorithms compared with examples.',
          pageCount: 7,
        ),
        MockSubjectNote(
          id: 'n-os-2',
          title: 'Deadlock Handling Strategies',
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          isFavorite: true,
          preview:
              'Deadlock prevention, avoidance (Banker\'s algorithm), detection, and recovery.',
          pageCount: 5,
        ),
      ],
      assignments: [
        MockSubjectAssignment(
          id: 'a-os-1',
          title: 'Round Robin Simulation',
          dueDate: DateTime.now().add(const Duration(days: 4)),
          isSubmitted: false,
          marks: null,
          totalMarks: 20,
          priority: 'medium',
        ),
      ],
      quizzes: [
        MockSubjectQuiz(
          id: 'q-os-1',
          title: 'Quiz 1 — Processes & Threads',
          date: DateTime.now().subtract(const Duration(days: 10)),
          score: 7,
          totalScore: 10,
          isDone: true,
        ),
        MockSubjectQuiz(
          id: 'q-os-2',
          title: 'Quiz 2 — Memory Management',
          date: DateTime.now().add(const Duration(days: 6)),
          score: null,
          totalScore: 10,
          isDone: false,
        ),
      ],
    ),

    'sub-s5-3': MockSubjectDetail(
      id: 'sub-s5-3',
      semesterId: 'sem-5',
      name: 'Database Systems',
      code: 'CS-341',
      professor: 'Prof. Tariq Aziz',
      color: const Color(0xFFFFA726),
      progress: 0.88,
      creditHours: 3,
      attendancePercent: 95,
      currentGrade: null,
      recentTopics: [
        'SQL Joins & Subqueries',
        'Normalisation (1NF–BCNF)',
        'Transactions & ACID',
        'Indexing & Query Optimisation',
        'ER Modelling',
      ],
      studyGoalHours: 30,
      studiedHours: 26.5,
      notes: [
        MockSubjectNote(
          id: 'n-db-1',
          title: 'SQL Joins & Normalisation',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          isFavorite: true,
          preview:
              'INNER JOIN, LEFT/RIGHT OUTER JOIN. 1NF, 2NF, 3NF, BCNF definitions with examples.',
          pageCount: 8,
        ),
        MockSubjectNote(
          id: 'n-db-2',
          title: 'ER Diagram Notation',
          updatedAt: DateTime.now().subtract(const Duration(days: 4)),
          isFavorite: false,
          preview:
              'Entity, Attribute, Relationship, Cardinality: one-to-one, one-to-many, many-to-many.',
          pageCount: 4,
        ),
      ],
      assignments: [
        MockSubjectAssignment(
          id: 'a-db-1',
          title: 'ER Diagram — Library System',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          isSubmitted: false,
          marks: null,
          totalMarks: 25,
          priority: 'medium',
        ),
      ],
      quizzes: [
        MockSubjectQuiz(
          id: 'q-db-1',
          title: 'Quiz 1 — SQL Basics',
          date: DateTime.now().subtract(const Duration(days: 12)),
          score: 10,
          totalScore: 10,
          isDone: true,
        ),
        MockSubjectQuiz(
          id: 'q-db-2',
          title: 'Quiz 2 — Normalisation',
          date: DateTime.now().subtract(const Duration(days: 5)),
          score: 9,
          totalScore: 10,
          isDone: true,
        ),
      ],
    ),

    'sub-s5-4': MockSubjectDetail(
      id: 'sub-s5-4',
      semesterId: 'sem-5',
      name: 'Software Engineering',
      code: 'CS-311',
      professor: 'Dr. Hina Rao',
      color: const Color(0xFFAB47BC),
      progress: 0.40,
      creditHours: 3,
      attendancePercent: 75,
      currentGrade: null,
      recentTopics: [
        'SDLC Models',
        'Requirements Engineering',
        'SRS Document',
        'Design Patterns',
        'Agile & Scrum',
      ],
      studyGoalHours: 30,
      studiedHours: 12,
      notes: [
        MockSubjectNote(
          id: 'n-se-1',
          title: 'SDLC Models Overview',
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          isFavorite: false,
          preview:
              'Waterfall, Agile, Spiral, and RAD models compared with pros and cons.',
          pageCount: 6,
        ),
      ],
      assignments: [
        MockSubjectAssignment(
          id: 'a-se-1',
          title: 'SRS Document Submission',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          isSubmitted: false,
          marks: null,
          totalMarks: 30,
          priority: 'high',
        ),
      ],
      quizzes: [
        MockSubjectQuiz(
          id: 'q-se-1',
          title: 'Quiz 1 — SDLC',
          date: DateTime.now().subtract(const Duration(days: 8)),
          score: 6,
          totalScore: 10,
          isDone: true,
        ),
      ],
    ),

    'sub-s5-5': MockSubjectDetail(
      id: 'sub-s5-5',
      semesterId: 'sem-5',
      name: 'Computer Networks',
      code: 'CS-351',
      professor: 'Dr. Imran Shah',
      color: const Color(0xFFEF5350),
      progress: 0.63,
      creditHours: 3,
      attendancePercent: 90,
      currentGrade: null,
      recentTopics: [
        'OSI & TCP/IP Model',
        'IP Addressing & Subnetting',
        'Routing Algorithms',
        'TCP vs UDP',
        'Network Security Basics',
      ],
      studyGoalHours: 32,
      studiedHours: 20,
      notes: [
        MockSubjectNote(
          id: 'n-cn-1',
          title: 'TCP/IP Protocol Stack',
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          isFavorite: true,
          preview:
              'Application, Transport, Network, Data Link, Physical layers explained with protocols at each layer.',
          pageCount: 9,
        ),
      ],
      assignments: [
        MockSubjectAssignment(
          id: 'a-cn-1',
          title: 'TCP/IP Protocol Analysis',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          isSubmitted: false,
          marks: null,
          totalMarks: 20,
          priority: 'low',
        ),
      ],
      quizzes: [
        MockSubjectQuiz(
          id: 'q-cn-1',
          title: 'Quiz 1 — OSI Model',
          date: DateTime.now().subtract(const Duration(days: 9)),
          score: 8,
          totalScore: 10,
          isDone: true,
        ),
      ],
    ),
  };

  /// Returns [MockSubjectDetail] for [subjectId], falling back to
  /// a generated placeholder if not explicitly defined.
  static MockSubjectDetail getById(String subjectId) {
    return _details[subjectId] ?? _placeholder(subjectId);
  }

  static MockSubjectDetail _placeholder(String id) {
    return MockSubjectDetail(
      id: id,
      semesterId: '',
      name: 'Subject',
      code: 'CS-000',
      professor: 'TBD',
      color: const Color(0xFF4A90E2),
      progress: 0.5,
      creditHours: 3,
      attendancePercent: 80,
      currentGrade: null,
      notes: const [],
      assignments: const [],
      quizzes: const [],
      recentTopics: const [],
      studyGoalHours: 20,
      studiedHours: 10,
    );
  }
}
