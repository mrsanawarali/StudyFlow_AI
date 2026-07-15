import 'package:hive/hive.dart';

part 'semester_local.g.dart';

@HiveType(typeId: 3)
class SemesterLocal extends HiveObject {
  @HiveField(0)
  String localId;

  @HiveField(1)
  String? serverId;

  @HiveField(2)
  String userId;

  @HiveField(3)
  String title;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  bool isSyncing = false;

  SemesterLocal({
    required this.localId,
    this.serverId,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.isSynced = false,
    this.isDeleted = false,
  });
}
