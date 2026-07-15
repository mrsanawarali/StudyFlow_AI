import 'package:hive/hive.dart';
import 'semester_local.dart';

class HiveSemesterHelper {
  static const String semesterBoxName = 'semesterBox';

  static Future<void> init() async {
    Hive.registerAdapter(SemesterLocalAdapter());
    await Hive.openBox<SemesterLocal>(semesterBoxName);
  }

  static Box<SemesterLocal> getSemesterBox() =>
      Hive.box<SemesterLocal>(semesterBoxName);
}
