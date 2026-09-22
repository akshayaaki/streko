import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'today_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import '../theme.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _screens = const [
    TodayScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              onPressed: () => context.push('/habit-form'),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline),
              selectedIcon: Icon(Icons.check_circle),
              label: 'Today'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Stats'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings'),
        ],
      ),
    );
  }
}
