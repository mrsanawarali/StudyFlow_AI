// note_item.dart
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'note_local.dart';

class NoteItem {
  static final _uuid = Uuid();

  final String localId;
  String? serverId;
  String? chapterId;
  String? subjectId;
  String? semesterId;
  final String userId;

  String type; // "text", "file", "image"
  String? title;
  String? content;
  String? fileName;
  String? fileUrl;
  String? imageUrl;
  String? publicId;
  Uint8List? fileBytes;

  DateTime createdAt;
  bool isSynced;
  bool isDeleted;
  bool isSyncing;
  bool isDirty;

  NoteItem({
    String? localId,
    this.chapterId,
    this.subjectId,
    this.semesterId,
    required this.userId,
    required this.type,
    this.title,
    this.content,
    this.fileName,
    this.fileUrl,
    this.imageUrl,
    this.publicId,
    this.fileBytes,
    this.serverId,
    DateTime? createdAt,
    this.isSynced = false,
    this.isDeleted = false,
    this.isSyncing = false,
    this.isDirty = false,
  })  : localId = localId ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  // Convert frontend NoteItem to Hive local note
  NoteLocal toLocal({
    required String semesterLocalId,
    required String subjectLocalId,
    required String chapterLocalId,
  }) {
    return NoteLocal(
      localId: localId,
      serverId: serverId,

      semesterLocalId: semesterLocalId,
      semesterId: semesterId,

      subjectLocalId: subjectLocalId,
      subjectId: subjectId,

      chapterLocalId: chapterLocalId,
      chapterId: chapterId,

      userId: userId,
      type: type,
      title: title,
      content: content,
      fileName: fileName,
      fileUrl: fileUrl,
      imageUrl: imageUrl,
      publicId: publicId,
      fileBytes: fileBytes,

      createdAt: createdAt,
      isSynced: isSynced,
      isDeleted: isDeleted,
      isSyncing: isSyncing,
      isDirty: isDirty,
    );
  }


  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      localId: json['localId'] ?? _uuid.v4(),
      serverId: json['id'] ?? json['serverId'],
      chapterId: json['chapterId'],
      subjectId: json['subjectId'],
      semesterId: json['semesterId'],
      userId: json['userId'] ?? 'currentUser',
      type: json['type'] ?? 'text',
      title: json['title'],
      content: json['content'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      imageUrl: json['imageUrl'],
      publicId: json['publicId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      isSynced: true,
      isDeleted: false,
      isSyncing: false,
      isDirty: false,
    );
  }
}
