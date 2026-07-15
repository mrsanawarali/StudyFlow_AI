import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notes mock models
// ─────────────────────────────────────────────────────────────────────────────

enum NoteViewMode { grid, list }

class MockNote {
  const MockNote({
    required this.id,
    required this.title,
    required this.subject,
    required this.subjectId,
    required this.subjectColor,
    required this.content,
    required this.tags,
    required this.isFavorite,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    required this.readingTimeMin,
    required this.wordCount,
    required this.attachments,
  });

  final String id;
  final String title;
  final String subject;
  final String subjectId;
  final Color subjectColor;
  final String content; // plain text body (rich text placeholder)
  final List<String> tags;
  final bool isFavorite;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int readingTimeMin;
  final int wordCount;
  final List<MockAttachment> attachments;
}

class MockAttachment {
  const MockAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeMb,
  });
  final String id;
  final String name;
  final String type; // 'pdf' | 'image' | 'link'
  final double sizeMb;
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockNotesData {
  MockNotesData._();

  static final List<MockNote> allNotes = [
    MockNote(
      id: 'note-1',
      title: 'AVL Trees & Rotations',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      tags: ['trees', 'algorithms', 'balancing'],
      isFavorite: true,
      isPinned: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      readingTimeMin: 8,
      wordCount: 1240,
      attachments: const [
        MockAttachment(
            id: 'a1', name: 'AVL_Slides.pdf', type: 'pdf', sizeMb: 1.2),
        MockAttachment(
            id: 'a2',
            name: 'Rotation_Diagram.png',
            type: 'image',
            sizeMb: 0.3),
      ],
      content: '''
An AVL tree is a self-balancing Binary Search Tree (BST) where the difference between heights of left and right subtrees cannot be more than one for all nodes.

## Key Properties
- Height difference (balance factor) of any node is -1, 0, or +1
- Named after inventors Adelson-Velsky and Landis (1962)
- Guarantees O(log n) for search, insert, and delete

## Types of Rotations

### 1. Right Rotation (LL Case)
Used when a node is inserted in the left subtree of the left child.
```
    z                y
   /                / \\
  y       →        x   z
 /
x
```

### 2. Left Rotation (RR Case)
Used when a node is inserted in the right subtree of the right child.

### 3. Left-Right Rotation (LR Case)
First apply left rotation on left child, then right rotation on root.

### 4. Right-Left Rotation (RL Case)
First apply right rotation on right child, then left rotation on root.

## Balance Factor
Balance Factor = Height(Left Subtree) - Height(Right Subtree)

A node is considered:
- **Left-heavy** if BF = +2
- **Right-heavy** if BF = -2
- **Balanced** if BF ∈ {-1, 0, +1}

## Time Complexity
| Operation | Average | Worst |
|-----------|---------|-------|
| Search    | O(log n)| O(log n)|
| Insert    | O(log n)| O(log n)|
| Delete    | O(log n)| O(log n)|
''',
    ),

    MockNote(
      id: 'note-2',
      title: 'Process Scheduling Algorithms',
      subject: 'Operating Systems',
      subjectId: 'sub-s5-2',
      subjectColor: const Color(0xFF50E3C2),
      tags: ['scheduling', 'cpu', 'processes'],
      isFavorite: false,
      isPinned: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      readingTimeMin: 6,
      wordCount: 980,
      attachments: const [
        MockAttachment(
            id: 'a3',
            name: 'Scheduling_Notes.pdf',
            type: 'pdf',
            sizeMb: 0.8),
      ],
      content: '''
Process scheduling is the activity of the process manager that handles the removal of the running process from the CPU and the selection of another process on the basis of a particular strategy.

## FCFS (First Come First Serve)
- Non-preemptive
- Processes are executed in the order they arrive
- Simple but may cause convoy effect

## SJF (Shortest Job First)
- Can be preemptive (SRTF) or non-preemptive
- Optimal average waiting time for a given set of processes
- Requires knowing burst time in advance

## Round Robin
- Preemptive with time quantum
- Each process gets a small unit of CPU time
- Good for time-sharing systems

## Priority Scheduling
- Each process has a priority value
- CPU allocated to highest priority process
- Can suffer from starvation (solved by aging)
''',
    ),

    MockNote(
      id: 'note-3',
      title: 'SQL Joins & Normalisation',
      subject: 'Database Systems',
      subjectId: 'sub-s5-3',
      subjectColor: const Color(0xFFFFA726),
      tags: ['sql', 'joins', 'normalisation', 'database'],
      isFavorite: true,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      readingTimeMin: 10,
      wordCount: 1560,
      attachments: const [],
      content: '''
## SQL Joins

### INNER JOIN
Returns rows that have matching values in both tables.
```sql
SELECT * FROM orders o
INNER JOIN customers c ON o.customer_id = c.id;
```

### LEFT OUTER JOIN
Returns all rows from left table, matched rows from right.

### RIGHT OUTER JOIN
Returns all rows from right table, matched rows from left.

### FULL OUTER JOIN
Returns all rows when there is a match in either left or right table.

## Database Normalisation

### 1NF (First Normal Form)
- Atomic values in each column
- No repeating groups
- Each row is unique

### 2NF (Second Normal Form)
- Must be in 1NF
- No partial dependencies (all non-key attributes fully dependent on primary key)

### 3NF (Third Normal Form)
- Must be in 2NF
- No transitive dependencies

### BCNF (Boyce-Codd Normal Form)
- Stricter version of 3NF
- For every functional dependency X → Y, X must be a superkey
''',
    ),

    MockNote(
      id: 'note-4',
      title: 'SDLC Models Overview',
      subject: 'Software Engineering',
      subjectId: 'sub-s5-4',
      subjectColor: const Color(0xFFAB47BC),
      tags: ['sdlc', 'agile', 'waterfall', 'software'],
      isFavorite: false,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      readingTimeMin: 5,
      wordCount: 820,
      attachments: const [
        MockAttachment(
            id: 'a4',
            name: 'SDLC_Comparison.pdf',
            type: 'pdf',
            sizeMb: 1.5),
      ],
      content: '''
## Software Development Life Cycle (SDLC)

SDLC is a process for planning, creating, testing, and deploying an information system.

### Waterfall Model
- Sequential linear process
- Each phase must be completed before next begins
- Easy to manage but inflexible to changes

### Agile Model
- Iterative and incremental approach
- Delivers working software frequently
- Embraces changing requirements
- Frameworks: Scrum, Kanban, XP

### Spiral Model
- Combines iterative development with risk analysis
- Each cycle involves: Planning → Risk Analysis → Engineering → Evaluation
- Good for large, complex projects

### RAD (Rapid Application Development)
- Focuses on quick development
- Uses prototyping and iterative delivery
- Less emphasis on planning
''',
    ),

    MockNote(
      id: 'note-5',
      title: 'TCP/IP Protocol Stack',
      subject: 'Computer Networks',
      subjectId: 'sub-s5-5',
      subjectColor: const Color(0xFFEF5350),
      tags: ['tcp', 'ip', 'networking', 'protocols'],
      isFavorite: true,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      readingTimeMin: 7,
      wordCount: 1100,
      attachments: const [
        MockAttachment(
            id: 'a5',
            name: 'Network_Diagram.png',
            type: 'image',
            sizeMb: 0.6),
        MockAttachment(
            id: 'a6',
            name: 'RFC_791_Reference.pdf',
            type: 'pdf',
            sizeMb: 2.1),
      ],
      content: '''
## TCP/IP Model Layers

### Application Layer
Provides network services directly to end users.
Protocols: HTTP, HTTPS, FTP, SMTP, DNS, DHCP

### Transport Layer
Provides host-to-host communication services.
- **TCP** (Transmission Control Protocol): Reliable, connection-oriented
- **UDP** (User Datagram Protocol): Fast, connectionless

### Internet Layer
Responsible for logical addressing and routing.
- **IP** (Internet Protocol): IPv4 and IPv6
- **ICMP**: Error reporting
- **ARP**: Address resolution

### Network Access Layer
Combines OSI's Data Link and Physical layers.
- Ethernet, Wi-Fi (802.11), PPP

## TCP Three-Way Handshake
1. **SYN** – Client sends synchronise segment
2. **SYN-ACK** – Server responds with synchronise-acknowledge
3. **ACK** – Client acknowledges

## IP Addressing
- IPv4: 32-bit address (e.g., 192.168.1.1)
- IPv6: 128-bit address
- Subnetting: divides a network into smaller networks
''',
    ),

    MockNote(
      id: 'note-6',
      title: 'Hashing & Collision Resolution',
      subject: 'Data Structures',
      subjectId: 'sub-s5-1',
      subjectColor: const Color(0xFF4A90E2),
      tags: ['hashing', 'hash-table', 'collision'],
      isFavorite: true,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      readingTimeMin: 6,
      wordCount: 950,
      attachments: const [],
      content: '''
## Hash Tables

A hash table is a data structure that implements an associative array abstract data type, a structure that can map keys to values.

### Hash Function
Maps a key to an index in the hash table.
- Division method: h(k) = k mod m
- Multiplication method: h(k) = floor(m * (k * A mod 1))
- Universal hashing: randomly chosen from a family of functions

### Collision Resolution

#### Open Addressing
All elements stored in the hash table itself.
- **Linear Probing**: h(k, i) = (h(k) + i) mod m
- **Quadratic Probing**: h(k, i) = (h(k) + c1·i + c2·i²) mod m
- **Double Hashing**: uses a second hash function

#### Separate Chaining
Each slot holds a linked list of elements that hash to that slot.
- Simple to implement
- Never fills up
- Extra memory for pointers
''',
    ),

    MockNote(
      id: 'note-7',
      title: 'Deadlock Handling Strategies',
      subject: 'Operating Systems',
      subjectId: 'sub-s5-2',
      subjectColor: const Color(0xFF50E3C2),
      tags: ['deadlock', 'banker', 'prevention'],
      isFavorite: false,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      readingTimeMin: 7,
      wordCount: 1080,
      attachments: const [
        MockAttachment(
            id: 'a7',
            name: 'Banker_Algorithm.pdf',
            type: 'pdf',
            sizeMb: 0.9),
      ],
      content: '''
## Deadlock

A deadlock is a situation where a set of processes are blocked because each process is holding a resource and waiting for another resource acquired by some other process.

### Four Necessary Conditions (Coffman Conditions)
1. **Mutual Exclusion**: Only one process can use a resource at a time
2. **Hold and Wait**: Process holds resources and waits for more
3. **No Preemption**: Resources cannot be forcibly taken
4. **Circular Wait**: Chain of processes each waiting for resource held by next

### Deadlock Prevention
Eliminate one of the four Coffman conditions.

### Deadlock Avoidance
Use algorithms like **Banker's Algorithm** to ensure safe states.
- Safe state: there exists a sequence in which all processes can finish
- Unsafe state: may lead to deadlock

### Deadlock Detection
Allow deadlocks to occur, detect them using resource allocation graph.

### Deadlock Recovery
- Process termination (abort one or all deadlocked processes)
- Resource preemption (preempt resources from processes)
''',
    ),

    MockNote(
      id: 'note-8',
      title: 'ER Diagram Notation',
      subject: 'Database Systems',
      subjectId: 'sub-s5-3',
      subjectColor: const Color(0xFFFFA726),
      tags: ['er-diagram', 'database-design', 'entities'],
      isFavorite: false,
      isPinned: false,
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      readingTimeMin: 4,
      wordCount: 620,
      attachments: const [
        MockAttachment(
            id: 'a8',
            name: 'Library_ER.png',
            type: 'image',
            sizeMb: 0.4),
      ],
      content: '''
## Entity-Relationship (ER) Diagram

### Components

#### Entity
A real-world object or concept (e.g., Student, Course).
- **Strong Entity**: Has its own primary key
- **Weak Entity**: Depends on another entity, shown with double rectangle

#### Attribute
Property of an entity.
- Simple: Atomic (e.g., Age)
- Composite: Can be divided (e.g., Name = FirstName + LastName)
- Derived: Calculated (e.g., Age from DOB)
- Multivalued: Can have multiple values (e.g., Phone numbers)

#### Relationship
Association between entities.
- One-to-One (1:1)
- One-to-Many (1:N)
- Many-to-Many (M:N)

### Cardinality Notation
- Chen notation uses 1 and N
- Crow's foot notation uses graphical symbols
''',
    ),
  ];

  // Getters for filtered views
  static List<MockNote> get pinnedNotes =>
      allNotes.where((n) => n.isPinned).toList();

  static List<MockNote> get favoriteNotes =>
      allNotes.where((n) => n.isFavorite).toList();

  static List<MockNote> get recentNotes {
    final sorted = List<MockNote>.from(allNotes)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted.take(5).toList();
  }

  static List<String> get allSubjects =>
      allNotes.map((n) => n.subject).toSet().toList()..sort();

  static List<String> get allTags =>
      allNotes.expand((n) => n.tags).toSet().toList()..sort();

  static MockNote? getById(String id) {
    try {
      return allNotes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<MockNote> filterBySubject(String subject) =>
      allNotes.where((n) => n.subject == subject).toList();

  static List<MockNote> search(String query) {
    final q = query.toLowerCase();
    return allNotes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.subject.toLowerCase().contains(q) ||
            n.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }
}
