import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:untitled/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme/app_theme.dart';
import 'package:untitled/notesApiServices/Notes/hive_note_helper.dart';
import 'package:untitled/screens/dashboard/schedule/models/hive_helper.dart';
import 'package:untitled/screens/dashboard/schedule/models/hive_service.dart';
import 'package:untitled/screens/dashboard/schedule/models/network_utils.dart';
import 'package:untitled/screens/dashboard/schedule/models/schedule_item_local.dart';
import 'package:untitled/screens/dashboard/schedule/notification_service.dart';
import 'package:untitled/screens/dashboard/schedule/schedule_notification_manager.dart';
import 'package:untitled/screens/dashboard/user-profile/hive-user-service.dart';
import 'package:untitled/screens/dashboard/user-profile/hive-user-helper.dart';
import 'package:untitled/screens/dashboard/user-profile/user_sync_manager.dart';
import 'package:untitled/screens/dashboard/user-profile/user_sync_service.dart';
import 'notesApiServices/Chapters/chapter_api_service.dart';
import 'notesApiServices/Chapters/chapter_sync_manager.dart';
import 'notesApiServices/Chapters/chapter_sync_service.dart';
import 'notesApiServices/Chapters/hive_chapter_service.dart';
import 'notesApiServices/Notes/hive_note_service.dart';
import 'notesApiServices/Notes/note_sync_service.dart';
import 'notesApiServices/Semesters/hive_semester_service.dart';
import 'notesApiServices/Semesters/semester_api_service.dart';
import 'notesApiServices/Semesters/semester_sync_manager.dart';
import 'notesApiServices/Semesters/semester_sync_service.dart';
import 'notesApiServices/Subjects/hive_subject_helper.dart';
import 'notesApiServices/Subjects/hive_subject_service.dart';
import 'notesApiServices/Subjects/subject_api_service.dart';
import 'notesApiServices/Subjects/subject_sync_manager.dart';
import 'notesApiServices/Subjects/subject_sync_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'notesApiServices/Semesters/hive_semester_helper.dart';
import 'notesApiServices/Chapters/hive_chapter_helper.dart'; // <-- Add this
import 'config/routing/app_router.dart';

import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Set Firebase Auth language globally
  FirebaseAuth.instance.setLanguageCode('en');

  // ------------------------------
  // Initialize Hive
  // ------------------------------
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleItemLocalAdapter());
  await Hive.openBox<ScheduleItemLocal>("schedule_items");

  // Optional: init other Hive boxes
  await HiveHelper.initHive();
  await HiveSemesterHelper.init();
  await HiveSubjectHelper.init();
  await HiveChapterHelper.init();
  await HiveNoteHelper.init();
  await HiveUserHelper.init();

  // ------------------------------
  // Initialize Notifications
  // ------------------------------
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

  await NotificationService.init();
  final now = tz.TZDateTime.now(tz.local);
  print(now); // Should print PKT, e.g., 2025-11-30 22:06:00.000+05:00
  print(tz.local.name); // Should print Asia/Karachi

  // ------------------------------
  // Reschedule all notifications after Hive is ready
  // ------------------------------
  await ScheduleNotificationManager.rescheduleAll();

  // final testTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
  //
  // await NotificationService.scheduleNotification(
  //   id: 999,
  //   title: 'Test Notification',
  //   body: 'This should appear in 10 seconds',
  //   dateTime: testTime,
  // );

  // ------------------------------
  // Run the app
  // ------------------------------
  runApp(ProviderScope(child: ScheduleApp()));

  HiveService.printHiveData();

  final connectivityService = ConnectivityService();
  connectivityService.startMonitoring();

  // ------------------------------
  // Optional: Start syncing in background (no await)
  // ------------------------------
  _startBackgroundSync();
}

Future<void> _startBackgroundSync() async {
  final API_BASE_IP = AppConfig.baseUrl;

  final semesterManager =
  SemesterSyncManager(api: SemesterApiService(baseUrl: "$API_BASE_IP/semesters"));
  await semesterManager.syncAll();
  HiveSemesterService.printAll();

  final subjectManager =
  SubjectSyncManager(api: SubjectApiService(baseUrl: "$API_BASE_IP/subjects"));
  await subjectManager.syncAll();
  HiveSubjectService.printAll();

  final chapterManager =
  ChapterSyncManager(api: ChapterApiService(baseUrl: "$API_BASE_IP/chapters"));
  await chapterManager.syncAll();
  HiveChapterService.printAll();

  NoteSyncService();
  HiveNoteService.printAll();

  final userManager = UserSyncManager();
  await userManager.syncAll();
  HiveUserService.printAll();
}


// void main() async {
//   const String API_BASE_IP = AppConfig.baseUrl; // <- update this when your IP changes
//
//
//   WidgetsFlutterBinding.ensureInitialized(); // <- Add this
//   await HiveHelper.initHive();
//   await HiveSemesterHelper.init();
//   await HiveSubjectHelper.init();
//   await HiveChapterHelper.init();
//   await HiveNoteHelper.init();
//   await HiveUserHelper.init();
//
//   // Initialize notifications
//   await NotificationService.init();
//   HiveService.printHiveData();
//
//   // Reschedule notifications for all non-deleted items
//   await ScheduleNotificationManager.rescheduleAll();
//
//   final connectivityService = ConnectivityService();
//   connectivityService.startMonitoring();
//
//
// //Semester
//   final syncManager = SemesterSyncManager(
//     api: SemesterApiService(baseUrl: "$API_BASE_IP/semesters"),
//   );
// // Start connectivity-aware sync
//   final syncService = SemesterSyncService(syncManager: syncManager);
// // Initial sync
//   await syncManager.syncAll();
//   HiveSemesterService.printAll();
//
//
//
// // Subjects
//   final subjectSyncManager = SubjectSyncManager(
//       api: SubjectApiService(baseUrl: "$API_BASE_IP/subjects"));
//   final subjectSyncService = SubjectSyncService(syncManager: subjectSyncManager);
//   await subjectSyncManager.syncAll();
//   HiveSubjectService.printAll();
//
// // Chapters
//
//   final chapterSyncManager = ChapterSyncManager(
//     api: ChapterApiService(baseUrl: "$API_BASE_IP/chapters"),
//   );
//   final chapterSyncService = ChapterSyncService(syncManager: chapterSyncManager);
//   await chapterSyncManager.syncAll();
//   HiveChapterService.printAll();
//
// // --------------------------------------------------
// // NOTES SYNC
// // --------------------------------------------------
//
//   NoteSyncService();
//   HiveNoteService.printAll();
//
//
//
//   // ---------------------------
//   // User Profile Sync
//   // ---------------------------
//   final userSyncManager = UserSyncManager();
//   final userSyncService = UserSyncService(syncManager: userSyncManager);
//   await userSyncManager.syncAll();
//   HiveUserService.printAll();
//
//
//
// // Initial sync
//   await syncManager.syncAll();
//
//
//   runApp(ScheduleApp());
// }

class ScheduleApp extends StatelessWidget {
  // GoRouter is created once and held at the app level.
  static final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudyFlow AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
