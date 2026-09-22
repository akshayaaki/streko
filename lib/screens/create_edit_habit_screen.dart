import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../theme.dart';
import '../widgets/habit_icons.dart';

class CreateEditHabitScreen extends ConsumerStatefulWidget {
  final String? editHabitId;
  const CreateEditHabitScreen({super.key, this.editHabitId});

  @override
  ConsumerState<CreateEditHabitScreen> createState() => _CreateEditHabitScreenState();
}

class _CreateEditHabitScreenState extends ConsumerState<CreateEditHabitScreen> {
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();

  String _iconKey = 'default';
  Color _color = AppColors.habitPalette.first;
  HabitFrequency _frequency = HabitFrequency.daily;
  Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  int _timesPerWeek = 3;
  bool _hasTarget = false;
  final List<TimeOfDay> _reminders = [];

  Habit? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.editHabitId != null) {
      final repo = ref.read(habitRepositoryProvider);
      _existing = repo.getHabit(widget.editHabitId!);
      if (_existing != null) {
        final h = _existing!;
        _nameController.text = h.name;
        _iconKey = h.icon;
        _color = Color(h.colorValue);
        _frequency = h.frequency;
        _weekdays = h.activeWeekdays.toSet();
        _timesPerWeek = h.timesPerWeekTarget;
        _hasTarget = h.targetCount != null;
        if (h.targetCount != null) _targetController.text = h.targetCount.toString();
        if (h.unit != null) _unitController.text = h.unit!;
        _reminders.addAll(h.reminderTimes.map((t) {
          final parts = t.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _reminders.add(time));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give your habit a name')),
      );
      return;
    }

    final controller = ref.read(habitControllerProvider);
    final reminderStrings = _reminders.map(_formatTime).toList();
    final targetCount = _hasTarget ? int.tryParse(_targetController.text) : null;

    if (_existing != null) {
      final h = _existing!;
      h.name = _nameController.text.trim();
      h.icon = _iconKey;
      h.colorValue = _color.toARGB32();
      h.frequency = _frequency;
      h.activeWeekdays = _weekdays.toList();
      h.timesPerWeekTarget = _timesPerWeek;
      h.targetCount = targetCount;
      h.unit = _hasTarget ? _unitController.text.trim() : null;
      h.reminderTimes = reminderStrings;
      await controller.updateHabit(h);
    } else {
      await controller.createHabit(
        name: _nameController.text.trim(),
        icon: _iconKey,
        colorValue: _color.toARGB32(),
        frequency: _frequency,
        activeWeekdays: _weekdays.toList(),
        timesPerWeekTarget: _timesPerWeek,
        targetCount: targetCount,
        unit: _hasTarget ? _unitController.text.trim() : null,
        reminderTimes: reminderStrings,
      );
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing != null ? 'Edit habit' : 'New habit'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Habit name',
              hintText: 'e.g. Drink water',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: habitIconMap.entries.map((entry) {
              final selected = entry.key == _iconKey;
              return GestureDetector(
                onTap: () => setState(() => _iconKey = entry.key),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: selected ? _color.withValues(alpha: 0.2) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: _color, width: 2) : null,
                  ),
                  child: Icon(entry.value, color: selected ? _color : Colors.grey.shade600),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: AppColors.habitPalette.map((c) {
              final selected = c.toARGB32() == _color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: Colors.black, width: 2) : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<HabitFrequency>(
            segments: const [
              ButtonSegment(value: HabitFrequency.daily, label: Text('Daily')),
              ButtonSegment(value: HabitFrequency.specificDays, label: Text('Specific days')),
              ButtonSegment(value: HabitFrequency.timesPerWeek, label: Text('X / week')),
            ],
            selected: {_frequency},
            onSelectionChanged: (s) => setState(() => _frequency = s.first),
          ),
          if (_frequency == HabitFrequency.specificDays) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final selected = _weekdays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _weekdays.remove(day);
                    } else {
                      _weekdays.add(day);
                    }
                  }),
                  child: CircleAvatar(
                    backgroundColor: selected ? _color : Colors.grey.shade200,
                    child: Text(labels[i],
                        style: TextStyle(color: selected ? Colors.white : Colors.black87)),
                  ),
                );
              }),
            ),
          ],
          if (_frequency == HabitFrequency.timesPerWeek) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Times per week:'),
                Expanded(
                  child: Slider(
                    value: _timesPerWeek.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: '$_timesPerWeek',
                    activeColor: _color,
                    onChanged: (v) => setState(() => _timesPerWeek = v.round()),
                  ),
                ),
                Text('$_timesPerWeek'),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Track a numeric target', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('e.g. 8 glasses, 30 pages'),
            value: _hasTarget,
            activeThumbColor: _color,
            onChanged: (v) => setState(() => _hasTarget = v),
          ),
          if (_hasTarget) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Target', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reminders', style: TextStyle(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: _pickReminderTime,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          ..._reminders.asMap().entries.map((entry) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined),
              title: Text(entry.value.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _reminders.removeAt(entry.key)),
              ),
            );
          }),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
