import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/verify_email_screen.dart';
import '../../features/authentication/presentation/screens/account_success_screen.dart';

import '../../features/dashboard/presentation/screens/feature_dashboard_screen.dart';
import '../../features/semesters/presentation/screens/semester_list_screen.dart';
import '../../features/semesters/presentation/screens/semester_detail_screen.dart';
import '../../features/subjects/presentation/screens/subject_list_screen.dart';
import '../../features/subjects/presentation/screens/subject_detail_screen.dart';
import '../../features/subjects/presentation/screens/subject_notes_screen.dart';
import '../../features/subjects/presentation/screens/subject_assignments_screen.dart';
import '../../features/subjects/presentation/screens/subject_quizzes_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/notes/presentation/screens/note_detail_screen.dart';
import '../../features/notes/presentation/screens/note_edit_screen.dart';
import '../../features/assignments/presentation/screens/assignments_list_screen.dart';
import '../../features/assignments/presentation/screens/assignment_detail_screen.dart';
import '../../features/quizzes/presentation/screens/quizzes_list_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_detail_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_result_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_home_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_chat_history_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/profile/presentation/screens/notifications_settings_screen.dart';
import '../../features/profile/presentation/screens/appearance_settings_screen.dart';
import '../../features/profile/presentation/screens/privacy_security_screen.dart';
import '../../features/profile/presentation/screens/help_about_screen.dart';

/// GoRouter configuration for StudyFlow AI.
///
/// Phase 2C: /app/home now renders FeatureDashboardScreen (5-tab shell).
/// Legacy DashboardScreen is preserved but not routed.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      // ── Entry flow ────────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Authentication ────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const FeatureLoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.signup,
        name: 'signup',
        builder: (context, state) => const FeatureSignupScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountSuccess,
        name: 'accountSuccess',
        builder: (context, state) => const AccountSuccessScreen(),
      ),

      // ── Main app (Phase 2C shell) ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) => const FeatureDashboardScreen(),
      ),

      // ── Semester module (Phase 2D) ─────────────────────────────────────
      GoRoute(
        path: RoutePaths.semesterList,
        name: 'semesterList',
        builder: (context, state) => const SemesterListScreen(),
      ),
      GoRoute(
        path: RoutePaths.semesterDetail,
        name: 'semesterDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SemesterDetailScreen(semesterId: id);
        },
      ),

      // ── Subject module (Phase 2E) ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.subjectList,
        name: 'subjectList',
        builder: (context, state) {
          final semId = state.pathParameters['semId'] ?? '';
          return SubjectListScreen(semesterId: semId);
        },
      ),
      GoRoute(
        path: RoutePaths.subjectDetail,
        name: 'subjectDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SubjectDetailScreen(subjectId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.subjectNotes,
        name: 'subjectNotes',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SubjectNotesScreen(subjectId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.subjectAssignments,
        name: 'subjectAssignments',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SubjectAssignmentsScreen(subjectId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.subjectQuizzes,
        name: 'subjectQuizzes',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return SubjectQuizzesScreen(subjectId: id);
        },
      ),
      // ── Notes module (Phase 2F) ────────────────────────────────────────
      GoRoute(
        path: RoutePaths.notesList,
        name: 'notesList',
        builder: (context, state) => const NotesListScreen(),
      ),
      GoRoute(
        path: RoutePaths.noteCreate,
        name: 'noteCreate',
        builder: (context, state) => const NoteEditScreen(),
      ),
      GoRoute(
        path: RoutePaths.noteDetail,
        name: 'noteDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoteDetailScreen(noteId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.noteEdit,
        name: 'noteEdit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoteEditScreen(noteId: id);
        },
      ),
      // ── Quizzes module (Phase 2H) ──────────────────────────────────────
      GoRoute(
        path: RoutePaths.quizzesList,
        name: 'quizzesList',
        builder: (context, state) => const QuizzesListScreen(),
      ),
      GoRoute(
        path: RoutePaths.quizDetail,
        name: 'quizDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return QuizDetailScreen(quizId: id);
        },
      ),
      GoRoute(
        path: RoutePaths.quizResult,
        name: 'quizResult',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          final score = extra['score'] as int? ?? 0;
          final total = extra['total'] as int? ?? 0;
          return QuizResultScreen(
              quizId: id, score: score, total: total);
        },
      ),

      // ── Assignments module (Phase 2G) ──────────────────────────────────
      GoRoute(
        path: RoutePaths.assignmentsList,
        name: 'assignmentsList',
        builder: (context, state) => const AssignmentsListScreen(),
      ),
      GoRoute(
        path: RoutePaths.assignmentDetail,
        name: 'assignmentDetail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AssignmentDetailScreen(assignmentId: id);
        },
      ),
      // ── Profile & Settings module (Phase 2L) ──────────────────────────
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsNotifications,
        name: 'settingsNotifications',
        builder: (context, state) =>
            const NotificationsSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsAppearance,
        name: 'settingsAppearance',
        builder: (context, state) =>
            const AppearanceSettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsPrivacy,
        name: 'settingsPrivacy',
        builder: (context, state) =>
            const PrivacySettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsSecurity,
        name: 'settingsSecurity',
        builder: (context, state) =>
            const SecuritySettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsHelp,
        name: 'settingsHelp',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: RoutePaths.settingsAbout,
        name: 'settingsAbout',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: 'editProfile',
        builder: (context, state) => const AboutScreen(), // placeholder
      ),

      // ── AI Assistant module (Phase 2K) ────────────────────────────────
      GoRoute(
        path: RoutePaths.aiAssistant,
        name: 'aiAssistant',
        builder: (context, state) => const AIHomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.aiChatNew,
        name: 'aiChatNew',
        builder: (context, state) => AIChatScreen(
          extra: state.extra as Map<String, dynamic>?,
        ),
      ),
      GoRoute(
        path: RoutePaths.aiChatHistory,
        name: 'aiChatHistory',
        builder: (context, state) => const AIChatHistoryScreen(),
      ),
      GoRoute(
        path: RoutePaths.aiChat,
        name: 'aiChat',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AIChatScreen(
            sessionId: id,
            extra: state.extra as Map<String, dynamic>?,
          );
        },
      ),
      // Phase 3: Replace with ShellRoute for persistent bottom nav via GoRouter
      // Phase 3: Add auth guard redirect
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
}
