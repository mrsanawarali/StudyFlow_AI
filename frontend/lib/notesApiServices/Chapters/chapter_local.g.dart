// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChapterLocalAdapter extends TypeAdapter<ChapterLocal> {
  @override
  final int typeId = 5;

  @override
  ChapterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterLocal(
      localId: fields[0] as String,
      serverId: fields[1] as String?,
      semesterLocalId: fields[2] as String,
      semesterId: fields[3] as String?,
      subjectLocalId: fields[4] as String,
      subjectId: fields[5] as String?,
      title: fields[6] as String,
      createdAt: fields[7] as DateTime,
      isSynced: fields[8] as bool,
      isDeleted: fields[9] as bool,
    )..isSyncing = fields[10] as bool;
  }

  @override
  void write(BinaryWriter writer, ChapterLocal obj) {
    writer
      ..writeByte(11)
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
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.isSynced)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.isSyncing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
