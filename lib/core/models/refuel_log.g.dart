// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refuel_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RefuelLogAdapter extends TypeAdapter<RefuelLog> {
  @override
  final int typeId = 9;

  @override
  RefuelLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RefuelLog(
      id: fields[4] == null ? '' : fields[4] as String,
      date: fields[0] as DateTime,
      hasBreakfast: fields[1] as bool,
      hasLunch: fields[2] as bool,
      hasDinner: fields[3] as bool,
      userId: fields[5] == null ? 'local' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RefuelLog obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.hasBreakfast)
      ..writeByte(2)
      ..write(obj.hasLunch)
      ..writeByte(3)
      ..write(obj.hasDinner)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefuelLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
