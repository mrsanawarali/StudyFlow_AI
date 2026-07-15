import 'package:hive/hive.dart';

part 'subject_local.g.dart';

@HiveType(typeId: 4)
class SubjectLocal extends HiveObject {
  @HiveField(0)
  String localId;

  @HiveField(1)
  String? serverId; // MongoDB _id

  @HiveField(2)
  String semesterLocalId; // local offline ID

  @HiveField(3)
  String? semesterId; // server-side ObjectId

  @HiveField(4)
  String title;

  @HiveField(5)
  String courseCode;

  @HiveField(6)
  String instructor;

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  bool isDeleted;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  bool isSyncing = false;

  SubjectLocal({
    required this.localId,
    this.serverId,
    required this.semesterLocalId,
    this.semesterId,
    required this.title,
    this.courseCode = '',
    this.instructor = '',
    this.isSynced = false,
    this.isDeleted = false,
    required this.createdAt,
  });
}
