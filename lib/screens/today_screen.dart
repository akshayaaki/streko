import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/habit_providers.dart';
import '../models/habit_log.dart';
import '../widgets/habit_tile.dart';
import '../widgets/date_strip.dart';
import '../widgets/empty_state.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final habitsWithLogs = ref.watch(scheduledHabitsForDateProvider);
    final isToday =
        HabitLog.normalize(DateTime.now()) == selectedDate;

    final completedCount =
        habitsWithLogs.where((h) => h.log?.completed ?? false).length;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat('EEEE, MMM d').format(selectedDate),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                    ),
                    if (habitsWithLogs.isNotEmpty)
                      Text(
                        '$completedCount of ${habitsWithLogs.length} done',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const DateStrip(),
          const SizedBox(height: 8),
          Expanded(
            child: habitsWithLogs.isEmpty
                ? EmptyState(
                    icon: Icons.self_improvement_rounded,
                    title: 'Nothing scheduled',
                    subtitle: isToday
                        ? 'Tap + to create your first habit.'
                        : 'No habits were scheduled for this day.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: habitsWithLogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = habitsWithLogs[i];
                      return HabitTile(
                        habit: item.habit,
                        log: item.log,
                        date: selectedDate,
                        onTap: () => context.push('/habit/${item.habit.id}'),
                        onCheck: () {
                          final controller = ref.read(habitControllerProvider);
                          if (item.habit.targetCount != null) {
                            controller.incrementProgress(item.habit, selectedDate);
                          } else {
                            controller.toggleCompletion(item.habit, selectedDate);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
