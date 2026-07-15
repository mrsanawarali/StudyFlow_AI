import '../Subjects/subject_local.dart';
import 'hive_chapter_service.dart';
import 'chapter_api_service.dart';
import 'chapter.dart';
import '../Subjects/hive_subject_service.dart';

class ChapterSyncManager {
  final ChapterApiService api;
  bool _isSyncing = false;

  ChapterSyncManager({required this.api});

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncUnsynced();
      await _syncDeleted();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncUnsynced() async {
    final unsynced = HiveChapterService.getAll()
        .where((c) => !c.isSynced && !c.isDeleted && !c.isSyncing)
        .toList();

    for (var chapter in unsynced) {
      try {
        // Check if parent subject has a serverId
        SubjectLocal? subject;
        try {
          subject = HiveSubjectService.getAll()
              .firstWhere((s) => s.localId == chapter.subjectLocalId);
        } catch (_) {
          subject = null;
        }

        if (subject == null || subject.serverId == null) {
          print("❗ Skipping chapter ${chapter.localId} — parent subject not synced yet");
          continue;
        }

        // Ensure chapter has server IDs for parent
        chapter.subjectId = subject.serverId;
        chapter.semesterId ??= subject.semesterId; // optional if needed

        chapter.isSyncing = true;
        await HiveChapterService.addOrUpdate(chapter);

        if (chapter.serverId == null) {
          final created = await api.addChapter(
            Chapter(
              semesterId: chapter.semesterId!,
              subjectId: chapter.subjectId!,
              title: chapter.title,
              createdAt: chapter.createdAt,
            ),
          );
          chapter.serverId = created.id;
        } else {
          await api.updateChapter(
            Chapter(
              id: chapter.serverId,
              semesterId: chapter.semesterId!,
              subjectId: chapter.subjectId!,
              title: chapter.title,
              createdAt: chapter.createdAt,
            ),
          );
        }

        chapter.isSynced = true;
        chapter.isSyncing = false;
        await HiveChapterService.addOrUpdate(chapter);
        print("✅ Synced chapter: ${chapter.localId}");
      } catch (e) {
        chapter.isSyncing = false;
        await HiveChapterService.addOrUpdate(chapter);
        print("❌ Failed to sync ${chapter.localId}: $e");
      }
    }
  }

  Future<void> _syncDeleted() async {
    final deleted = HiveChapterService.getAll().where((c) => c.isDeleted).toList();

    for (var chapter in deleted) {
      try {
        if (chapter.serverId != null) {
          await api.deleteChapter(chapter.serverId!);
        }
        await HiveChapterService.delete(chapter.localId);
        print("🗑 Deleted chapter: ${chapter.localId}");
      } catch (e) {
        print("❌ Failed to delete ${chapter.localId}: $e");
      }
    }
  }
}
