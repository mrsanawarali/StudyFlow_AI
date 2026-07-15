import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'hive_service.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;


  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        print("Internet detected — syncing unsynced items...");
        await HiveService.syncUnsyncedItems();
        await HiveService.syncDeletedItems(); // add this line
      }
    });
  }
  void stopMonitoring() {
    _subscription?.cancel();
  }

  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}


// ✅ Singleton instance outside the class
final connectivityService = ConnectivityService();