import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quiz mock models
// ─────────────────────────────────────────────────────────────────────────────

enum QuizStatus { upcoming, completed, missed }

enum QuestionType { mcq, trueFalse, shortAnswer }

class MockQuizQuestion {
  const MockQuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String question;
  final QuestionType type;
  final List<String> options; // empty for shortAnswer
  final int correctIndex;     // index in options; -1 for shortAnswer
  final String explanation;
}

class MockQuiz {
  const MockQuiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    required this.subjectColor,
    required this.scheduledDate,
    required this.durationMinutes,
    required this.totalMarks,
    required this.status,
    this.obtainedMarks,
    this.attemptedAt,
    required this.questions,
    required this.topic,
  });

  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final Color subjectColor;
  final DateTime scheduledDate;
  final int durationMinutes;
  final int totalMarks;
  final QuizStatus status;
  final int? obtainedMarks;
  final DateTime? attemptedAt;
  final List<MockQuizQuestion> questions;
  final String topic;

  double get percentage =>
      obtainedMarks != null ? (obtainedMarks! / totalMarks) * 100 : 0;

  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 85) return 'A';
    if (p >= 80) return 'A-';
    if (p >= 75) return 'B+';
    if (p >= 70) return 'B';
    if (p >= 65) return 'B-';
    if (p >= 60) return 'C+';
    if (p >= 55) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockQuizzesData {
  MockQuizzesData._();

  static final List<MockQuiz> all = [
    // ── Data Structures quizzes ────────────────────────────────────────────
    MockQuiz(
      id: 'quiz-ds-1',
      title: 'Quiz 1 — Arrays & Linked Lists',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      scheduledDate: DateTime.now().subtract(const Duration(days: 14)),
      durationMinutes: 20,
      totalMarks: 10,
      status: QuizStatus.completed,
      obtainedMarks: 9,
      attemptedAt: DateTime.now().subtract(const Duration(days: 14)),
      topic: 'Arrays, Linked Lists, Stacks, Queues',
      questions: [
        const MockQuizQuestion(
          id: 'q-ds-1-1',
          question:
              'What is the time complexity of accessing an element in an array by index?',
          type: QuestionType.mcq,
          options: ['O(n)', 'O(log n)', 'O(1)', 'O(n²)'],
          correctIndex: 2,
          explanation:
              'Arrays provide O(1) random access because each element is stored at a fixed offset from the base address.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-1-2',
          question:
              'In a singly linked list, inserting a node at the beginning takes O(1) time.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation:
              'Inserting at the head only requires updating one pointer, so it is O(1).',
        ),
        const MockQuizQuestion(
          id: 'q-ds-1-3',
          question:
              'Which data structure follows the LIFO (Last In, First Out) principle?',
          type: QuestionType.mcq,
          options: ['Queue', 'Stack', 'Linked List', 'Tree'],
          correctIndex: 1,
          explanation:
              'A Stack follows LIFO — the last element pushed is the first one popped.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-1-4',
          question:
              'What is the worst-case time complexity of searching in an unsorted array?',
          type: QuestionType.mcq,
          options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
          correctIndex: 2,
          explanation:
              'In the worst case, we must check every element, giving O(n) linear search.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-1-5',
          question:
              'A Queue can be efficiently implemented using two stacks.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation:
              'Yes — push all elements onto stack 1; pop from stack 2 (refill from stack 1 when empty) to simulate FIFO behaviour.',
        ),
      ],
    ),

    MockQuiz(
      id: 'quiz-ds-2',
      title: 'Quiz 2 — Trees',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      scheduledDate: DateTime.now().subtract(const Duration(days: 7)),
      durationMinutes: 20,
      totalMarks: 10,
      status: QuizStatus.completed,
      obtainedMarks: 8,
      attemptedAt: DateTime.now().subtract(const Duration(days: 7)),
      topic: 'Binary Trees, BST, AVL Trees',
      questions: [
        const MockQuizQuestion(
          id: 'q-ds-2-1',
          question:
              'In a Binary Search Tree (BST), where are smaller values stored?',
          type: QuestionType.mcq,
          options: [
            'In the right subtree',
            'In the left subtree',
            'At the root',
            'Randomly'
          ],
          correctIndex: 1,
          explanation:
              'BST property: all values in the left subtree are smaller than the root.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-2-2',
          question:
              'The balance factor of a node in an AVL tree can be +2.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 1,
          explanation:
              'In a valid AVL tree, the balance factor must be -1, 0, or +1. A balance factor of +2 triggers a rotation.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-2-3',
          question:
              'What traversal visits nodes in Left → Root → Right order?',
          type: QuestionType.mcq,
          options: ['Pre-order', 'Post-order', 'In-order', 'Level-order'],
          correctIndex: 2,
          explanation:
              'In-order traversal (Left → Root → Right) visits a BST in sorted ascending order.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-2-4',
          question:
              'What is the minimum number of nodes in an AVL tree of height 3?',
          type: QuestionType.mcq,
          options: ['4', '5', '6', '7'],
          correctIndex: 3,
          explanation:
              'Minimum nodes in AVL tree: N(h) = N(h-1) + N(h-2) + 1. N(0)=1, N(1)=2, N(2)=4, N(3)=7.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-2-5',
          question: 'A complete binary tree of height h has exactly 2^h leaf nodes.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation:
              'A complete binary tree of height h has 2^h leaves in the last level.',
        ),
      ],
    ),

    MockQuiz(
      id: 'quiz-ds-3',
      title: 'Quiz 3 — Graphs',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      scheduledDate: DateTime.now().add(const Duration(days: 3)),
      durationMinutes: 20,
      totalMarks: 10,
      status: QuizStatus.upcoming,
      topic: 'Graph Representations, BFS, DFS, Shortest Paths',
      questions: [
        const MockQuizQuestion(
          id: 'q-ds-3-1',
          question: 'Which algorithm is used to find the shortest path in an unweighted graph?',
          type: QuestionType.mcq,
          options: ["Dijkstra's", 'BFS', 'DFS', 'Bellman-Ford'],
          correctIndex: 1,
          explanation:
              'BFS explores nodes level by level, guaranteeing the shortest path in an unweighted graph.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-3-2',
          question: 'DFS uses a queue as its primary data structure.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 1,
          explanation: 'DFS uses a stack (or recursion call stack). BFS uses a queue.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-3-3',
          question: 'What is the space complexity of an adjacency matrix for a graph with V vertices?',
          type: QuestionType.mcq,
          options: ['O(V)', 'O(E)', 'O(V²)', 'O(V + E)'],
          correctIndex: 2,
          explanation: 'An adjacency matrix requires a V×V boolean matrix, so O(V²) space.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-3-4',
          question: 'A directed acyclic graph (DAG) can be topologically sorted.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation: 'Topological sort is only defined for DAGs — graphs with no cycles.',
        ),
        const MockQuizQuestion(
          id: 'q-ds-3-5',
          question: "Dijkstra's algorithm works correctly with negative edge weights.",
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 1,
          explanation:
              "Dijkstra's fails with negative weights. Use Bellman-Ford instead for negative edges.",
        ),
      ],
    ),

    // ── Operating Systems quizzes ──────────────────────────────────────────
    MockQuiz(
      id: 'quiz-os-1',
      title: 'Quiz 1 — Processes & Threads',
      subject: 'Operating Systems',
      subjectId: 'sub-s5-2',
      subjectColor: const Color(0xFF50E3C2),
      scheduledDate: DateTime.now().subtract(const Duration(days: 10)),
      durationMinutes: 15,
      totalMarks: 10,
      status: QuizStatus.completed,
      obtainedMarks: 7,
      attemptedAt: DateTime.now().subtract(const Duration(days: 10)),
      topic: 'Processes, Threads, Context Switching',
      questions: [
        const MockQuizQuestion(
          id: 'q-os-1-1',
          question: 'Which state does a process enter when it is waiting for an I/O operation?',
          type: QuestionType.mcq,
          options: ['Running', 'Ready', 'Blocked/Waiting', 'Terminated'],
          correctIndex: 2,
          explanation:
              'A process moves to the Blocked/Waiting state when it is waiting for I/O or another event.',
        ),
        const MockQuizQuestion(
          id: 'q-os-1-2',
          question: 'Threads within the same process share the same memory space.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation:
              'Threads share the heap, global variables, and code segment of their parent process.',
        ),
        const MockQuizQuestion(
          id: 'q-os-1-3',
          question: 'Which scheduling algorithm can cause the convoy effect?',
          type: QuestionType.mcq,
          options: ['Round Robin', 'FCFS', 'SJF', 'Priority Scheduling'],
          correctIndex: 1,
          explanation:
              'FCFS can cause the convoy effect where short processes wait behind a long-running process.',
        ),
      ],
    ),

    MockQuiz(
      id: 'quiz-os-2',
      title: 'Quiz 2 — Memory Management',
      subject: 'Operating Systems',
      subjectId: 'sub-s5-2',
      subjectColor: const Color(0xFF50E3C2),
      scheduledDate: DateTime.now().add(const Duration(days: 6)),
      durationMinutes: 15,
      totalMarks: 10,
      status: QuizStatus.upcoming,
      topic: 'Paging, Segmentation, Virtual Memory',
      questions: [
        const MockQuizQuestion(
          id: 'q-os-2-1',
          question: 'What is the purpose of a page table in virtual memory?',
          type: QuestionType.mcq,
          options: [
            'Store actual data pages',
            'Map virtual addresses to physical addresses',
            'Schedule processes',
            'Manage disk I/O'
          ],
          correctIndex: 1,
          explanation:
              'A page table maps virtual page numbers to physical frame numbers in RAM.',
        ),
        const MockQuizQuestion(
          id: 'q-os-2-2',
          question: 'Internal fragmentation occurs in paging.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 0,
          explanation:
              'Yes — the last page allocated may not be fully used, causing internal fragmentation.',
        ),
        const MockQuizQuestion(
          id: 'q-os-2-3',
          question: 'Which page replacement algorithm always gives the optimal result?',
          type: QuestionType.mcq,
          options: ['LRU', 'FIFO', 'Optimal (OPT)', 'Clock'],
          correctIndex: 2,
          explanation:
              'The Optimal algorithm replaces the page that will not be used for the longest time in future.',
        ),
      ],
    ),

    // ── Database Systems quizzes ───────────────────────────────────────────
    MockQuiz(
      id: 'quiz-db-1',
      title: 'Quiz 1 — SQL Basics',
      subject: 'Database Systems',
      subjectId: 'sub-s5-3',
      subjectColor: const Color(0xFFFFA726),
      scheduledDate: DateTime.now().subtract(const Duration(days: 12)),
      durationMinutes: 20,
      totalMarks: 10,
      status: QuizStatus.completed,
      obtainedMarks: 10,
      attemptedAt: DateTime.now().subtract(const Duration(days: 12)),
      topic: 'SQL SELECT, WHERE, JOIN, GROUP BY',
      questions: [
        const MockQuizQuestion(
          id: 'q-db-1-1',
          question: 'Which SQL clause is used to filter rows?',
          type: QuestionType.mcq,
          options: ['HAVING', 'GROUP BY', 'WHERE', 'ORDER BY'],
          correctIndex: 2,
          explanation:
              'WHERE filters individual rows before grouping. HAVING filters after GROUP BY.',
        ),
        const MockQuizQuestion(
          id: 'q-db-1-2',
          question: 'An INNER JOIN returns all rows from both tables including non-matching rows.',
          type: QuestionType.trueFalse,
          options: ['True', 'False'],
          correctIndex: 1,
          explanation:
              'INNER JOIN only returns rows where there is a match in both tables. LEFT/RIGHT JOIN return non-matching rows.',
        ),
        const MockQuizQuestion(
          id: 'q-db-1-3',
          question: 'Which aggregate function counts the number of non-NULL values?',
          type: QuestionType.mcq,
          options: ['SUM()', 'AVG()', 'COUNT()', 'MAX()'],
          correctIndex: 2,
          explanation:
              'COUNT(column) counts non-NULL values. COUNT(*) counts all rows including NULLs.',
        ),
      ],
    ),
  ];

  // ── Helpers ──────────────────────────────────────────────────────────────
  static List<MockQuiz> get completed =>
      all.where((q) => q.status == QuizStatus.completed).toList();

  static List<MockQuiz> get upcoming =>
      all.where((q) => q.status == QuizStatus.upcoming).toList();

  static List<MockQuiz> bySubject(String subjectId) =>
      all.where((q) => q.subjectId == subjectId).toList();

  static MockQuiz? getById(String id) {
    try {
      return all.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}
