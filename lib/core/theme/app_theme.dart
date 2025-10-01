import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Common theme properties
  static const _borderRadius = 12.0;
  static const _elevation = 1.0;
  static const _horizontalPadding = 16.0;
  static const _verticalPadding = 8.0;
  static const _buttonVerticalPadding = 16.0;
  static const _buttonHorizontalPadding = 24.0;
  static const _inputPadding = 16.0;

  // Color palette
  static const _primaryColor = Colors.blue;
  static const _secondaryColor = Colors.blueAccent;
  static const _errorColor = Colors.red;

  // Text theme
  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.poppinsTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textColor.withOpacity(0.87)),
        bodyMedium: TextStyle(fontSize: 14, color: textColor.withOpacity(0.87)),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Common theme data
  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color primaryColor,
    required ColorScheme colorScheme,
  }) {
    final isDark = brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      brightness: brightness,
      textTheme: _buildTextTheme(textColor),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: _elevation,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: _buildTextTheme(
          textColor,
        ).titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      // cardTheme: CardTheme(
      //   elevation: _elevation,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(_borderRadius),
      //   ),
      //   margin: const EdgeInsets.symmetric(
      //     horizontal: _horizontalPadding,
      //     vertical: _verticalPadding,
      //   ),
      //   color: colorScheme.surface,
      // ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
        contentPadding: const EdgeInsets.all(_inputPadding),
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: _buttonVerticalPadding,
            horizontal: _buttonHorizontalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: _buttonVerticalPadding - 4,
            horizontal: _buttonHorizontalPadding - 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          side: BorderSide(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: _buttonVerticalPadding - 8,
            horizontal: _buttonHorizontalPadding - 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.white24 : Colors.black12,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
    );

    return _baseTheme(
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      colorScheme: colorScheme,
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      secondary: _secondaryColor,
      error: _errorColor,
    );

    return _baseTheme(
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      colorScheme: colorScheme,
    );
  }
}
