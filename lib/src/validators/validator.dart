/// Abstract base class for all validators.
///
/// A validator checks a single constraint on a value of type [T] and returns
/// interpolation parameters on failure, or `null` on success.
///
/// ```dart
/// class MinValidator extends Validator<int> {
///   final int min;
///   const MinValidator({required this.min});
///
///   @override
///   String get code => 'number.too_small';
///
///   @override
///   Map<String, dynamic>? validate(int value) =>
///       value >= min ? null : {'min': min};
/// }
/// ```
abstract class Validator<T> {
  /// Creates a [Validator].
  const Validator();

  /// The error code used for locale translation lookup.
  String get code;

  /// Validates [value] and returns interpolation parameters on failure,
  /// or `null` on success.
  Map<String, dynamic>? validate(T value);
}

/// Abstract base class for async validators.
///
/// Like [Validator], but [validate] returns a [Future] — use this when
/// the check needs IO (database lookup, HTTP call, etc.).
///
/// Schemas that include an async validator become async-only: the
/// synchronous consumers (`parse`, `validate`, `safeParse`, `errors`)
/// throw `VAsyncRequiredException`; use the `*Async` variants.
///
/// ```dart
/// class UsernameAvailableValidator extends AsyncValidator<String> {
///   const UsernameAvailableValidator();
///
///   @override
///   String get code => 'username_taken';
///
///   @override
///   Future<Map<String, dynamic>?> validate(String value) async =>
///       (await db.usernameExists(value)) ? {} : null;
/// }
///
/// V.string().addAsync(const UsernameAvailableValidator());
/// ```
abstract class AsyncValidator<T> {
  /// Creates an [AsyncValidator].
  const AsyncValidator();

  /// The error code used for locale translation lookup.
  String get code;

  /// Validates [value] asynchronously. Returns `null` on success, or a
  /// map with interpolation parameters on failure.
  Future<Map<String, dynamic>?> validate(T value);
}
