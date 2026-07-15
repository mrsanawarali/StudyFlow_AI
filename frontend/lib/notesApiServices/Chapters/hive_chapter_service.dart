import 'package:hive/hive.dart';
import 'hive_chapter_helper.dart';
import 'chapter_local.dart';

class HiveChapterService {
  static Box<ChapterLocal> get _box => HiveChapterHelper.getChapterBox();

  static Future<void> addOrUpdate(ChapterLocal chapter) async {
    await _box.put(chapter.localId, chapter);
  }

  static List<ChapterLocal> getAll() => _box.values.toList();

  static ChapterLocal? getByLocalId(String localId) {
    return _box.get(localId);
  }
  static Future<void> delete(String localId) async => await _box.delete(localId);

  static Future<void> clear() async => await _box.clear();

  static void printAll() {
    print("------ CHAPTERS (HIVE) ------");
    for (var c in _box.values) {
      print(
          "LocalID: ${c.localId} | ServerID: ${c.serverId} | SubjectLocalID: ${c.subjectLocalId} | Title: ${c.title} | Synced: ${c.isSynced} | Deleted: ${c.isDeleted}"
      );
    }
    print("-------------------------------");
  }
}
