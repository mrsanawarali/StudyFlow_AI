import 'package:hive/hive.dart';

part 'chapter_local.g.dart';

@HiveType(typeId: 5)
class ChapterLocal extends HiveObject {
  @HiveField(0)
  String localId;

  @HiveField(1)
  String? serverId;

  @HiveField(2)
  String semesterLocalId;

  @HiveField(3)
  String? semesterId;

  @HiveField(4)
  String subjectLocalId;

  @HiveField(5)
  String? subjectId;

  @HiveField(6)
  String title;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  bool isSynced;

  @HiveField(9)
  bool isDeleted;

  @HiveField(10)
  bool isSyncing = false;

  ChapterLocal({
    required this.localId,
    this.serverId,
    required this.semesterLocalId,
    this.semesterId,
    required this.subjectLocalId,
    this.subjectId,
    required this.title,
    required this.createdAt,
    this.isSynced = false,
    this.isDeleted = false,
  });
}
