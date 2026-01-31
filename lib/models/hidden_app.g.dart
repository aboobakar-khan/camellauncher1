// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiddenAppAdapter extends TypeAdapter<HiddenApp> {
  @override
  final int typeId = 10;

  @override
  HiddenApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiddenApp(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      isHiddenByUser: fields[2] as bool,
      lastModified: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, HiddenApp obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.isHiddenByUser)
      ..writeByte(3)
      ..write(obj.lastModified);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiddenAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
