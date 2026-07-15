// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_item_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduleItemLocalAdapter extends TypeAdapter<ScheduleItemLocal> {
  @override
  final int typeId = 1;

  @override
  ScheduleItemLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleItemLocal(
      localId: fields[0] as String,
      serverId: fields[2] as String?,
      userId: fields[3] as String,
      type: fields[4] as String,
      title: fields[5] as String,
      day: fields[6] as String?,
      startTime: fields[7] as String?,
      endTime: fields[8] as String?,
      room: fields[9] as String?,
      details: fields[10] as String?,
      startDate: fields[11] as DateTime?,
      endDate: fields[12] as DateTime?,
      isSynced: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleItemLocal obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.isSynced)
      ..writeByte(2)
      ..write(obj.serverId)
      ..writeByte(3)
      ..write(obj.userId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.day)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.endTime)
      ..writeByte(9)
      ..write(obj.room)
      ..writeByte(10)
      ..write(obj.details)
      ..writeByte(11)
      ..write(obj.startDate)
      ..writeByte(12)
      ..write(obj.endDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleItemLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
