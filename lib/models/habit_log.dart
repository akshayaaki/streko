import 'package:hive/hive.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 2)
class HabitLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String habitId;

  /// Stored at midnight (date-only) for easy lookups.
  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool completed;

  /// For habits with a numeric target, how much was logged.
  @HiveField(4)
  int progressCount;

  @HiveField(5)
  String? note;

  @HiveField(6)
  bool usedFreeze;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    this.completed = false,
    this.progressCount = 0,
    this.note,
    this.usedFreeze = false,
  });

  static DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}
