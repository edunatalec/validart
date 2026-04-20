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
  VLiteral(this._expected);

  @override
  VResult<T?> safeParse(Object? value) {
    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, value);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input == _expected) {
      return VSuccess<T?>(_expected);
    }

    return VFailure<T?>([
      VError(
        code: VCode.invalidLiteral,
        message: V.t(VCode.invalidLiteral, {
          'expected': _expected,
          'received': input,
        }),
      ),
    ]);
  }
}
