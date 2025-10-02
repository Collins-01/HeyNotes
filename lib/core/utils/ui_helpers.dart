import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../navigation/navigation_service.dart';

class UIHelpers {
  // Screen size helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;
  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double scaffoldPadding = 16.0;

  // Border radius
  static const double borderRadiusSm = 4.0;
  static const double borderRadiusMd = 8.0;
  static const double borderRadiusLg = 12.0;
  static const double borderRadiusXl = 16.0;

  // Animation durations
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 350);
  static const Duration slowDuration = Duration(milliseconds: 500);

  // Text styles
  static TextStyle? get headline1 =>
      const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
  static TextStyle? get headline2 =>
      const TextStyle(fontSize: 28, fontWeight: FontWeight.w600);
  static TextStyle? get headline3 =>
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static TextStyle? get headline4 =>
      const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static TextStyle? get bodyText1 => const TextStyle(fontSize: 16);
  static TextStyle? get bodyText2 => const TextStyle(fontSize: 14);
  static TextStyle? get caption => const TextStyle(fontSize: 12);

  // Edge insets
  static EdgeInsets edgeInsetsAll(double value) => EdgeInsets.all(value);
  static EdgeInsets edgeInsetsHorizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets edgeInsetsVertical(double value) =>
      EdgeInsets.symmetric(vertical: value);
  static EdgeInsets edgeInsetsOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Formatters
  static final currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final dateFormatter = DateFormat('MMM d, yyyy');
  static final timeFormatter = DateFormat('h:mm a');
  static final dateTimeFormatter = DateFormat('MMM d, yyyy h:mm a');

  // Keyboard utilities
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  // Copy to clipboard
  static Future<void> copyToClipboard(
    String text, {
    String? successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (successMessage != null) {
      showSuccessSnackBar(successMessage);
    }
  }

  // Snackbars
  static void showErrorSnackBar(String message) {
    final context = NavigationService.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  static void showSuccessSnackBar(String message) {
    final context = NavigationService.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  // Responsive layout helpers
  static bool isMobile(BuildContext context) => screenWidth(context) < 650;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= 650 && screenWidth(context) < 900;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= 900;

  // Device orientation
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
}
