import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFFFF6B35);
  static const accentSoft = Color(0xFFFFE8DC);
  static const habitPalette = <Color>[
    Color(0xFFFF6B35),
    Color(0xFF2EC4B6),
    Color(0xFF6C5CE7),
    Color(0xFFE84393),
    Color(0xFF00B894),
    Color(0xFFFDCB6E),
    Color(0xFF0984E3),
    Color(0xFFD63031),
  ];
}

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    brightness: Brightness.light,
  );
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Colors.black87,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    textTheme: base.textTheme.apply(fontFamily: 'Roboto'),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.accent,
    brightness: Brightness.dark,
  );
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
  );
}
