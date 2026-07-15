// hive_note_helper.dart
import 'package:hive/hive.dart';
import 'note_local.dart';

class HiveNoteHelper {
  static const String noteBoxName = 'noteBox';

  static Future<void> init() async {
    Hive.registerAdapter(NoteLocalAdapter());
    await Hive.openBox<NoteLocal>(noteBoxName);
  }

  static Box<NoteLocal> getNoteBox() => Hive.box<NoteLocal>(noteBoxName);
}
