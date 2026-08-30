import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/preferences_service.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  PreferencesService? _prefs;

  ThemeModeNotifier() : super(ThemeMode.system) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await PreferencesService.create();
    final isDark = _prefs?.getThemeMode() == 'dark';
    if (_prefs?.getThemeMode() != null) {
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs?.setThemeMode(mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
