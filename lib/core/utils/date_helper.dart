import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swift_alert/swift_alert.dart';

/// A helper class for handling date-related operations with platform-specific UIs.
class DateHelper {
  /// Shows a platform-appropriate date picker dialog.
  ///
  /// Returns the selected date, or null if the user cancels the dialog.
  static Future<DateTime?> showNativeDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? confirmText,
    String? cancelText,
    Color? backgroundColor,
    Color? textColor,
  }) async {
    final ThemeData theme = Theme.of(context);
    final bool isIOS = theme.platform == TargetPlatform.iOS;

    final DateTime effectiveInitialDate = initialDate ?? DateTime.now();
    final DateTime effectiveFirstDate = firstDate ?? DateTime(2000);
    final DateTime effectiveLastDate = lastDate ?? DateTime(2100);

    if (isIOS) {
      // iOS-style date picker
      DateTime? selectedDate = effectiveInitialDate;

      final result = await showModalBottomSheet<DateTime>(
        context: context,
        isScrollControlled: true,
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        cancelText ?? 'Cancel',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor ?? theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, selectedDate),
                      child: Text(
                        confirmText ?? 'Done',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 1),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: effectiveInitialDate,
                    minimumDate: effectiveFirstDate,
                    maximumDate: effectiveLastDate,
                    onDateTimeChanged: (DateTime newDate) {
                      selectedDate = newDate;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

      return result;
    } else {
      // Android-style date picker
      return await showDatePicker(
        context: context,
        initialDate: effectiveInitialDate,
        firstDate: effectiveFirstDate,
        lastDate: effectiveLastDate,
        builder: (context, child) {
          return Theme(
            data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                primary: theme.primaryColor,
                onPrimary: theme.colorScheme.onPrimary,
                surface: theme.cardColor,
                onSurface: textColor ?? theme.textTheme.bodyLarge?.color,
              ),
            ),
            child: child!,
          );
        },
      );
    }
  }

  /// Formats a DateTime object into a human-readable string.
  ///
  /// [date] - The date to format
  /// [format] - The format string (defaults to 'MMMM d, y')
  static String formatDate(DateTime date, {String format = 'MMMM d, y'}) {
    return DateFormat(format).format(date);
  }

  /// Shows a snackbar with the selected date information.
  ///
  /// [context] - The build context
  /// [date] - The selected date to display
  /// [message] - Optional custom message (will include date if not provided)
  /// [duration] - How long the snackbar should be displayed (defaults to 2 seconds)
  static void showDateSelectedSnackbar(
    BuildContext context, {
    required DateTime date,
    String? message,
    Duration duration = const Duration(seconds: 2),
  }) {
    if (context.mounted) {
      final formattedDate = formatDate(date);
      SwiftAlert.display(
        context,
        type: NotificationType.success,
        message: message ?? 'Selected date: $formattedDate',
      );
    }
  }
}
