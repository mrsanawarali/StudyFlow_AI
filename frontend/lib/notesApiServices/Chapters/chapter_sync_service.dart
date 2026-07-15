import 'package:connectivity_plus/connectivity_plus.dart';
import 'chapter_sync_manager.dart';
import 'hive_chapter_service.dart';

class ChapterSyncService {
  final ChapterSyncManager syncManager;

  ChapterSyncService({required this.syncManager}) {
    _initConnectivityListener();
  }

  void _initConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((status) async {
      if (status != ConnectivityResult.none) {
        print("📶 Internet back — syncing chapters...");
        try {
          await syncManager.syncAll();
        } catch (e) {
          print("⚠️ Chapter connectivity sync failed: $e");
        }
        HiveChapterService.printAll();
      }
    });
  }
}
