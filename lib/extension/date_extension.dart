import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  /// Returns the abbreviated day name (e.g., 'Mon', 'Tue', 'Wed', etc.)
  /// for the given DateTime object.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2025, 10, 2); // A Wednesday
  /// print(date.toDayStringValue); // Outputs: 'Wed'
  /// ```
  String get toDayStringValue {
    return DateFormat('E').format(this);
  }

  /// Returns the abbreviated month name (e.g., 'Jan', 'Feb', 'Mar', etc.)
  /// for the given DateTime object.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2025, 10, 2); // A Wednesday
  /// print(date.toMonthStringValue); // Outputs: 'Oct'
  /// ```
  String get toMonthStringValue {
    return DateFormat('MMM').format(this);
  }
}
