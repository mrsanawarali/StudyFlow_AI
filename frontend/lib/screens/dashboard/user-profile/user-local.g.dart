// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user-local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLocalAdapter extends TypeAdapter<UserLocal> {
  @override
  final int typeId = 10;

  @override
  UserLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLocal(
      firebaseUid: fields[0] as String,
      name: fields[1] as String,
      bio: fields[2] as String,
      avatarUrl: fields[3] as String,
      visible: fields[4] as bool,
      bookmarked: (fields[5] as List?)?.cast<String>(),
      isSynced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserLocal obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.firebaseUid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.bio)
      ..writeByte(3)
      ..write(obj.avatarUrl)
      ..writeByte(4)
      ..write(obj.visible)
      ..writeByte(5)
      ..write(obj.bookmarked)
      ..writeByte(6)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
