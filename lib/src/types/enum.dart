part of 'type.dart';

/// Validates that a value belongs to a set of enum values.
///
/// ```dart
/// enum Color { red, green, blue }
///
/// final schema = V.enm(Color.values);
/// schema.parse(Color.red); // Color.red
/// ```
class VEnum<T extends Enum> extends VType<T> {
  final List<T> _values;

  /// Creates an enum validator that accepts only the given [_values].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VEnum(this._values, {super.message});

  @override
  VResult<T?> safeParse(Object? value) {
    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, value);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is T && _values.contains(input)) {
      return _runPipeline(input);
    }

    return VFailure<T?>([
      VError(
        code: VCode.invalidEnum,
        message: V.t(VCode.invalidEnum, {
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
