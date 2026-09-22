import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/habit_repository.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../services/notification_service.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  throw UnimplementedError('Override in main.dart after repository.init()');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Bumping this int forces dependent providers to re-read from the repo.
final habitsRefreshProvider = StateProvider<int>((ref) => 0);

final habitsListProvider = Provider<List<Habit>>((ref) {
  ref.watch(habitsRefreshProvider);
  final repo = ref.watch(habitRepositoryProvider);
  return repo.getAllHabits();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return HabitLog.normalize(DateTime.now());
});

/// Habits scheduled for the currently selected date, with today's log attached.
final scheduledHabitsForDateProvider =
    Provider<List<HabitWithLog>>((ref) {
  ref.watch(habitsRefreshProvider);
  final repo = ref.watch(habitRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  final habits = repo.getAllHabits().where((h) => h.isScheduledFor(date));
  return habits
      .map((h) => HabitWithLog(h, repo.getLogForDate(h.id, date)))
      .toList();
});

final overallConsistencyProvider = Provider<double>((ref) {
  ref.watch(habitsRefreshProvider);
  final repo = ref.watch(habitRepositoryProvider);
  return repo.overallConsistency();
});

class HabitWithLog {
  final Habit habit;
  final HabitLog? log;
  HabitWithLog(this.habit, this.log);
}

/// Notifier-style controller for mutating habits/logs and triggering refresh.
class HabitController {
  final HabitRepository repo;
  final NotificationService notifications;
  final Ref ref;

  HabitController(this.repo, this.notifications, this.ref);

  Future<void> toggleCompletion(Habit habit, DateTime date) async {
    await repo.logProgress(habit, date);
    _refresh();
  }

  Future<void> incrementProgress(Habit habit, DateTime date, {int by = 1}) async {
    await repo.logProgress(habit, date, incrementBy: by);
    _refresh();
  }

  Future<Habit> createHabit({
    required String name,
    required String icon,
    required int colorValue,
    required HabitFrequency frequency,
    List<int>? activeWeekdays,
    int timesPerWeekTarget = 3,
    int? targetCount,
    String? unit,
    List<String>? reminderTimes,
  }) async {
    final habit = await repo.createHabit(
      name: name,
      icon: icon,
      colorValue: colorValue,
      frequency: frequency,
      activeWeekdays: activeWeekdays,
      timesPerWeekTarget: timesPerWeekTarget,
      targetCount: targetCount,
      unit: unit,
      reminderTimes: reminderTimes,
    );
    if (habit.reminderTimes.isNotEmpty) {
      await notifications.scheduleHabitReminders(habit);
    }
    _refresh();
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await repo.updateHabit(habit);
    await notifications.scheduleHabitReminders(habit);
    _refresh();
  }

  Future<void> archiveHabit(String id) async {
    final habit = repo.getHabit(id);
    if (habit != null) await notifications.cancelHabitReminders(habit);
    await repo.archiveHabit(id);
    _refresh();
  }

  Future<void> deleteHabit(String id) async {
    final habit = repo.getHabit(id);
    if (habit != null) await notifications.cancelHabitReminders(habit);
    await repo.deleteHabit(id);
    _refresh();
  }

  void _refresh() {
    ref.read(habitsRefreshProvider.notifier).state++;
  }
}

final habitControllerProvider = Provider<HabitController>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final notif = ref.watch(notificationServiceProvider);
  return HabitController(repo, notif, ref);
});
