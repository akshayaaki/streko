import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/habit_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(habitRepositoryProvider);
    final habits = repo.getAllHabits(includeArchived: true);

    final rows = <List<dynamic>>[
      ['habit', 'date', 'completed', 'progress_count', 'note'],
    ];
    for (final h in habits) {
      for (final log in repo.getLogsForHabit(h.id)) {
        rows.add([
          h.name,
          '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}-${log.date.day.toString().padLeft(2, '0')}',
          log.completed,
          log.progressCount,
          log.note ?? '',
        ]);
      }
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/streako_export.csv');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Streako habit export');
  }

  Future<void> _tryEnableAppLock(BuildContext context, WidgetRef ref, bool enable) async {
    if (!enable) {
      await ref.read(securitySettingsProvider.notifier).setAppLock(false);
      return;
    }
    final auth = LocalAuthentication();
    try {
      final canCheck = await auth.canCheckBiometrics || await auth.isDeviceSupported();
      if (!canCheck) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No biometrics/PIN available on this device')),
          );
        }
        return;
      }
      final didAuth = await auth.authenticate(
        localizedReason: 'Confirm to enable app lock',
      );
      if (didAuth) {
        await ref.read(securitySettingsProvider.notifier).setAppLock(true);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not verify biometrics')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final security = ref.watch(securitySettingsProvider);
    final archivedHabits = ref.watch(habitRepositoryProvider).getAllHabits(includeArchived: true)
        .where((h) => h.archived)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (m) {
                if (m != null) ref.read(themeModeProvider.notifier).setMode(m);
              },
              child: const Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text('System'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Light'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: Text('Dark'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Security', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('App lock'),
              subtitle: const Text('Require biometrics or device PIN to open'),
              value: security.appLockEnabled,
              onChanged: (v) => _tryEnableAppLock(context, ref, v),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ios_share_rounded),
              title: const Text('Export as CSV'),
              subtitle: const Text('Share your full habit history'),
              onTap: () => _exportData(context, ref),
            ),
          ),
          if (archivedHabits.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('Archived habits', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: archivedHabits
                    .map((h) => ListTile(
                          title: Text(h.name),
                          trailing: TextButton(
                            onPressed: () async {
                              h.archived = false;
                              await ref.read(habitRepositoryProvider).updateHabit(h);
                              ref.read(habitsRefreshProvider.notifier).state++;
                            },
                            child: const Text('Restore'),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 44,
                    height: 44,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Streako',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  'Build habits. Keep the flame alive.',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
