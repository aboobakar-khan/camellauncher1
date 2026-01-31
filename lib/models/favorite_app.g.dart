// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_app.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteAppAdapter extends TypeAdapter<FavoriteApp> {
  @override
  final int typeId = 8;

  @override
  FavoriteApp read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteApp(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      addedAt: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteApp obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteAppAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
