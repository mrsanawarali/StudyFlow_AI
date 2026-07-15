import 'package:hive/hive.dart';
import 'chapter_local.dart';

class HiveChapterHelper {
  static const String chapterBoxName = 'chapterBox';

  static Future<void> init() async {
    Hive.registerAdapter(ChapterLocalAdapter());
    await Hive.openBox<ChapterLocal>(chapterBoxName);
  }

  static Box<ChapterLocal> getChapterBox() => Hive.box<ChapterLocal>(chapterBoxName);
}
