// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_mode.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FocusModeSettingsAdapter extends TypeAdapter<FocusModeSettings> {
  @override
  final int typeId = 7;

  @override
  FocusModeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FocusModeSettings(
      isEnabled: fields[0] as bool,
      allowedApps: (fields[1] as List?)?.cast<String>(),
      startTime: fields[2] as DateTime?,
      endTime: fields[3] as DateTime?,
      blockMessage: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FocusModeSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.allowedApps)
      ..writeByte(2)
      ..write(obj.startTime)
      ..writeByte(3)
      ..write(obj.endTime)
      ..writeByte(4)
      ..write(obj.blockMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusModeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
