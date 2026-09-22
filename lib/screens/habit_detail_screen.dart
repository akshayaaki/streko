import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/habit_providers.dart';
import '../models/habit_log.dart';
import '../widgets/habit_icons.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;
  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    ref.watch(habitsRefreshProvider);
    final repo = ref.read(habitRepositoryProvider);
    final habit = repo.getHabit(widget.habitId);

    if (habit == null) {
      return const Scaffold(body: Center(child: Text('Habit not found')));
    }

    final logs = {
      for (final l in repo.getLogsForHabit(habit.id)) l.date: l,
    };
    final color = Color(habit.colorValue);
    final rate30 = (repo.completionRate(habit, days: 30) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final controller = ref.read(habitControllerProvider);
              if (value == 'edit') {
                context.push('/habit-form?edit=${habit.id}');
              } else if (value == 'archive') {
                await controller.archiveHabit(habit.id);
                if (context.mounted) context.pop();
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete habit?'),
                    content: const Text('This removes all history for this habit. This can\'t be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await controller.deleteHabit(habit.id);
                  if (context.mounted) context.pop();
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'archive', child: Text('Archive')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(habitIconFromKey(habit.icon), color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  children: [
                    _StatBlock(label: 'Current', value: '${habit.currentStreak}', suffix: 'days'),
                    const SizedBox(width: 24),
                    _StatBlock(label: 'Longest', value: '${habit.longestStreak}', suffix: 'days'),
                    const SizedBox(width: 24),
                    _StatBlock(label: '30-day', value: '$rate30', suffix: '%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: habit.createdAt.subtract(const Duration(days: 1)),
                lastDay: DateTime.now().add(const Duration(days: 1)),
                focusedDay: _focusedDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarFormat: CalendarFormat.month,
                onPageChanged: (day) => setState(() => _focusedDay = day),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final normalized = HabitLog.normalize(day);
                    final log = logs[normalized];
                    final scheduled = habit.isScheduledFor(normalized);
                    return _dayCell(day, log, scheduled, color);
                  },
                  todayBuilder: (context, day, focusedDay) {
                    final normalized = HabitLog.normalize(day);
                    final log = logs[normalized];
                    final scheduled = habit.isScheduledFor(normalized);
                    return _dayCell(day, log, scheduled, color, isToday: true);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Notes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...logs.values
              .where((l) => l.note != null && l.note!.trim().isNotEmpty)
              .toList()
              .reversed
              .take(10)
              .map((l) => Card(
                    child: ListTile(
                      title: Text(l.note!),
                      subtitle: Text('${l.date.month}/${l.date.day}/${l.date.year}'),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime day, HabitLog? log, bool scheduled, Color color, {bool isToday = false}) {
    Color bg = Colors.transparent;
    if (scheduled) {
      if (log?.completed ?? false) {
        bg = color;
      } else if (log?.usedFreeze ?? false) {
        bg = color.withValues(alpha: 0.3);
      } else if (day.isBefore(DateTime.now())) {
        bg = Colors.grey.shade200;
      }
    }
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: color, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: (log?.completed ?? false) ? Colors.white : null,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  const _StatBlock({required this.label, required this.value, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$value $suffix', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
