import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI mock models
// ─────────────────────────────────────────────────────────────────────────────

enum MessageRole { user, assistant }

class MockChatMessage {
  const MockChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isTyping = false,
  });
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isTyping;
}

class MockChatSession {
  const MockChatSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.messageCount,
    required this.actionType,
    required this.color,
  });
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int messageCount;
  final String actionType;
  final Color color;
}

class MockAIAction {
  const MockAIAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.prompt,
  });
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String prompt; // pre-filled prompt shown in chat
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mock data
// ─────────────────────────────────────────────────────────────────────────────

class MockAIData {
  MockAIData._();

  static const List<MockAIAction> actions = [
    MockAIAction(
      id: 'ask',
      title: 'Ask AI',
      subtitle: 'Ask anything about your studies',
      icon: Icons.chat_outlined,
      color: Color(0xFF50E3C2),
      prompt: '',
    ),
    MockAIAction(
      id: 'summarize',
      title: 'Summarize Notes',
      subtitle: 'Get a concise summary of your notes',
      icon: Icons.summarize_outlined,
      color: Color(0xFF4A90E2),
      prompt: 'Summarize the following notes for me:\n\n',
    ),
    MockAIAction(
      id: 'explain',
      title: 'Explain Topic',
      subtitle: 'Get a simplified explanation',
      icon: Icons.lightbulb_outline_rounded,
      color: Color(0xFFFFA726),
      prompt: 'Explain this topic in simple terms:\n\n',
    ),
    MockAIAction(
      id: 'quiz',
      title: 'Generate Quiz',
      subtitle: 'Auto-create a practice quiz',
      icon: Icons.quiz_outlined,
      color: Color(0xFFAB47BC),
      prompt: 'Generate a 5-question MCQ quiz on the topic:\n\n',
    ),
    MockAIAction(
      id: 'flashcards',
      title: 'Flashcards',
      subtitle: 'Create spaced-repetition cards',
      icon: Icons.style_outlined,
      color: Color(0xFFEF5350),
      prompt: 'Create 10 flashcards for this topic:\n\n',
    ),
    MockAIAction(
      id: 'planner',
      title: 'Study Planner',
      subtitle: 'Get a personalised study schedule',
      icon: Icons.calendar_today_outlined,
      color: Color(0xFF66BB6A),
      prompt: 'Create a study schedule for my upcoming exam on:\n\n',
    ),
  ];

  static final List<MockChatSession> chatHistory = [
    MockChatSession(
      id: 'chat-1',
      title: 'AVL Tree Rotations Explained',
      lastMessage: 'An AVL tree balances itself by performing rotations...',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      messageCount: 6,
      actionType: 'explain',
      color: const Color(0xFFFFA726),
    ),
    MockChatSession(
      id: 'chat-2',
      title: 'Data Structures Quiz',
      lastMessage: 'Q1: What is the time complexity of BST search?',
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
      messageCount: 12,
      actionType: 'quiz',
      color: const Color(0xFFAB47BC),
    ),
    MockChatSession(
      id: 'chat-3',
      title: 'OS Chapter 3 Summary',
      lastMessage: 'Here is a concise summary of Process Scheduling...',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      messageCount: 4,
      actionType: 'summarize',
      color: const Color(0xFF4A90E2),
    ),
    MockChatSession(
      id: 'chat-4',
      title: 'SQL Joins Flashcards',
      lastMessage: 'Front: What does INNER JOIN return? Back: Rows...',
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      messageCount: 8,
      actionType: 'flashcards',
      color: const Color(0xFFEF5350),
    ),
    MockChatSession(
      id: 'chat-5',
      title: 'Exam Study Plan — Finals',
      lastMessage: 'Day 1 (Monday): Data Structures — 3 hours...',
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      messageCount: 5,
      actionType: 'planner',
      color: const Color(0xFF66BB6A),
    ),
  ];

  // Pre-filled mock conversation for chat-1
  static final List<MockChatMessage> sampleConversation = [
    MockChatMessage(
      id: 'm1',
      role: MessageRole.user,
      content: 'Explain AVL tree rotations in simple terms.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    MockChatMessage(
      id: 'm2',
      role: MessageRole.assistant,
      content:
          'An **AVL tree** is a self-balancing Binary Search Tree. '
          'When you insert or delete a node, the tree may become unbalanced. '
          'It fixes this using four types of **rotations**:\n\n'
          '**1. Right Rotation (LL Case)**\nWhen a node is inserted into the left subtree '
          'of the left child. The unbalanced node is rotated to the right.\n\n'
          '**2. Left Rotation (RR Case)**\nWhen a node is inserted into the right subtree '
          'of the right child. The unbalanced node is rotated to the left.\n\n'
          '**3. Left-Right Rotation (LR Case)**\nFirst apply left rotation on the left child, '
          'then right rotation on the root.\n\n'
          '**4. Right-Left Rotation (RL Case)**\nFirst apply right rotation on the right child, '
          'then left rotation on the root.\n\n'
          'Think of rotations as *restructuring* the tree to restore the balance factor to {-1, 0, +1}.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 24)),
    ),
    MockChatMessage(
      id: 'm3',
      role: MessageRole.user,
      content: 'Can you give me an example of the LL case?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    MockChatMessage(
      id: 'm4',
      role: MessageRole.assistant,
      content:
          'Sure! Here is the **LL Case** step by step:\n\n'
          '**Before insertion:** Tree is balanced.\n'
          '```\n    30\n   /\n  20\n```\n\n'
          '**After inserting 10:**\n'
          '```\n    30  ← BF = +2 (unbalanced)\n   /\n  20\n /\n10\n```\n\n'
          '**After Right Rotation on 30:**\n'
          '```\n  20\n /  \\\n10   30\n```\n\n'
          'The tree is now balanced. Node 20 becomes the new root, '
          '10 is its left child, and 30 is its right child. ✅',
      timestamp: DateTime.now().subtract(const Duration(minutes: 19)),
    ),
    MockChatMessage(
      id: 'm5',
      role: MessageRole.user,
      content: 'Perfect! What is the time complexity of AVL operations?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    MockChatMessage(
      id: 'm6',
      role: MessageRole.assistant,
      content:
          'All major operations on an AVL tree run in **O(log n)** time:\n\n'
          '| Operation | Time Complexity |\n'
          '|---|---|\n'
          '| Search | O(log n) |\n'
          '| Insert | O(log n) |\n'
          '| Delete | O(log n) |\n'
          '| Rotation | O(1) |\n\n'
          'This is guaranteed because the AVL property ensures the tree height '
          'is always O(log n), unlike a regular BST which can degrade to O(n) '
          'in the worst case (e.g., sorted input).',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    ),
  ];

  static List<MockChatMessage> getConversation(String sessionId) {
    if (sessionId == 'chat-1') return sampleConversation;
    return [
      MockChatMessage(
        id: 'mock-1',
        role: MessageRole.user,
        content: 'Hello, I need help with my studies.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      MockChatMessage(
        id: 'mock-2',
        role: MessageRole.assistant,
        content:
            'Hi! I\'m StudyFlow AI. I\'m here to help you study smarter. '
            'What subject or topic would you like to explore today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
    ];
  }
}
