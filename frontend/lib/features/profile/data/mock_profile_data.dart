import 'package:flutter/material.dart';

class MockProfileUser {
  const MockProfileUser({
    required this.name,
    required this.email,
    required this.university,
    required this.department,
    required this.semester,
    required this.studentId,
    required this.joinedDate,
    required this.bio,
    required this.avatarInitials,
    required this.avatarColor,
  });
  final String name;
  final String email;
  final String university;
  final String department;
  final String semester;
  final String studentId;
  final String joinedDate;
  final String bio;
  final String avatarInitials;
  final Color avatarColor;
}

class MockAchievement {
  const MockAchievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.earned,
  });
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool earned;
}

class MockProfileData {
  MockProfileData._();

  static const MockProfileUser user = MockProfileUser(
    name: 'Sanawar Ali',
    email: 'sanawar.ali@comsats.edu.pk',
    university: 'COMSATS University',
    department: 'Computer Science',
    semester: '5th Semester',
    studentId: 'FA20-BCE-007',
    joinedDate: 'September 2022',
    bio: 'CS student passionate about algorithms, AI and building cool apps. '
        'Currently exploring Flutter and Machine Learning.',
    avatarInitials: 'SA',
    avatarColor: Color(0xFF4A90E2),
  );

  static const List<MockAchievement> achievements = [
    MockAchievement(
      icon: Icons.emoji_events_rounded,
      title: 'Dean\'s List',
      description: 'GPA ≥ 3.5 for two consecutive semesters',
      color: Color(0xFFFFD700),
      earned: true,
    ),
    MockAchievement(
      icon: Icons.local_fire_department_rounded,
      title: '7-Day Streak',
      description: 'Studied every day for a week',
      color: Color(0xFFFF7043),
      earned: true,
    ),
    MockAchievement(
      icon: Icons.auto_stories_rounded,
      title: 'Note Master',
      description: 'Created 50+ notes',
      color: Color(0xFF4A90E2),
      earned: true,
    ),
    MockAchievement(
      icon: Icons.quiz_rounded,
      title: 'Quiz Ace',
      description: 'Scored 90%+ on 5 quizzes',
      color: Color(0xFFAB47BC),
      earned: false,
    ),
    MockAchievement(
      icon: Icons.psychology_rounded,
      title: 'AI Explorer',
      description: 'Used AI assistant 10 times',
      color: Color(0xFF50E3C2),
      earned: false,
    ),
    MockAchievement(
      icon: Icons.military_tech_rounded,
      title: 'Perfect Score',
      description: 'Score 100% on any quiz',
      color: Color(0xFF66BB6A),
      earned: false,
    ),
  ];

  // Profile stats
  static const int totalNotes = 63;
  static const int totalQuizzes = 8;
  static const int studyDays = 142;
  static const double cgpa = 3.48;

  // Notification settings (defaults)
  static const Map<String, bool> notificationDefaults = {
    'class_reminders': true,
    'assignment_due': true,
    'quiz_reminders': true,
    'ai_suggestions': false,
    'weekly_summary': true,
    'study_streak': true,
  };

  // Appearance defaults
  static const String defaultTheme = 'light';
  static const String defaultFontSize = 'medium';
}
