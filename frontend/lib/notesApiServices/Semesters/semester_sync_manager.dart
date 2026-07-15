import 'semester_local.dart';
import 'hive_semester_service.dart';
import 'semester_api_service.dart';
import 'semester.dart';

class SemesterSyncManager {
  final SemesterApiService api;
  bool _isSyncing = false; // Prevent concurrent syncs

  SemesterSyncManager({required this.api});

  /// Sync all local changes
  Future<void> syncAll() async {
    if (_isSyncing) return; // already syncing
    _isSyncing = true;
    try {
      await _syncUnsynced();
      await _syncDeleted();
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync new/edited semesters
  Future<void> _syncUnsynced() async {
    final unsynced = HiveSemesterService.getAll()
        .where((s) => !s.isSynced && !s.isDeleted && !(s.isSyncing ?? false))
        .toList();

    for (var sem in unsynced) {
      try {
        sem.isSyncing = true;
        await HiveSemesterService.addOrUpdate(sem);

        if (sem.serverId == null) {
          // New semester — add to server
          final created = await api.addSemester(
            Semester(
              userId: sem.userId,
              title: sem.title,
              createdAt: sem.createdAt,
            ),
          );
          sem.serverId = created.id;
        } else {
          // Existing semester — update on server
          final updated = await api.updateSemester(
            Semester(
              id: sem.serverId,
              userId: sem.userId,
              title: sem.title,
              createdAt: sem.createdAt,
            ),
          );
          sem.serverId = updated.id;
        }

        sem.isSynced = true;
        sem.isSyncing = false;
        await HiveSemesterService.addOrUpdate(sem);

        print("✅ Synced semester: ${sem.localId}");
      } catch (e) {
        sem.isSyncing = false;
        await HiveSemesterService.addOrUpdate(sem);
        print("❌ Failed to sync ${sem.localId}: $e");
      }
    }
  }

  /// Sync deleted semesters
  Future<void> _syncDeleted() async {
    final deleted = HiveSemesterService.getAll()
        .where((s) => s.isDeleted && !(s.isSyncing ?? false))
        .toList();

    for (var sem in deleted) {
      try {
        sem.isSyncing = true;
        await HiveSemesterService.addOrUpdate(sem);

        if (sem.serverId != null) {
          await api.deleteSemester(sem.serverId!);
        }

        await HiveSemesterService.delete(sem.localId);
        print("🗑 Deleted semester: ${sem.localId}");
      } catch (e) {
        sem.isSyncing = false;
        await HiveSemesterService.addOrUpdate(sem);
        print("❌ Failed to delete ${sem.localId}: $e");
      }
    }
  }
}
