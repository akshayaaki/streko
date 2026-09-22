import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);

    // Android 13+ runtime permission.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Deterministic notification id from habitId + time string, so
  /// re-scheduling the same reminder overwrites rather than duplicates.
  int _notificationId(String habitId, String time) =>
      (habitId + time).hashCode & 0x7fffffff;

  Future<void> scheduleHabitReminders(Habit habit) async {
    // Clear existing reminders for this habit first.
    await cancelHabitReminders(habit);

    for (final timeStr in habit.reminderTimes) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final id = _notificationId(habit.id, timeStr);
      final scheduledTime = _nextInstanceOfTime(hour, minute);

      await _plugin.zonedSchedule(
        id,
        'Time for: ${habit.name}',
        _reminderBody(habit),
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit reminders',
            channelDescription: 'Reminders to complete your habits',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  String _reminderBody(Habit habit) {
    if (habit.currentStreak > 0) {
      return "Keep your ${habit.currentStreak}-day streak alive!";
    }
    return "Don't break the chain today.";
  }

  Future<void> cancelHabitReminders(Habit habit) async {
    for (final timeStr in habit.reminderTimes) {
      final id = _notificationId(habit.id, timeStr);
      await _plugin.cancel(id);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
