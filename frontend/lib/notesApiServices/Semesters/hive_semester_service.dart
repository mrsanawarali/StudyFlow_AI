import 'package:hive/hive.dart';
import 'semester_local.dart';
import 'hive_semester_helper.dart';

class HiveSemesterService {
  static Box<SemesterLocal> get _box => HiveSemesterHelper.getSemesterBox();

  static Future<void> addOrUpdate(SemesterLocal sem) async {
    await _box.put(sem.localId, sem);  
  }

  static List<SemesterLocal> getAll() {
    return _box.values.toList();
  }

  static Future<void> delete(String localId) async {
    await _box.delete(localId);
  }

  static Future<void> clear() async {
    await _box.clear();
  }

  static void printAll() {
    print("------ SEMESTERS (HIVE) ------");
    for (var item in _box.values) {
      print(
          "LocalID: ${item.localId} | "
              "ServerID: ${item.serverId} | "
              "Title: ${item.title} | "
              "Synced: ${item.isSynced} | "
              "Deleted: ${item.isDeleted}"
      );
    }
    print("--------------------------------");
  }
}
