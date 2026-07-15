import 'package:hive/hive.dart';
import 'dart:typed_data';

part 'note_local.g.dart';

@HiveType(typeId: 6)
class NoteLocal extends HiveObject {
  @HiveField(0)
  String localId;

  @HiveField(1)
  String? serverId;

  // -------------------------------
  // Parent Linking (LOCAL + SERVER)
  // -------------------------------

  @HiveField(2)
  String semesterLocalId;

  @HiveField(3)
  String? semesterId;

  @HiveField(4)
  String subjectLocalId;

  @HiveField(5)
  String? subjectId;

  @HiveField(6)
  String chapterLocalId;

  @HiveField(7)
  String? chapterId;

  // -------------------------------
  // Content
  // -------------------------------

  @HiveField(8)
  String userId;

  @HiveField(9)
  String type;

  @HiveField(10)
  String? title;

  @HiveField(11)
  String? content;

  @HiveField(12)
  String? fileName;

  @HiveField(13)
  String? fileUrl;

  @HiveField(14)
  String? imageUrl;

  @HiveField(15)
  String? publicId;

  @HiveField(16)
  Uint8List? fileBytes;

  // -------------------------------
  // Meta
  // -------------------------------

  @HiveField(17)
  DateTime createdAt;

  @HiveField(18)
  bool isSynced;

  @HiveField(19)
  bool isDeleted;

  @HiveField(20)
  bool isSyncing;

  @HiveField(21)
  bool isDirty;

  NoteLocal({
    required this.localId,
    this.serverId,

    required this.semesterLocalId,
    this.semesterId,

    required this.subjectLocalId,
    this.subjectId,

    required this.chapterLocalId,
    this.chapterId,

    required this.userId,
    required this.type,
    this.title,
    this.content,
    this.fileName,
    this.fileUrl,
    this.imageUrl,
    this.publicId,
    this.fileBytes,

    DateTime? createdAt,
    this.isSynced = false,
    this.isDeleted = false,
    this.isSyncing = false,
    this.isDirty = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NoteLocal.fromJson(Map<String, dynamic> json) {
    return NoteLocal(
      localId: json['localId'] ?? "local_${DateTime.now().millisecondsSinceEpoch}",
      serverId: json['id'] ?? json['_id'],

      semesterLocalId: json['semesterLocalId'] ?? "",
      semesterId: json['semesterId'],

      subjectLocalId: json['subjectLocalId'] ?? "",
      subjectId: json['subjectId'],

      chapterLocalId: json['chapterLocalId'] ?? "",
      chapterId: json['chapterId'],

      userId: json['userId'] ?? "",
      type: json['type'] ?? "text",
      title: json['title'],
      content: json['content'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      imageUrl: json['imageUrl'],
      publicId: json['publicId'],

      fileBytes: json['fileBytes'] != null
          ? Uint8List.fromList(List<int>.from(json['fileBytes']))
          : null,

      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
      isSynced: true,
      isDeleted: false,
      isSyncing: false,
      isDirty: false,
    );
  }
}
