import 'package:flutter/material.dart';

/// Maps a stable string key (stored in Hive) to a Material icon.
/// Using string keys instead of raw codepoints keeps saved habits stable
/// across icon font/version changes.
const Map<String, IconData> habitIconMap = {
  'water': Icons.water_drop_rounded,
  'run': Icons.directions_run_rounded,
  'book': Icons.menu_book_rounded,
  'meditate': Icons.self_improvement_rounded,
  'sleep': Icons.bedtime_rounded,
  'gym': Icons.fitness_center_rounded,
  'food': Icons.restaurant_rounded,
  'code': Icons.code_rounded,
  'money': Icons.savings_rounded,
  'music': Icons.music_note_rounded,
  'walk': Icons.directions_walk_rounded,
  'journal': Icons.edit_note_rounded,
  'clean': Icons.cleaning_services_rounded,
  'phone_off': Icons.phonelink_erase_rounded,
  'sun': Icons.wb_sunny_rounded,
  'heart': Icons.favorite_rounded,
  'star': Icons.star_rounded,
  'default': Icons.check_circle_rounded,
};

IconData habitIconFromKey(String key) => habitIconMap[key] ?? habitIconMap['default']!;
