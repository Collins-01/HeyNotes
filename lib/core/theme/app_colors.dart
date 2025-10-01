import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color lightBlue = Color(0xFFC2DCFD);
  static const Color pink = Color(0xFFFFD8F4);
  static const Color lightYellow = Color(0xFFFBF6AA);
  static const Color mintGreen = Color(0xFFB0E9CA);
  static const Color cream = Color(0xFFFCFAD9);
  static const Color lavender = Color(0xFFF1DBF5);
  static const Color periwinkle = Color(0xFFD9E8FC);
  static const Color lightCoral = Color(0xFFFFDBE3);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color darkGrey = Color(0xFF333333);
  static const Color mediumGrey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFFAFAFA);
  
  // Functional Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Background Colors for Notes
  static const List<Color> noteColors = [
    lightBlue,
    pink,
    lightYellow,
    mintGreen,
    cream,
    lavender,
    periwinkle,
    lightCoral,
  ];
  
  // Get a random note color
  static Color getRandomNoteColor() {
    return noteColors[DateTime.now().millisecondsSinceEpoch % noteColors.length];
  }
}
