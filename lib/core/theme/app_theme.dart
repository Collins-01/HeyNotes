import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Theme constants
  static const double _borderRadius = 12.0;
  static const double _elevation = 2.0;
  static const double _buttonVerticalPadding = 14.0;
  static const double _buttonHorizontalPadding = 20.0;
  static const double _inputPadding = 16.0;
  static const double _appBarElevation = 0.0;
  static const double _cardElevation = 1.0;

  // Text theme with Montserrat from Google Fonts
  static TextTheme _buildTextTheme() {
    final baseTextStyle = TextStyle(color: AppColors.textBlack);
    
    return GoogleFonts.montserratTextTheme(
      TextTheme(
        // Display styles
        displayLarge: baseTextStyle.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.5,
        ),
        displayMedium: baseTextStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.25,
          letterSpacing: -0.25,
        ),
        displaySmall: baseTextStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),

        // Headline styles
        headlineLarge: baseTextStyle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
        headlineMedium: baseTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineSmall: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.45,
        ),

        // Title styles
        titleLarge: baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
        titleMedium: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.1,
        ),

        // Body styles
        bodyLarge: baseTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        bodyMedium: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.25,
        ),
        bodySmall: baseTextStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.4,
        ),

        // Label styles
        labelLarge: baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.5,
          letterSpacing: 0.5,
        ),
      ).apply(
        fontFamily: 'Avenir',
        displayColor: AppColors.black,
        bodyColor: AppColors.darkGrey,
      ),
    );
  }

  // Common theme data
  static ThemeData _baseTheme({
    required Color primaryColor,
    required ColorScheme colorScheme,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
      canvasColor: isDark ? AppColors.darkGrey : AppColors.white,
      cardColor: isDark ? const Color(0xFF1E1E1E) : AppColors.white,

      // Text Theme
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: _appBarElevation,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.black,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.white : AppColors.black,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: _cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: _inputPadding,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : AppColors.lightGrey,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : AppColors.lightGrey,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.0),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.grey[500] : AppColors.mediumGrey,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.grey[400] : AppColors.mediumGrey,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            vertical: _buttonVerticalPadding,
            horizontal: _buttonHorizontalPadding,
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
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
          side: BorderSide(
            color: isDark ? Colors.grey[700]! : AppColors.lightGrey,
            width: 1.5,
          ),
          foregroundColor: isDark ? AppColors.white : AppColors.darkGrey,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            vertical: _buttonVerticalPadding - 8,
            horizontal: _buttonHorizontalPadding - 8,
          ),
          foregroundColor: primaryColor,
          textStyle: textTheme.labelLarge?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey[800] : AppColors.lightGrey,
        thickness: 1,
        space: 1,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.white,
        elevation: _elevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius * 2),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkGrey : AppColors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? Colors.grey[500] : AppColors.mediumGrey,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? Colors.grey[800]! : const Color(0xFFF5F5F5),
        disabledColor: isDark ? Colors.grey[800]! : AppColors.lightGrey,
        selectedColor: primaryColor.withOpacity(0.2),
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.white : AppColors.darkGrey,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: AppColors.white,
        ),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }

  // Light theme
  static ThemeData get lightTheme => _baseTheme(
    primaryColor: AppColors.lightBlue,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightBlue,
      secondary: AppColors.mintGreen,
      surface: AppColors.white,
      surfaceContainerHighest: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.darkGrey,
      onSecondary: AppColors.darkGrey,
      onSurface: AppColors.darkGrey,
      onSurfaceVariant: AppColors.darkGrey,
      onError: AppColors.white,
      brightness: Brightness.light,
    ),
  );

  // Dark theme
  static ThemeData get darkTheme => _baseTheme(
    primaryColor: AppColors.periwinkle,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.periwinkle,
      secondary: AppColors.mintGreen,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: Color(0xFFFF8A80),
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.white,
      onBackground: AppColors.white,
      onError: AppColors.black,
      brightness: Brightness.dark,
    ),
  );
}
