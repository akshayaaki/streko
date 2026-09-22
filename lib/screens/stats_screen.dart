import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_icons.dart';
import '../widgets/empty_state.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsListProvider);
    final repo = ref.watch(habitRepositoryProvider);
    final overall = ref.watch(overallConsistencyProvider);

    if (habits.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.bar_chart_rounded,
          title: 'No data yet',
          subtitle: 'Create a habit and start checking in to see stats here.',
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Stats', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: overall,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        Text('${(overall * 100).round()}%',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Overall consistency', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Average completion rate across all habits, last 30 days',
                            style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('30-day completion by habit', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: 100,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 25),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= habits.length) return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(habitIconFromKey(habits[i].icon),
                                  size: 16, color: Color(habits[i].colorValue)),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    barGroups: habits.asMap().entries.map((entry) {
                      final i = entry.key;
                      final h = entry.value;
                      final rate = repo.completionRate(h, days: 30) * 100;
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: rate,
                            color: Color(h.colorValue),
                            width: 20,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Streaks', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...habits.map((h) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(habitIconFromKey(h.icon), color: Color(h.colorValue)),
                  title: Text(h.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text('${h.currentStreak}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 10),
                      Text('best ${h.longestStreak}', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
