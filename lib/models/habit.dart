import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  specificDays,
  @HiveField(2)
  timesPerWeek,
}

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon; // stored as a codepoint key, mapped in UI layer

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  HabitFrequency frequency;

  /// For specificDays: list of weekday ints (1 = Monday ... 7 = Sunday)
  @HiveField(5)
  List<int> activeWeekdays;

  /// For timesPerWeek: target count per week
  @HiveField(6)
  int timesPerWeekTarget;

  /// Optional numeric target per check-in (e.g. 8 glasses of water). Null = simple boolean habit.
  @HiveField(7)
  int? targetCount;

  @HiveField(8)
  String? unit; // e.g. "glasses", "pages"

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  List<String> reminderTimes; // stored as "HH:mm" strings

  @HiveField(11)
  bool archived;

  @HiveField(12)
  int currentStreak;

  @HiveField(13)
  int longestStreak;

  @HiveField(14)
  int freezesAvailable;

  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.frequency,
    List<int>? activeWeekdays,
    this.timesPerWeekTarget = 3,
    this.targetCount,
    this.unit,
    DateTime? createdAt,
    List<String>? reminderTimes,
    this.archived = false,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezesAvailable = 1,
  })  : activeWeekdays = activeWeekdays ?? [1, 2, 3, 4, 5, 6, 7],
        createdAt = createdAt ?? DateTime.now(),
        reminderTimes = reminderTimes ?? [];

  /// Is this habit scheduled for the given date, based on its frequency rules.
  bool isScheduledFor(DateTime date) {
    if (archived) return false;
    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.specificDays:
        return activeWeekdays.contains(date.weekday);
      case HabitFrequency.timesPerWeek:
        return true; // any day is eligible; weekly target checked separately
    }
  }
}
