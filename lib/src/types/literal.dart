part of 'type.dart';

/// Validates that a value is exactly equal to the expected literal.
///
/// ```dart
/// final schema = V.literal('active');
/// schema.parse('active');   // 'active'
/// schema.parse('inactive'); // throws VException
/// ```
class VLiteral<T> extends VType<T> {
  final T _expected;

  /// Creates a literal validator that only accepts [_expected].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VLiteral(this._expected, {super.message});

  @override
  String get typeName => 'literal';

  @override
  VResult<T?> safeParse(Object? value) {
    Object? preprocessed = value;

    for (final fn in _preprocessors) {
      preprocessed = fn(preprocessed);
    }

    final resolution =
        _resolveNull<T>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input == _expected) {
      return VSuccess<T?>(_expected);
    }

    return VFailure<T?>([
      VError(
        code: VLiteralCode.invalid,
        message: V.t(VLiteralCode.invalid, {
          'expected': _expected,
          'received': input,
        }),
      ),
    ]);
  }
}
