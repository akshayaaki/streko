import 'package:flutter_test/flutter_test.dart';
import 'package:streako/models/habit.dart';
import 'package:streako/models/habit_log.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit scheduling for daily habits', () {
      final habit = Habit(
        id: '1',
        name: 'Exercise',
        icon: 'gym',
        colorValue: 0xFF2EC4B6,
        frequency: HabitFrequency.daily,
      );

      final now = DateTime.now();
      expect(habit.isScheduledFor(now), isTrue);
    });

    test('Habit scheduling for specific days', () {
      final habit = Habit(
        id: '2',
        name: 'Weekend Project',
        icon: 'code',
        colorValue: 0xFF6C5CE7,
        frequency: HabitFrequency.specificDays,
        activeWeekdays: [6, 7], // Saturday, Sunday
      );

      // 2026-09-26 is a Saturday (weekday 6)
      final saturday = DateTime(2026, 9, 26);
      final monday = DateTime(2026, 9, 21);

      expect(habit.isScheduledFor(saturday), isTrue);
      expect(habit.isScheduledFor(monday), isFalse);
    });

    test('HabitLog normalizes date to midnight', () {
      final dateTime = DateTime(2026, 9, 23, 14, 35, 12);
      final normalized = HabitLog.normalize(dateTime);

      expect(normalized.year, equals(2026));
      expect(normalized.month, equals(9));
      expect(normalized.day, equals(23));
      expect(normalized.hour, equals(0));
      expect(normalized.minute, equals(0));
      expect(normalized.second, equals(0));
    });
  });
}
