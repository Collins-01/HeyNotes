import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
    state = ThemeMode.values[themeIndex];
  }

  Future<void> setTheme(AppThemeMode theme) async {
    if ((theme == AppThemeMode.system && state == ThemeMode.system) ||
        (theme == AppThemeMode.light && state == ThemeMode.light) ||
        (theme == AppThemeMode.dark && state == ThemeMode.dark)) {
      return;
    }

    state = theme == AppThemeMode.system
        ? ThemeMode.system
        : (theme == AppThemeMode.light ? ThemeMode.light : ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final appThemeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);

  final isDark =
      themeMode == ThemeMode.dark ||
      (themeMode == ThemeMode.system &&
          WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

  if (isDark) {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.blueGrey[800]!,
        secondary: Colors.blueGrey[600]!,
        surface: Colors.blueGrey[900]!,
        background: Colors.blueGrey[900]!,
      ),
      cardTheme: CardThemeData(
        color: Colors.blueGrey[800],
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } else {
    return ThemeData.light().copyWith(
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.lightBlue,
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
});
