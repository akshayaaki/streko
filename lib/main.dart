import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/habit_repository.dart';
import 'providers/habit_providers.dart';
import 'providers/settings_providers.dart';
import 'services/notification_service.dart';
import 'router.dart';
import 'theme.dart';
import 'screens/lock_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final repository = HabitRepository();
  await repository.init();

  final notificationService = NotificationService();
  await notificationService.init();

  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
      ],
      child: StreakoApp(showOnboarding: !onboardingComplete),
    ),
  );
}

class StreakoApp extends ConsumerStatefulWidget {
  final bool showOnboarding;
  const StreakoApp({super.key, required this.showOnboarding});

  @override
  ConsumerState<StreakoApp> createState() => _StreakoAppState();
}

class _StreakoAppState extends ConsumerState<StreakoApp> with WidgetsBindingObserver {
  late final GoRouter _router;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = buildRouter(showOnboarding: widget.showOnboarding);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final appLockEnabled = ref.read(securitySettingsProvider).appLockEnabled;
    if (state == AppLifecycleState.paused && appLockEnabled) {
      setState(() => _locked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Streako',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      routerConfig: _router,
      builder: (context, child) {
        if (_locked) {
          return LockScreen(onUnlocked: () => setState(() => _locked = false));
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
