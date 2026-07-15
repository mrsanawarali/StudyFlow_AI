import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'schedule_item_local.dart';

class HiveHelper {
  static const String scheduleBoxName = 'schedule_items';

  // Call this at app startup
  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register the adapter (only once)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScheduleItemLocalAdapter());
    }

    // Open box
    await Hive.openBox<ScheduleItemLocal>(scheduleBoxName);
  }

  // Helper to get the box
  static Box<ScheduleItemLocal> getScheduleBox() {
    return Hive.box<ScheduleItemLocal>(scheduleBoxName);
  }
}
