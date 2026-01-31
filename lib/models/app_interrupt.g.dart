// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_interrupt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppInterruptAdapter extends TypeAdapter<AppInterrupt> {
  @override
  final int typeId = 5;

  @override
  AppInterrupt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppInterrupt(
      packageName: fields[0] as String,
      appName: fields[1] as String,
      method: fields[2] as InterruptMethod,
      customPassword: fields[3] as String?,
      reminderMessage: fields[4] as String?,
      showReminder: fields[5] as bool,
      isEnabled: fields[6] as bool,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppInterrupt obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.method)
      ..writeByte(3)
      ..write(obj.customPassword)
      ..writeByte(4)
      ..write(obj.reminderMessage)
      ..writeByte(5)
      ..write(obj.showReminder)
      ..writeByte(6)
      ..write(obj.isEnabled)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppInterruptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InterruptMethodAdapter extends TypeAdapter<InterruptMethod> {
  @override
  final int typeId = 6;

  @override
  InterruptMethod read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InterruptMethod.timer30;
      case 1:
        return InterruptMethod.textPassword;
      case 2:
        return InterruptMethod.voiceConfirmation;
      case 3:
        return InterruptMethod.timerAndReminder;
      case 4:
        return InterruptMethod.passwordAndReminder;
      case 5:
        return InterruptMethod.voiceAndReminder;
      default:
        return InterruptMethod.timer30;
    }
  }

  @override
  void write(BinaryWriter writer, InterruptMethod obj) {
    switch (obj) {
      case InterruptMethod.timer30:
        writer.writeByte(0);
        break;
      case InterruptMethod.textPassword:
        writer.writeByte(1);
        break;
      case InterruptMethod.voiceConfirmation:
        writer.writeByte(2);
        break;
      case InterruptMethod.timerAndReminder:
        writer.writeByte(3);
        break;
      case InterruptMethod.passwordAndReminder:
        writer.writeByte(4);
        break;
      case InterruptMethod.voiceAndReminder:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InterruptMethodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
