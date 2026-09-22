// GENERATED CODE - hand-authored to match build_runner output.
// If you run `flutter pub run build_runner build`, this file will be
// regenerated automatically from the annotations in habit.dart.

part of 'habit.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 1;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorValue: fields[3] as int,
      frequency: fields[4] as HabitFrequency,
      activeWeekdays: (fields[5] as List).cast<int>(),
      timesPerWeekTarget: fields[6] as int,
      targetCount: fields[7] as int?,
      unit: fields[8] as String?,
      createdAt: fields[9] as DateTime,
      reminderTimes: (fields[10] as List).cast<String>(),
      archived: fields[11] as bool,
      currentStreak: fields[12] as int,
      longestStreak: fields[13] as int,
      freezesAvailable: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.activeWeekdays)
      ..writeByte(6)
      ..write(obj.timesPerWeekTarget)
      ..writeByte(7)
      ..write(obj.targetCount)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.reminderTimes)
      ..writeByte(11)
      ..write(obj.archived)
      ..writeByte(12)
      ..write(obj.currentStreak)
      ..writeByte(13)
      ..write(obj.longestStreak)
      ..writeByte(14)
      ..write(obj.freezesAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final int typeId = 0;

  @override
  HabitFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequency.daily;
      case 1:
        return HabitFrequency.specificDays;
      case 2:
        return HabitFrequency.timesPerWeek;
      default:
        return HabitFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    switch (obj) {
      case HabitFrequency.daily:
        writer.writeByte(0);
        break;
      case HabitFrequency.specificDays:
        writer.writeByte(1);
        break;
      case HabitFrequency.timesPerWeek:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
