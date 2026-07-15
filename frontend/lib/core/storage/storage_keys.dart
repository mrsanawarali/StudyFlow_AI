/// Hive box name constants used across StudyFlow AI.
/// Centralises all box names to avoid magic strings.
class StorageKeys {
  StorageKeys._();

  // Existing box names (must match main.dart registrations)
  static const String scheduleItems = 'schedule_items';
  static const String semesters = 'semesters';
  static const String subjects = 'subjects';
  static const String chapters = 'chapters';
  static const String notes = 'notes';
  static const String users = 'users';

  // App-level preferences (future: use flutter_secure_storage)
  static const String authToken = 'auth_token';
  static const String userPreferences = 'user_preferences';
  static const String onboardingComplete = 'onboarding_complete';
}
