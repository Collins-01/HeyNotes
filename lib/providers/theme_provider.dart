import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hey_notes/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  static const String _key = 'theme_mode';

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_key);
    AppLogger.d("Theme mode loaded from prefs: $themeModeString");

    if (themeModeString != null) {
      state = _stringToThemeMode(themeModeString);
      AppLogger.d("Theme mode set to: $state");
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final themeMode = _appThemeModeToThemeMode(mode);
    state = themeMode;
    AppLogger.d("Theme mode set to: $themeMode");

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _themeModeToString(themeMode));
    AppLogger.d("Theme mode saved to prefs: ${prefs.getString(_key)}");
  }

  ThemeMode _appThemeModeToThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
    }
  }

  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  AppThemeMode getCurrentAppThemeMode() {
    switch (state) {
      case ThemeMode.system:
        return AppThemeMode.system;
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
