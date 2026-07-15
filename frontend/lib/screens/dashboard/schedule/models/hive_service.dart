import 'package:hive/hive.dart';
import 'hive_helper.dart';
import 'network_utils.dart';
import 'schedule_item_local.dart';
import 'schedule_item.dart';
import '../api_service.dart';

class HiveService {
  static Box<ScheduleItemLocal> get _box => HiveHelper.getScheduleBox();

  /// ----------------- CRUD ----------------- ///

  static bool isEmpty() => _box.isEmpty;

  // Get items that are NOT deleted
  static List<ScheduleItemLocal> getVisibleItems() =>
      _box.values.where((item) => !item.isDeleted).toList();

  static Future<void> addOrUpdateItem(ScheduleItemLocal item) async {
    await _box.put(item.localId, item);
  }

  static Future<void> addAll(List<ScheduleItemLocal> items) async {
    final map = {for (var item in items) item.localId: item};
    await _box.putAll(map);
  }

// Mark an item as deleted locally
  static Future<void> markDeleted(ScheduleItemLocal item) async {
    item.isDeleted = true;
    item.isSynced = false; // will trigger API sync later
    await addOrUpdateItem(item);
  }

  static Future<void> deleteItem(String localId) async {
    if (_box.containsKey(localId)) await _box.delete(localId);
  }

  static List<ScheduleItemLocal> getAll() => _box.values.toList();

  static List<ScheduleItemLocal> getUnsyncedItems() =>
      _box.values.where((item) => !item.isSynced).toList();

  static void printHiveData() {
    print("Hive box contents:");
    if (_box.isEmpty) {
      print("Box is empty!");
      return;
    }
    for (var item in _box.values) {
      print('---');
      print('localId: ${item.localId}');
      print('serverId: ${item.serverId}');
      print('userId: ${item.userId}');
      print('type: ${item.type}');
      print('title: ${item.title}');
      print('day: ${item.day}');
      print('startTime: ${item.startTime}');
      print('endTime: ${item.endTime}');
      print('room: ${item.room}');
      print('details: ${item.details}');
      print('startDate: ${item.startDate}');
      print('endDate: ${item.endDate}');
      print('isSynced: ${item.isSynced}');
      print('isDeleted: ${item.isDeleted}');
      print('---');
    }
  }

  /// ----------------- API Conversion ----------------- ///

  static ScheduleItemLocal fromApi(ScheduleItem apiItem) {
    return ScheduleItemLocal(
      localId: apiItem.id ?? apiItem.title + DateTime.now().millisecondsSinceEpoch.toString(),
      serverId: apiItem.id,
      userId: apiItem.userId,
      type: apiItem.type,
      title: apiItem.title,
      day: apiItem.day,
      startTime: apiItem.startTime,
      endTime: apiItem.endTime,
      room: apiItem.room,
      details: apiItem.details,
      startDate: apiItem.startDate,
      endDate: apiItem.endDate,
      isSynced: true,
    );
  }

  /// ----------------- First-time sync ----------------- ///

  static Future<void> firstTimeSync(String userId, Map<String, List<ScheduleItem>> itemsMap) async {
    if (_box.isEmpty) {
      print("Hive empty — fetching from API...");
      for (var type in itemsMap.keys) {
        try {
          final fetched = await ApiService.fetchSchedule(userId, type: type);
          final hiveItems = fetched.map(fromApi).toList();
          await addAll(hiveItems);
          itemsMap[type] = fetched;
        } catch (e) {
          print('Error fetching $type: $e');
        }
      }
    } else {
      print("Hive has data — using local storage...");
      final allHiveItems = getVisibleItems();
      for (var type in itemsMap.keys) {
        itemsMap[type] =
            allHiveItems.where((item) => item.type == type).map((e) {
              return ScheduleItem(
                id: e.serverId,
                userId: e.userId,
                type: e.type,
                title: e.title,
                day: e.day,
                startTime: e.startTime,
                endTime: e.endTime,
                room: e.room,
                details: e.details,
                startDate: e.startDate,
                endDate: e.endDate,
              );
            }).toList();
      }
    }
  }

  /// ----------------- Sync ----------------- ///

  static Future<void> syncUnsyncedItems() async {
    final unsynced = getUnsyncedItems();
    if (unsynced.isEmpty) return;

    for (var item in unsynced) {
      try {
        final apiItem = ScheduleItem(
          id: item.serverId,
          userId: item.userId,
          type: item.type,
          title: item.title,
          day: item.day,
          startTime: item.startTime,
          endTime: item.endTime,
          room: item.room,
          details: item.details,
          startDate: item.startDate,
          endDate: item.endDate,
        );

        final saved = item.serverId == null
            ? await ApiService.addSchedule(apiItem)
            : await ApiService.updateSchedule(apiItem);

        item.isSynced = true;
        item.serverId = saved.id;
        await addOrUpdateItem(item);

        print('Synced item ${item.localId}');
      } catch (e) {
        print('Failed to sync ${item.localId}: $e');
      }
    }
  }
// Mark an item as deleted (offline-first)
  static Future<void> deleteItemOfflineFirst(ScheduleItemLocal item) async {
    if (item.serverId == null) {
      // Item never synced: delete immediately
      await _box.delete(item.localId);
      print('Locally deleted (never synced) ${item.localId}');
    } else {
      // Item synced: mark for deletion
      item.isDeleted = true;
      item.isSynced = false; // keep false until deletion synced
      await addOrUpdateItem(item);

      print('Marked deleted: ${item.localId}');

      // Attempt immediate sync if online
      if (await connectivityService.hasInternet()) {
        await syncDeletedItems();
      }
    }
  }

// Sync all deleted items
  static Future<void> syncDeletedItems() async {
    final deletedItems = _box.values.where((item) => item.isDeleted).toList();

    for (var item in deletedItems) {
      try {
        if (item.serverId != null) {
          await ApiService.deleteSchedule(item.serverId!);
        }
        await _box.delete(item.localId); // remove from Hive completely
        print('Deleted and synced ${item.localId}');
      } catch (e) {
        print('Failed to sync deletion for ${item.localId}: $e');
      }
    }
  }

// Get items marked deleted but not yet synced
  static List<ScheduleItemLocal> getDeletedItems() =>
      _box.values.where((item) => item.isDeleted && !item.isSynced).toList();


  static Future<ScheduleItemLocal> syncSingleItem(ScheduleItemLocal item) async {
    final apiItem = ScheduleItem(
      id: item.serverId,
      userId: item.userId,
      type: item.type,
      title: item.title,
      day: item.day,
      startTime: item.startTime,
      endTime: item.endTime,
      room: item.room,
      details: item.details,
      startDate: item.startDate,
      endDate: item.endDate,
    );

    ScheduleItem saved;
    if (item.serverId == null) {
      // New item: add to server
      saved = await ApiService.addSchedule(apiItem);
    } else {
      // Existing item: update on server
      saved = await ApiService.updateSchedule(apiItem);
    }

    // Update local item with serverId and mark as synced
    item.serverId = saved.id;
    item.isSynced = true;

    // Save back to Hive
    await addOrUpdateItem(item);

    return item;
  }
}
