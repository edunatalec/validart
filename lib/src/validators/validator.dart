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
