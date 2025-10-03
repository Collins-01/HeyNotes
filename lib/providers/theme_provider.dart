import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hey_notes/core/theme/app_theme.dart';

enum AppThemeMode { system, light, dark }

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      state = ThemeMode.values[themeIndex];
    } catch (e) {
      // If there's an error loading the theme, default to system theme
      state = ThemeMode.system;
    }
  }

  /// Changes the current theme to the specified [theme]
  Future<void> setTheme(AppThemeMode theme) async {
    if ((theme == AppThemeMode.system && state == ThemeMode.system) ||
        (theme == AppThemeMode.light && state == ThemeMode.light) ||
        (theme == AppThemeMode.dark && state == ThemeMode.dark)) {
      return;
    }

    final newThemeMode = theme == AppThemeMode.system
        ? ThemeMode.system
        : (theme == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark);

    state = newThemeMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggles between light and dark theme
  void toggleTheme() {
    setTheme(state == ThemeMode.light ? AppThemeMode.dark : AppThemeMode.light);
  }

  /// Returns the current app theme mode
  AppThemeMode get currentThemeMode {
    if (state == ThemeMode.system) return AppThemeMode.system;
    return state == ThemeMode.light ? AppThemeMode.light : AppThemeMode.dark;
  }

  /// Returns the current theme data based on the current brightness
  ThemeData getThemeData(BuildContext context) {
    final brightness = state == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (state == ThemeMode.light ? Brightness.light : Brightness.dark);
    
    return brightness == Brightness.dark 
        ? AppTheme.darkTheme 
        : AppTheme.lightTheme;
  }

  /// Sets the theme mode (alias for setTheme for backward compatibility)
  void setThemeMode(AppThemeMode theme) {
    setTheme(theme);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
