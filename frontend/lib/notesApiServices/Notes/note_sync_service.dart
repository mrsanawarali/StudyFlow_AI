import 'package:connectivity_plus/connectivity_plus.dart';
import 'hive_note_service.dart';
import 'note_local.dart';
import 'note_sync_manager.dart';

class NoteSyncService {
  static final NoteSyncService _instance = NoteSyncService._internal();
  factory NoteSyncService() => _instance;
  NoteSyncService._internal() {
    _initConnectivityListener();
  }

  final NoteSyncManager _syncManager = NoteSyncManager();

  /// Only triggers sync for notes; no chapters, semesters, subjects.
  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _syncManager.syncAll();
      }
    });
  }

  /// Manual sync for notes only
  Future<void> syncNow() => _syncManager.syncAll();

  Future<void> syncSingle(NoteLocal note) => _syncManager.syncSingleNoteImmediately(note);

}






// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'hive_note_service.dart';
// import 'note_sync_manager.dart';
//
// class NoteSyncService {
//   static final NoteSyncService _instance = NoteSyncService._internal();
//   factory NoteSyncService() => _instance;
//   NoteSyncService._internal() {
//     _initConnectivityListener();
//     _tryInitialSync();
//   }
//
//   final NoteSyncManager syncManager = NoteSyncManager();
//   bool _isRetrying = false;
//
//   void _initConnectivityListener() {
//     Connectivity().onConnectivityChanged.listen((status) {
//       if (status != ConnectivityResult.none) {
//         print("📶 Internet back — attempting note sync...");
//         _retryUnsyncedNotes();
//       }
//     });
//   }
//
//   Future<void> _tryInitialSync() async {
//     final status = await Connectivity().checkConnectivity();
//     if (status != ConnectivityResult.none) _retryUnsyncedNotes();
//   }
//
//   void _retryUnsyncedNotes() {
//     if (_isRetrying) return;



