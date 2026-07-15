
//dashboard/schedule/models/schedule_item_local.dart
import 'package:hive/hive.dart';

part 'schedule_item_local.g.dart';

@HiveType(typeId: 1)
class ScheduleItemLocal extends HiveObject {

  // Local-only fields
  @HiveField(0)
  String localId;       // always set (UUID)

  @HiveField(1)
  bool isSynced;        // used for offline → online sync

  // Server fields (mirrors your API)
  @HiveField(2)
  String? serverId;

  @HiveField(3)
  String userId;

  @HiveField(4)
  String type;

  @HiveField(5)
  String title;

  @HiveField(6)
  String? day;

  @HiveField(7)
  String? startTime;

  @HiveField(8)
  String? endTime;

  @HiveField(9)
  String? room;

  @HiveField(10)
  String? details;

  @HiveField(11)
  DateTime? startDate;

  @HiveField(12)
  DateTime? endDate;


  bool isDeleted;

  ScheduleItemLocal({
    required this.localId,
    this.serverId,
    required this.userId,
    required this.type,
    required this.title,
    this.day,
    this.startTime,
    this.endTime,
    this.room,
    this.details,
    this.startDate,
    this.endDate,
    this.isSynced = false,
    this.isDeleted = false,
  });
}
