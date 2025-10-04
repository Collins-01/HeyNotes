import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);

      if (themeIndex != null && themeIndex < ThemeMode.values.length) {
        state = ThemeMode.values[themeIndex];
        AppLogger.d('Loaded theme: ${state.name}');
      }
    } catch (e) {
      AppLogger.e('Error loading theme: $e');
    }
  }

  /// Changes the current theme to the specified [theme]
  Future<void> setTheme(AppThemeMode theme) async {
    final newThemeMode = _appThemeToThemeMode(theme);

    if (state == newThemeMode) return;

    AppLogger.i('Changing theme to ${newThemeMode.name}');
    state = newThemeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      AppLogger.e('Failed to save theme: $e');
    }
  }

  /// Toggles between light and dark theme (ignores system mode)
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;

    await setTheme(newTheme);
  }

  /// Returns the current app theme mode
  AppThemeMode get currentThemeMode {
    return switch (state) {
      ThemeMode.system => AppThemeMode.system,
      ThemeMode.light => AppThemeMode.light,
      ThemeMode.dark => AppThemeMode.dark,
    };
  }

  /// Converts AppThemeMode to ThemeMode
  ThemeMode _appThemeToThemeMode(AppThemeMode theme) {
    return switch (theme) {
      AppThemeMode.system => ThemeMode.system,
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
    };
  }
}

// Provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});


