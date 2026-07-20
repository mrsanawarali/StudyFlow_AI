/// Type-safe route path constants for StudyFlow AI.
/// All GoRoute paths MUST reference these constants — no magic strings.
///
/// Usage:
/// ```dart
/// context.go(RoutePaths.login);
/// context.go('/notes/${noteId}');
/// ```
class RoutePaths {
  RoutePaths._();

  // ── Root ──────────────────────────────────────────────────────────────────
  /// Splash screen (app entry point).
  static const String splash = '/';

  /// Onboarding flow.
  static const String onboarding = '/onboarding';

  // ── Authentication ────────────────────────────────────────────────────────
  /// Login screen.
  static const String login = '/auth/login';

  /// Sign-up screen.
  static const String signup = '/auth/signup';

  /// Forgot password screen.
  static const String forgotPassword = '/auth/forgot-password';

  /// Verify email placeholder screen.
  static const String verifyEmail = '/auth/verify-email';

  /// Account created success screen.
  static const String accountSuccess = '/auth/success';

  // ── Main App (Shell) ──────────────────────────────────────────────────────
  /// Feature dashboard (Phase 2C shell with 5-tab bottom nav).
  static const String home = '/app/home';

  /// Explore / public notes screen.
  static const String explore = '/app/explore';

  /// Schedule screen.
  static const String schedule = '/app/schedule';

  /// Profile screen.
  static const String profile = '/app/profile';

  // ── Semester module ───────────────────────────────────────────────────────
  /// Semester list screen.
  static const String semesterList = '/semesters';

  /// Semester detail — pass `:id` parameter.
  static const String semesterDetail = '/semesters/:id';

  // ── Subject module ────────────────────────────────────────────────────────
  /// Subject list for a given semester — pass `:semId` parameter.
  static const String subjectList = '/semesters/:semId/subjects';

  /// Subject detail — pass `:id` parameter.
  static const String subjectDetail = '/subjects/:id';

  /// Subject notes — pass `:id` parameter.
  static const String subjectNotes = '/subjects/:id/notes';

  /// Subject assignments — pass `:id` parameter.
  static const String subjectAssignments = '/subjects/:id/assignments';

  /// Subject quizzes — pass `:id` parameter.
  static const String subjectQuizzes = '/subjects/:id/quizzes';

  // ── Notes module ─────────────────────────────────────────────────────────
  /// All notes list screen.
  static const String notesList = '/notes';

  /// Note detail — pass `:id` parameter.
  static const String noteDetail = '/notes/:id';

  /// Create new note.
  static const String noteCreate = '/notes/new';

  /// Edit note — pass `:id` parameter.
  static const String noteEdit = '/notes/:id/edit';

  // ── Quizzes module ────────────────────────────────────────────────────────
  /// Global quizzes list.
  static const String quizzesList = '/quizzes';

  /// Quiz detail / attempt — pass `:id` parameter.
  static const String quizDetail = '/quizzes/:id';

  /// Quiz result — pass `:id` parameter.
  static const String quizResult = '/quizzes/:id/result';

  // ── Assignments module ────────────────────────────────────────────────────
  /// Global assignments list.
  static const String assignmentsList = '/assignments';

  /// Assignment detail — pass `:id` parameter.
  static const String assignmentDetail = '/assignments/:id';

  /// Grade calculator screen.
  static const String gradeCalculator = '/grades';

  // ── Profile & Settings module ────────────────────────────────────────────
  /// Settings screen.
  static const String settings = '/settings';

  /// Edit profile screen.
  static const String editProfile = '/profile/edit';

  /// Notifications settings.
  static const String settingsNotifications = '/settings/notifications';

  /// Appearance settings.
  static const String settingsAppearance = '/settings/appearance';

  /// Privacy settings.
  static const String settingsPrivacy = '/settings/privacy';

  /// Security settings.
  static const String settingsSecurity = '/settings/security';

  /// Help & support.
  static const String settingsHelp = '/settings/help';

  /// About screen.
  static const String settingsAbout = '/settings/about';

  // ── AI Assistant module ───────────────────────────────────────────────────
  /// AI Assistant home screen.
  static const String aiAssistant = '/ai';

  /// New AI chat.
  static const String aiChatNew = '/ai/chat/new';

  /// AI chat history.
  static const String aiChatHistory = '/ai/history';

  /// AI chat with session — pass `:id`.
  static const String aiChat = '/ai/chat/:id';

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Builds a semester detail path with the given [id].
  static String semesterDetailPath(String id) => '/semesters/$id';

  /// Builds a subject list path for the given [semesterId].
  static String subjectListPath(String semesterId) =>
      '/semesters/$semesterId/subjects';

  /// Builds a subject detail path with the given [id].
  static String subjectDetailPath(String id) => '/subjects/$id';

  /// Builds a subject notes path with the given [id].
  static String subjectNotesPath(String id) => '/subjects/$id/notes';

  /// Builds a subject assignments path with the given [id].
  static String subjectAssignmentsPath(String id) =>
      '/subjects/$id/assignments';

  /// Builds a subject quizzes path with the given [id].
  static String subjectQuizzesPath(String id) => '/subjects/$id/quizzes';

  /// Builds a note detail path with the given [id].
  static String noteDetailPath(String id) => '/notes/$id';

  /// Builds a note edit path with the given [id].
  static String noteEditPath(String id) => '/notes/$id/edit';

  /// Builds an assignment detail path with the given [id].
  static String assignmentDetailPath(String id) => '/assignments/$id';

  /// Builds a quiz detail path with the given [id].
  static String quizDetailPath(String id) => '/quizzes/$id';

  /// Builds a quiz result path with the given [id].
  static String quizResultPath(String id) => '/quizzes/$id/result';

  /// Builds an AI chat path with the given session [id].
  static String aiChatPath(String id) => '/ai/chat/$id';

  /// Builds a chapter detail path with the given [id].
  static String chapterDetailPath(String id) => '/chapters/$id';
}
