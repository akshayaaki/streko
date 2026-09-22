import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/habit_providers.dart';
import '../models/habit_log.dart';
import '../theme.dart';

class DateStrip extends ConsumerStatefulWidget {
  const DateStrip({super.key});

  @override
  ConsumerState<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends ConsumerState<DateStrip> {
  late final ScrollController _scrollController;
  static const int _daysBack = 60;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: (_daysBack - 3) * 56.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDateProvider);
    final today = HabitLog.normalize(DateTime.now());

    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _daysBack + 1,
        itemBuilder: (context, i) {
          final date = today.subtract(Duration(days: _daysBack - i));
          final isSelected = date == selected;
          final isToday = date == today;
          return GestureDetector(
            onTap: () => ref.read(selectedDateProvider.notifier).state = date,
            child: Container(
              width: 48,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(color: AppColors.accent, width: 1.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
