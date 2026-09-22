import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

/// Single source of truth for habit + log persistence.
/// Backed by Hive today; swap the box calls for a remote data source later
/// (e.g. Supabase) without touching callers, since they only see this class.
class HabitRepository {
  static const String habitsBoxName = 'habits_box';
  static const String logsBoxName = 'logs_box';

  late Box<Habit> _habitsBox;
  late Box<HabitLog> _logsBox;
  final _uuid = const Uuid();

  Box<Habit> get habitsBox => _habitsBox;
  Box<HabitLog> get logsBox => _logsBox;

  static Future<void> registerAdapters() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitFrequencyAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HabitLogAdapter());
    }
  }

  Future<void> init() async {
    await registerAdapters();
    _habitsBox = await Hive.openBox<Habit>(habitsBoxName);
    _logsBox = await Hive.openBox<HabitLog>(logsBoxName);
  }

  // ---------- Habit CRUD ----------

  List<Habit> getAllHabits({bool includeArchived = false}) {
    final all = _habitsBox.values.toList();
    final filtered =
        includeArchived ? all : all.where((h) => !h.archived).toList();
    filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return filtered;
  }

  Habit? getHabit(String id) {
    try {
      return _habitsBox.values.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
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
    final habit = Habit(
      id: _uuid.v4(),
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
    await _habitsBox.add(habit);
    return habit;
  }

  Future<void> updateHabit(Habit habit) async {
    await habit.save();
  }

  Future<void> archiveHabit(String id) async {
    final habit = getHabit(id);
    if (habit != null) {
      habit.archived = true;
      await habit.save();
    }
  }

  Future<void> deleteHabit(String id) async {
    final habit = getHabit(id);
    if (habit == null) return;
    final logsToDelete =
        _logsBox.values.where((l) => l.habitId == id).toList();
    for (final log in logsToDelete) {
      await log.delete();
    }
    await habit.delete();
  }

  // ---------- Log CRUD ----------

  HabitLog? getLogForDate(String habitId, DateTime date) {
    final normalized = HabitLog.normalize(date);
    try {
      return _logsBox.values.firstWhere(
        (l) => l.habitId == habitId && l.date == normalized,
      );
    } catch (_) {
      return null;
    }
  }

  List<HabitLog> getLogsForHabit(String habitId) {
    return _logsBox.values.where((l) => l.habitId == habitId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<HabitLog> getLogsForDate(DateTime date) {
    final normalized = HabitLog.normalize(date);
    return _logsBox.values.where((l) => l.date == normalized).toList();
  }

  /// Toggle or increment a habit's completion for [date].
  /// For simple habits, this flips completed on/off.
  /// For target-count habits, pass [incrementBy] to add to progress.
  Future<HabitLog> logProgress(
    Habit habit,
    DateTime date, {
    int incrementBy = 1,
    bool? forceCompleted,
  }) async {
    final normalized = HabitLog.normalize(date);
    var log = getLogForDate(habit.id, normalized);

    log ??= HabitLog(
      id: _uuid.v4(),
      habitId: habit.id,
      date: normalized,
    );

    if (habit.targetCount != null) {
      log.progressCount += incrementBy;
      if (log.progressCount < 0) log.progressCount = 0;
      log.completed = log.progressCount >= habit.targetCount!;
    } else {
      log.completed = forceCompleted ?? !log.completed;
      log.progressCount = log.completed ? 1 : 0;
    }

    if (log.isInBox) {
      await log.save();
    } else {
      await _logsBox.add(log);
    }

    await recalculateStreak(habit);
    return log;
  }

  Future<void> setNote(Habit habit, DateTime date, String note) async {
    final normalized = HabitLog.normalize(date);
    var log = getLogForDate(habit.id, normalized);
    log ??= HabitLog(id: _uuid.v4(), habitId: habit.id, date: normalized);
    log.note = note;
    if (log.isInBox) {
      await log.save();
    } else {
      await _logsBox.add(log);
    }
  }

  // ---------- Streak logic ----------

  /// Recomputes current + longest streak for a habit by walking backward
  /// from today. A day counts toward the streak if it was completed, if it
  /// wasn't scheduled, or if a freeze was applied.
  Future<void> recalculateStreak(Habit habit) async {
    final logs = {
      for (final l in getLogsForHabit(habit.id)) l.date: l,
    };

    int current = 0;
    int longest = 0;
    int running = 0;
    DateTime cursor = HabitLog.normalize(DateTime.now());

    // Walk backward up to 2 years to compute current streak, stop at first break.
    bool stillCounting = true;
    for (int i = 0; i < 730; i++) {
      final day = cursor.subtract(Duration(days: i));
      final scheduled = habit.isScheduledFor(day);
      final log = logs[day];
      final dayOk = !scheduled || (log?.completed ?? false) || (log?.usedFreeze ?? false);

      if (stillCounting) {
        if (dayOk) {
          if (scheduled && (log?.completed ?? false)) current++;
          // unscheduled days don't increment but don't break either
        } else {
          stillCounting = false;
        }
      }
    }

    // Longest streak: forward scan over full history.
    final sortedDates = logs.keys.toList()..sort();
    if (sortedDates.isNotEmpty) {
      DateTime? prev;
      for (final d in sortedDates) {
        final log = logs[d]!;
        final scheduled = habit.isScheduledFor(d);
        final dayOk = log.completed || log.usedFreeze;
        if (scheduled && dayOk) {
          if (prev != null && d.difference(prev).inDays <= 1) {
            running++;
          } else {
            running = 1;
          }
          longest = running > longest ? running : longest;
          prev = d;
        } else if (scheduled) {
          running = 0;
          prev = d;
        }
      }
    }

    habit.currentStreak = current;
    habit.longestStreak = longest > habit.longestStreak ? longest : habit.longestStreak;
    await habit.save();
  }

  // ---------- Analytics ----------

  /// Completion rate (0.0-1.0) over the last [days] days for a habit.
  double completionRate(Habit habit, {int days = 30}) {
    final logs = {
      for (final l in getLogsForHabit(habit.id)) l.date: l,
    };
    final today = HabitLog.normalize(DateTime.now());
    int scheduledCount = 0;
    int completedCount = 0;
    for (int i = 0; i < days; i++) {
      final day = today.subtract(Duration(days: i));
      if (!habit.isScheduledFor(day)) continue;
      scheduledCount++;
      final log = logs[day];
      if (log?.completed ?? false) completedCount++;
    }
    if (scheduledCount == 0) return 0;
    return completedCount / scheduledCount;
  }

  /// Overall consistency score across all active habits.
  double overallConsistency({int days = 30}) {
    final habits = getAllHabits();
    if (habits.isEmpty) return 0;
    final total = habits.fold<double>(
      0,
      (sum, h) => sum + completionRate(h, days: days),
    );
    return total / habits.length;
  }
}
