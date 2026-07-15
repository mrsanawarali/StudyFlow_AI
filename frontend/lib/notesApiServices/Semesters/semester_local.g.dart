// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SemesterLocalAdapter extends TypeAdapter<SemesterLocal> {
  @override
  final int typeId = 3;

  @override
  SemesterLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SemesterLocal(
      localId: fields[0] as String,
      serverId: fields[1] as String?,
      userId: fields[2] as String,
      title: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isSynced: fields[5] as bool,
      isDeleted: fields[6] as bool,
    )..isSyncing = fields[7] as bool;
  }

  @override
  void write(BinaryWriter writer, SemesterLocal obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.serverId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isSynced)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.isSyncing);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemesterLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
