// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deen_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeenModeSettingsAdapter extends TypeAdapter<DeenModeSettings> {
  @override
  final int typeId = 15;

  @override
  DeenModeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeenModeSettings(
      isEnabled: fields[0] as bool,
      startTime: fields[1] as DateTime?,
      endTime: fields[2] as DateTime?,
      durationMinutes: fields[3] as int,
      purpose: fields[4] as String,
      notificationsMuted: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DeenModeSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.durationMinutes)
      ..writeByte(4)
      ..write(obj.purpose)
      ..writeByte(5)
      ..write(obj.notificationsMuted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeenModeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
