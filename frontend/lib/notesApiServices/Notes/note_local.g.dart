// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteLocalAdapter extends TypeAdapter<NoteLocal> {
  @override
  final int typeId = 6;

  @override
  NoteLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteLocal(
      localId: fields[0] as String,
      serverId: fields[1] as String?,
      semesterLocalId: fields[2] as String,
      semesterId: fields[3] as String?,
      subjectLocalId: fields[4] as String,
      subjectId: fields[5] as String?,
      chapterLocalId: fields[6] as String,
      chapterId: fields[7] as String?,
      userId: fields[8] as String,
      type: fields[9] as String,
      title: fields[10] as String?,
      content: fields[11] as String?,
      fileName: fields[12] as String?,
      fileUrl: fields[13] as String?,
      imageUrl: fields[14] as String?,
      publicId: fields[15] as String?,
      fileBytes: fields[16] as Uint8List?,
      createdAt: fields[17] as DateTime?,
      isSynced: fields[18] as bool,
      isDeleted: fields[19] as bool,
      isSyncing: fields[20] as bool,
      isDirty: fields[21] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, NoteLocal obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.semesterLocalId)
      ..writeByte(3)
      ..write(obj.semesterId)
      ..writeByte(4)
      ..write(obj.subjectLocalId)
      ..writeByte(5)
      ..write(obj.subjectId)
      ..writeByte(6)
      ..write(obj.chapterLocalId)
      ..writeByte(7)
      ..write(obj.chapterId)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.type)
      ..writeByte(10)
      ..write(obj.title)
      ..writeByte(11)
      ..write(obj.content)
      ..writeByte(12)
      ..write(obj.fileName)
      ..writeByte(13)
      ..write(obj.fileUrl)
      ..writeByte(14)
      ..write(obj.imageUrl)
      ..writeByte(15)
      ..write(obj.publicId)
      ..writeByte(16)
      ..write(obj.fileBytes)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.isSynced)
      ..writeByte(19)
      ..write(obj.isDeleted)
      ..writeByte(20)
      ..write(obj.isSyncing)
      ..writeByte(21)
      ..write(obj.isDirty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
