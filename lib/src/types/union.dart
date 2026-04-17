part of 'type.dart';

/// Validates that a value matches at least one of the given schemas.
///
/// ```dart
/// final schema = V.union([V.string(), V.int()]);
/// schema.validate('hello'); // true
/// schema.validate(42);      // true
/// schema.validate(true);    // false
/// ```
class VUnion extends VType<Object> {
  final List<VType> _options;

  /// Creates a union validator that accepts values matching any of the
  /// [_options]. Must have at least 2 options.
  VUnion(this._options) {
    assert(_options.length >= 2, 'Union must have at least 2 options.');
  }

  @override
  VResult<Object?> safeParse(Object? value) {
    final nullResult = _nullCheck<Object>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

    final optionErrors = <List<VError>>[];

    for (final option in _options) {
      final result = option.safeParse(value);

      if (result.isValid) return VSuccess<Object?>(value);

      optionErrors.add((result as VFailure).errors);
    }

    return VFailure<Object?>([
      VError(
        code: VCode.invalidUnion,
        message: V.t(VCode.invalidUnion),
        context: optionErrors,
      ),
    ]);
  }
}
