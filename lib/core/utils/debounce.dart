import 'dart:async';

import 'package:flutter/material.dart';

/// A utility class that provides debouncing functionality.
///
/// Debouncing is a programming practice used to ensure that time-consuming tasks
/// do not fire so often, which can cause performance issues.
///
/// Example usage:
/// ```dart
/// final debouncer = Debouncer(duration: const Duration(milliseconds: 500));
///
/// // In a text field's onChanged:
/// onChanged: (value) {
///   debouncer.run(() {
///     // Your search logic here
///     searchNotes(value);
///   });
/// }
/// ```
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Runs the given [callback] after the debounce duration has passed.
  /// If this method is called again before the duration has passed,
  /// the previous call will be canceled.
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  /// Cancels any pending debounced calls.
  void cancel() {
    _timer?.cancel();
  }

  /// Whether there is a pending debounced call.
  bool get isActive => _timer?.isActive ?? false;

  /// Disposes of the debouncer and cancels any pending timers.
  void dispose() {
    _timer?.cancel();
  }
}

/// Creates a debounced version of the given function.
///
/// Example:
/// ```dart
/// final debouncedSearch = debounce((String query) {
///   // Your search logic here
///   searchNotes(query);
/// }, duration: const Duration(milliseconds: 500));
///
/// // Use in text field:
/// onChanged: debouncedSearch;
/// ```
VoidCallback debounce(
  Function() callback, {
  Duration duration = const Duration(milliseconds: 300),
}) {
  Timer? timer;

  return () {
    timer?.cancel();
    timer = Timer(duration, callback);
  };
}
