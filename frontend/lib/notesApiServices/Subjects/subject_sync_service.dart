import 'package:connectivity_plus/connectivity_plus.dart';
import 'subject_sync_manager.dart';
import 'hive_subject_service.dart';

class SubjectSyncService {
  final SubjectSyncManager syncManager;

  SubjectSyncService({required this.syncManager}) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        print("📶 Internet back — syncing subjects...");
        try {
          await syncManager.syncAll();
        } catch (e) {
          print("⚠️ Connectivity sync failed: $e");
        }
        HiveSubjectService.printAll();
      }
    });
  }

}
