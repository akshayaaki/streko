import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'theme_mode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'light') state = ThemeMode.light;
    if (value == 'dark') state = ThemeMode.dark;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);

class SecuritySettings {
  final bool appLockEnabled;
  const SecuritySettings({this.appLockEnabled = false});
}

class SecuritySettingsController extends StateNotifier<SecuritySettings> {
  SecuritySettingsController() : super(const SecuritySettings()) {
    _load();
  }
  static const _key = 'app_lock_enabled';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SecuritySettings(appLockEnabled: prefs.getBool(_key) ?? false);
  }

  Future<void> setAppLock(bool enabled) async {
    state = SecuritySettings(appLockEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
  }
}

final securitySettingsProvider =
    StateNotifierProvider<SecuritySettingsController, SecuritySettings>(
  (ref) => SecuritySettingsController(),
);
