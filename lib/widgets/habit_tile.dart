import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import 'habit_icons.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final HabitLog? log;
  final DateTime date;
  final VoidCallback onTap;
  final VoidCallback onCheck;

  const HabitTile({
    super.key,
    required this.habit,
    required this.log,
    required this.date,
    required this.onTap,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final completed = log?.completed ?? false;
    final hasTarget = habit.targetCount != null;
    final progress = log?.progressCount ?? 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(habitIconFromKey(habit.icon), color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 14, color: Colors.orange.shade400),
                        const SizedBox(width: 2),
                        Text(
                          '${habit.currentStreak} day streak',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        if (hasTarget) ...[
                          const SizedBox(width: 8),
                          Text(
                            '· $progress/${habit.targetCount} ${habit.unit ?? ""}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onCheck,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: completed ? color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: completed ? color : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: completed
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
