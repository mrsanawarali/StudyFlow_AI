import 'package:hive/hive.dart';
import 'subject_local.dart';

class HiveSubjectHelper {
  static const String subjectBoxName = 'subjectBox';

  static Future<void> init() async {
    Hive.registerAdapter(SubjectLocalAdapter());
    await Hive.openBox<SubjectLocal>(subjectBoxName);
  }

  static Box<SubjectLocal> getSubjectBox() => Hive.box<SubjectLocal>(subjectBoxName);
}
