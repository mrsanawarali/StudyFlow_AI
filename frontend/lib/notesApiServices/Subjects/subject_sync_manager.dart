// subject_sync_manager.dart
import 'subject_local.dart';
import 'hive_subject_service.dart';
import 'subject_api_service.dart';
import 'subject.dart';

class SubjectSyncManager {
  final SubjectApiService api;

  SubjectSyncManager({required this.api});

  /// Sync all subjects
  Future<void> syncAll() async {
    await _syncUnsynced();
    await _syncDeleted();
  }

  /// Sync subjects that are not synced and not deleted
  Future<void> _syncUnsynced() async {
    final unsynced = HiveSubjectService.getAll()
        .where((s) => !s.isSynced && !s.isDeleted && !s.isSyncing)
        .toList();

    for (var sub in unsynced) {
      try {
        sub.isSyncing = true;
        await HiveSubjectService.addOrUpdate(sub);

        if (sub.semesterId == null) {
          print("⚠️ Skipping ${sub.localId}: missing server semesterId");
          sub.isSyncing = false;
          await HiveSubjectService.addOrUpdate(sub);
          continue;
        }

        if (sub.serverId == null) {
          final created = await api.addSubject(
            Subject(
              semesterId: sub.semesterId!,
              title: sub.title,
              courseCode: sub.courseCode,
              instructor: sub.instructor,
              createdAt: sub.createdAt,
            ),
          );
          sub.serverId = created.id;
        } else {
          await api.updateSubject(
            Subject(
              id: sub.serverId,
              semesterId: sub.semesterId!,
              title: sub.title,
              courseCode: sub.courseCode,
              instructor: sub.instructor,
              createdAt: sub.createdAt,
            ),
          );
        }

        sub.isSynced = true;
        sub.isSyncing = false;
        await HiveSubjectService.addOrUpdate(sub);

        print("✅ Synced subject: ${sub.localId}");
      } catch (e) {
        sub.isSyncing = false;
        await HiveSubjectService.addOrUpdate(sub);
        print("❌ Failed to sync ${sub.localId}: $e");
      }
    }
  }

  /// Sync subjects marked as deleted
  Future<void> _syncDeleted() async {
    final deleted = HiveSubjectService.getAll()
        .where((s) => s.isDeleted)
        .toList();

    for (var sub in deleted) {
      try {
        if (sub.serverId != null) {
          await api.deleteSubject(sub.serverId!);
        }
        await HiveSubjectService.delete(sub.localId);
        print("🗑 Deleted subject: ${sub.localId}");
      } catch (e) {
        print("❌ Failed to delete ${sub.localId}: $e");
      }
    }
  }
}
