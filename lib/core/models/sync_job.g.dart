// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_job.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncJobAdapter extends TypeAdapter<SyncJob> {
  @override
  final int typeId = 11;

  @override
  SyncJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncJob(
      id: fields[0] as String,
      action: fields[1] as String,
      table: fields[2] as String,
      payload: (fields[3] as Map).cast<String, dynamic>(),
      state: fields[4] as SyncState,
      retryCount: fields[5] as int,
      lastAttempt: fields[6] as DateTime?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncJob obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.table)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.lastAttempt)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncJobAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStateAdapter extends TypeAdapter<SyncState> {
  @override
  final int typeId = 10;

  @override
  SyncState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncState.pending;
      case 1:
        return SyncState.syncing;
      case 2:
        return SyncState.failed;
      case 3:
        return SyncState.retrying;
      default:
        return SyncState.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncState obj) {
    switch (obj) {
      case SyncState.pending:
        writer.writeByte(0);
        break;
      case SyncState.syncing:
        writer.writeByte(1);
        break;
      case SyncState.failed:
        writer.writeByte(2);
        break;
      case SyncState.retrying:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
