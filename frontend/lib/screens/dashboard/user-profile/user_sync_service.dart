import 'package:connectivity_plus/connectivity_plus.dart';
import 'user_sync_manager.dart';

class UserSyncService {
  final UserSyncManager syncManager;

  UserSyncService({required this.syncManager}) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        // Internet is back → sync any unsynced users
        try {
          await syncManager.syncAll();
        } catch (e) {
          print("⚠️ User connectivity sync failed: $e");
        }
      }
    });
  }

  /// Optional: manually trigger a sync
  Future<void> syncNow() async => syncManager.syncAll();


}
