import 'package:hive/hive.dart';
import 'subject_local.dart';
import 'hive_subject_helper.dart';

class HiveSubjectService {
  static Box<SubjectLocal> get _box => HiveSubjectHelper.getSubjectBox();

  static Future<void> addOrUpdate(SubjectLocal sub) async {
    await _box.put(sub.localId, sub);
  }

  static List<SubjectLocal> getAll() => _box.values.toList();

  static SubjectLocal? getByLocalId(String localId) {
    return _box.get(localId);
  }

  static Future<void> delete(String localId) async => await _box.delete(localId);

  static Future<void> clear() async => await _box.clear();

  static void printAll() {
    print("------ SUBJECTS (HIVE) ------");
    for (var s in _box.values) {
      print(
          "LocalID: ${s.localId} | ServerID: ${s.serverId} | SemesterLocalID: ${s.semesterLocalId} | Title: ${s.title} | Synced: ${s.isSynced} | Deleted: ${s.isDeleted}"
      );
    }
    print("-------------------------------");
  }
}
