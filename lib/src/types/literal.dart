part of 'type.dart';

/// Validates that a value is exactly equal to the expected literal.
///
/// ```dart
/// final schema = V.literal('active');
/// schema.parse('active');   // 'active'
/// schema.parse('inactive'); // throws VException
/// ```
class VLiteral<T> extends VType<T> {
  /// Creates a literal validator that only accepts [_expected].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VLiteral(this._expected, {super.message, super.invalidTypeMessage});

  final T _expected;

  @override
  String get typeName => 'literal';

  @override
  VResult<T?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final Object? preprocessed = runPreprocessors(value);

    final resolution =
        _resolveNull<T>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input == _expected) {
      return _runPipeline(_expected);
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
