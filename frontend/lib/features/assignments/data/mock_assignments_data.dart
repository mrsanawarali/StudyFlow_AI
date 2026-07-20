import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Assignments mock models
// ─────────────────────────────────────────────────────────────────────────────

enum AssignmentStatus { pending, submitted, overdue, graded }

enum AssignmentPriority { high, medium, low }

class MockAssignment {
  const MockAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    required this.subjectColor,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.totalMarks,
    this.obtainedMarks,
    required this.rubric,
    required this.attachments,
    required this.submissionNotes,
  });

  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final Color subjectColor;
  final String description;
  final DateTime dueDate;
  final AssignmentStatus status;
  final AssignmentPriority priority;
  final int totalMarks;
  final int? obtainedMarks;
  final List<String> rubric; // marking criteria
  final List<String> attachments; // file names
  final String submissionNotes;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockAssignmentsData {
  MockAssignmentsData._();

  static final List<MockAssignment> all = [
    MockAssignment(
      id: 'asgn-1',
      title: 'BST Implementation in C++',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      description:
          'Implement a Binary Search Tree in C++ with the following operations:\n\n'
          '- Insert a node\n'
          '- Delete a node\n'
          '- Search for a key\n'
          '- In-order, Pre-order, Post-order traversals\n'
          '- Find minimum and maximum\n\n'
          'Submit a .cpp file with full comments explaining each function. '
          'Include a test main() that demonstrates all operations.',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.high,
      totalMarks: 20,
      obtainedMarks: null,
      rubric: [
        'Correct BST insert logic (4 marks)',
        'Correct delete with 3 cases (4 marks)',
        'All traversals working (4 marks)',
        'Code quality and comments (4 marks)',
        'Test cases in main() (4 marks)',
      ],
      attachments: ['BST_Starter.cpp', 'Assignment_Guidelines.pdf'],
      submissionNotes: '',
    ),

    MockAssignment(
      id: 'asgn-2',
      title: "Dijkstra's Algorithm Report",
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      description:
          "Write a comprehensive report on Dijkstra's shortest path algorithm:\n\n"
          '- Explain the algorithm step by step\n'
          '- Prove time complexity O((V+E) log V)\n'
          '- Compare with Bellman-Ford\n'
          '- Provide a worked example with a weighted graph\n'
          '- Discuss real-world applications (GPS, routing protocols)',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.medium,
      totalMarks: 15,
      obtainedMarks: null,
      rubric: [
        'Algorithm explanation (5 marks)',
        'Complexity proof (3 marks)',
        'Comparison with Bellman-Ford (3 marks)',
        'Worked example (4 marks)',
      ],
      attachments: ['Report_Template.docx'],
      submissionNotes: '',
    ),

    MockAssignment(
      id: 'asgn-3',
      title: 'Sorting Analysis Lab',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      description:
          'Implement and benchmark the following sorting algorithms:\n\n'
          '- Bubble Sort\n'
          '- Insertion Sort\n'
          '- Merge Sort\n'
          '- Quick Sort\n'
          '- Heap Sort\n\n'
          'Measure execution time on arrays of size 100, 1000, 10000. '
          'Plot results and write a 1-page analysis.',
      dueDate: DateTime.now().subtract(const Duration(days: 2)),
      status: AssignmentStatus.graded,
      priority: AssignmentPriority.low,
      totalMarks: 20,
      obtainedMarks: 18,
      rubric: [
        'All 5 algorithms implemented correctly (10 marks)',
        'Benchmarking with correct timing (4 marks)',
        'Analysis report (6 marks)',
      ],
      attachments: ['Sorting_Lab.cpp'],
      submissionNotes:
          'Submitted on time. All algorithms work correctly. Great analysis!',
    ),

    MockAssignment(
      id: 'asgn-4',
      title: 'Round Robin Simulation',
      subject: 'Operating Systems',
      subjectId: 'sub-s5-2',
      subjectColor: const Color(0xFF50E3C2),
      description:
          'Simulate the Round Robin CPU scheduling algorithm:\n\n'
          '- Accept process burst times and arrival times from the user\n'
          '- Accept a time quantum Q\n'
          '- Output the Gantt chart\n'
          '- Calculate: Average waiting time, Average turnaround time\n\n'
          'Implement in any programming language. '
          'Submit code + sample output for at least 3 test cases.',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.medium,
      totalMarks: 20,
      obtainedMarks: null,
      rubric: [
        'Correct Round Robin logic (8 marks)',
        'Gantt chart output (4 marks)',
        'Correct AWT and ATT calculation (4 marks)',
        'Multiple test cases (4 marks)',
      ],
      attachments: ['OS_Assignment2.pdf'],
      submissionNotes: '',
    ),

    MockAssignment(
      id: 'asgn-5',
      title: 'ER Diagram — Library System',
      subject: 'Database Systems',
      subjectId: 'sub-s5-3',
      subjectColor: const Color(0xFFFFA726),
      description:
          'Design a complete ER diagram for a University Library Management System.\n\n'
          'Include the following entities:\n'
          '- Member (student/faculty)\n'
          '- Book\n'
          '- Author\n'
          '- Category\n'
          '- Loan/Borrow record\n'
          '- Fine\n\n'
          'Specify all attributes, primary keys, and cardinality ratios. '
          'Convert the ER diagram to a relational schema.',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.medium,
      totalMarks: 25,
      obtainedMarks: null,
      rubric: [
        'All entities and attributes (8 marks)',
        'Correct cardinality (6 marks)',
        'Relational schema conversion (6 marks)',
        'Diagram clarity (5 marks)',
      ],
      attachments: ['ER_Assignment.pdf'],
      submissionNotes: '',
    ),

    MockAssignment(
      id: 'asgn-6',
      title: 'SRS Document Submission',
      subject: 'Software Engineering',
      subjectId: 'sub-s5-4',
      subjectColor: const Color(0xFFAB47BC),
      description:
          'Write a complete Software Requirements Specification (SRS) document '
          'for a Student Attendance Management System.\n\n'
          'Follow IEEE 830 format:\n'
          '- Introduction (Purpose, Scope, Definitions)\n'
          '- Overall Description\n'
          '- Specific Requirements (Functional & Non-Functional)\n'
          '- Use Case Diagrams\n'
          '- External Interface Requirements\n\n'
          'Minimum 15 pages. Submit as PDF.',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.high,
      totalMarks: 30,
      obtainedMarks: null,
      rubric: [
        'Introduction section (5 marks)',
        'Functional requirements (10 marks)',
        'Non-functional requirements (5 marks)',
        'Use case diagrams (5 marks)',
        'Formatting and completeness (5 marks)',
      ],
      attachments: ['SRS_Template.docx', 'IEEE830_Guide.pdf'],
      submissionNotes: '',
    ),

    MockAssignment(
      id: 'asgn-7',
      title: 'TCP/IP Protocol Analysis',
      subject: 'Computer Networks',
      subjectId: 'sub-s5-5',
      subjectColor: const Color(0xFFEF5350),
      description:
          'Use Wireshark to capture and analyse TCP/IP network traffic.\n\n'
          'Tasks:\n'
          '1. Capture at least 100 packets during a web browsing session\n'
          '2. Identify and explain HTTP, DNS, TCP packets\n'
          '3. Reconstruct the TCP three-way handshake from captured data\n'
          '4. Calculate round-trip time from captured packets\n'
          '5. Write a 2-page analysis report',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      status: AssignmentStatus.pending,
      priority: AssignmentPriority.low,
      totalMarks: 20,
      obtainedMarks: null,
      rubric: [
        'Wireshark capture file (4 marks)',
        'Packet identification (6 marks)',
        'TCP handshake reconstruction (5 marks)',
        'Analysis report (5 marks)',
      ],
      attachments: ['Wireshark_Guide.pdf'],
      submissionNotes: '',
    ),
  ];

  // ── Helpers ──────────────────────────────────────────────────────────────
  static List<MockAssignment> get pending =>
      all.where((a) => a.status == AssignmentStatus.pending).toList();

  static List<MockAssignment> get submitted =>
      all.where((a) => a.status == AssignmentStatus.submitted).toList();

  static List<MockAssignment> get graded =>
      all.where((a) => a.status == AssignmentStatus.graded).toList();

  static List<MockAssignment> get overdue =>
      all.where((a) => a.status == AssignmentStatus.overdue).toList();

  static List<MockAssignment> bySubject(String subjectId) =>
      all.where((a) => a.subjectId == subjectId).toList();

  static MockAssignment? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
