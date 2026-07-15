import 'package:connectivity_plus/connectivity_plus.dart';
import 'hive_semester_service.dart';
import 'semester_sync_manager.dart';

class SemesterSyncService {
  final SemesterSyncManager syncManager;

  SemesterSyncService({required this.syncManager}) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        print("📶 Internet is back — syncing semesters...");

        try {
          // Trigger sync safely
          await syncManager.syncAll();
        } catch (e) {
          print("⚠️ Connectivity sync failed: $e");
        }

        // Print all semesters after sync
        HiveSemesterService.printAll();
      } else {
        print("⚠️ No internet — offline mode");
      }
    });
  }

}
