/// A generic class that wraps a value to distinguish between a
/// provided `null` and an unprovided value. This is particularly
/// useful for `copyWith` methods to handle nullable fields correctly.
///
/// # Usage Examples
///
/// ## Basic Usage
/// ```dart
/// // Create an optional with a value (can be null)
/// final optionalWithValue = Optional.of('Hello');
/// final optionalWithNull = Optional.of<String>(null);
/// final optionalNone = Optional<String>.none();
///
/// // Check if has value
/// if (optionalWithValue.hasValue) {
///   // Get the value (returns null if no value)
///   final value = optionalWithValue.valueOrNull;
/// }
/// ```
///
/// ## With StateNotifier
/// ```dart
/// class MyState {
///   final String? name;
///   final int? age;
///   final Optional<String> message; // Using Optional for nullable field
///
///   MyState({
///     this.name,
///     this.age,
///     Optional<String>? message,
///   }) : message = message ?? Optional.none();
///
///   MyState copyWith({
///     String? name,
///     int? age,
///     Optional<String>? message, // Use Optional in copyWith
///   }) {
///     return MyState(
///       name: name ?? this.name,
///       age: age ?? this.age,
///       message: message ?? this.message,
///     );
///   }
/// }
///
/// class MyNotifier extends StateNotifier<MyState> {
///   MyNotifier() : super(MyState());
///
///   void updateName(String name) {
///     state = state.copyWith(name: name);
///   }
///
///   void clearMessage() {
///     // Set message to none (unset it)
///     state = state.copyWith(message: Optional.none());
///   }
///
///   void setMessage(String? message) {
///     // Set message (can be null)
///     state = state.copyWith(message: Optional.of(message));
///   }
/// }
/// ```
class Optional<T> {
  final T? _value;
  final bool _hasValue;

  /// Private constructor to ensure instances are created via the factory methods.
  const Optional._(this._value, this._hasValue);

  /// Creates an `Optional` with the given value.
  ///
  /// Use this when you want to wrap a value that could be null.
  /// ```dart
  /// final name = Optional.of('John');
  /// final noName = Optional.of<String>(null);
  /// ```
  factory Optional.of(T? value) => Optional._(value, true);

  /// Creates an empty `Optional` with no value.
  ///
  /// This is equivalent to `Optional.of(null)` but more explicit.
  /// ```dart
  /// final empty = Optional<String>.none();
  /// ```
  // factory Optional.none() => const Optional._(null, false);

  /// Creates an empty `Optional` with no value.
  ///
  /// Alias for [none()].
  factory Optional.empty() => const Optional._(null, false);

  /// A constant instance representing an unprovided value.
  static const Optional none = Optional._(null, false);

  /// Returns `true` if this `Optional` contains a value (even if that value is `null`).
  ///
  /// ```dart
  /// Optional.of('test').hasValue; // true
  /// Optional.of(null).hasValue;   // true
  /// Optional.none().hasValue;     // false
  /// ```
  bool get hasValue => _hasValue;

  /// Returns the wrapped value if it exists, otherwise returns `null`.
  ///
  /// ```dart
  /// Optional.of('test').valueOrNull; // 'test'
  /// Optional.of(null).valueOrNull;   // null
  /// Optional.none().valueOrNull;     // null
  /// ```
  T? get valueOrNull => _hasValue ? _value : null;

  /// Returns the wrapped value if it exists, otherwise returns [defaultValue].
  ///
  /// ```dart
  /// Optional.of('test').valueOr('default'); // 'test'
  /// Optional.none().valueOr('default');     // 'default'
  /// ```
  T valueOr(T defaultValue) =>
      _hasValue && _value != null ? _value : defaultValue;

  @override
  String toString() => _hasValue ? 'Optional.of($_value)' : 'Optional.none()';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Optional<T> &&
          runtimeType == other.runtimeType &&
          _hasValue == other._hasValue &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode ^ _hasValue.hashCode;
}
