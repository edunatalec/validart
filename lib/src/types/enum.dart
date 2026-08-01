part of 'type.dart';

/// Validates that a value belongs to a set of enum values.
///
/// {@category Types}
///
/// ```dart
/// enum Color { red, green, blue }
///
/// final schema = V.enm(Color.values);
/// schema.parse(Color.red); // Color.red
/// ```
///
/// See also:
///
///  * [V.enm], the factory that creates this schema.
///  * [VEnumCode], the error codes it emits.
///  * [VLiteral], for a fixed value that is not an enum member.
class VEnum<T extends Enum> extends VType<T> {
  /// Creates an enum validator that accepts only the given [_values].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VEnum(this._values, {super.message, super.invalidTypeMessage});

  final List<T> _values;

  @override
  String get typeName => 'enum';

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

    if (input is T && _values.contains(input)) {
      return _runPipeline(input);
    }

    return VFailure<T?>([
      VError(
        code: VEnumCode.invalid,
        message: V.t(VEnumCode.invalid, {
          'values': _values.map((v) => v.name).join(', '),
        }),
      ),
    ]);
  }

  /// Creates a [VArray] schema that validates a `List<T>`.
  ///
  /// ```dart
  /// V.enm(Color.values).array().parse([Color.red, Color.blue]);
  /// ```
  VArray<T> array() => VArray<T>(this);
}
