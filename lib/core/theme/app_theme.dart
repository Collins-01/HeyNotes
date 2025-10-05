import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/theme/app_typography.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: AppTextStyles.textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.info,
        secondary: AppColors.mintGreen,
        surface: AppColors.white,
        background: AppColors.white, // <-- ADD THIS!
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.darkGrey,
        onSurface: AppColors.textBlack,
        onBackground: AppColors.textBlack, // <-- ADD THIS!
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.white,

      // CRITICAL: Disable Material 3 surface tinting globally
      applyElevationOverlayColor: false, // <-- ADD THIS!

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textBlack,
        surfaceTintColor: Colors.transparent, // <-- THIS FIXES THE MILKY COLOR!
      ),

      cardTheme: CardThemeData(
        color: AppColors.white,
        surfaceTintColor: Colors.transparent, // <-- THIS TOO!
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.info, width: 1),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),

      // Additional widgets that might show tinting
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent, // <-- For dialogs
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent, // <-- For drawers
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent, // <-- For bottom sheets
      ),
    );
  }

  static ThemeData darkTheme = ThemeData(
    iconTheme: const IconThemeData(size: 20),
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTextStyles.fontFamily,
    textTheme: AppTextStyles.textTheme,
    appBarTheme: const AppBarTheme(backgroundColor: AppColors.textBlack),
    scaffoldBackgroundColor: AppColors.textBlack,
    primaryColor: AppColors.info,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      onPrimary: AppColors.white,
      seedColor: AppColors.info,
      primary: AppColors.white,
      onSecondary: AppColors.white,
      error: AppColors.error,
      secondary: AppColors.mintGreen,
    ),
  );
}
