part of 'type.dart';

/// Validates that a value matches at least one of the given schemas.
///
/// ```dart
/// final schema = V.union([V.string(), V.int()]);
/// schema.validate('hello'); // true
/// schema.validate(42);      // true
/// schema.validate(true);    // false
/// ```
///
/// See also:
///
///  * [V.union], the factory that creates this schema.
///  * [VUnionCode], the error codes it emits.
class VUnion extends VType<Object> {
  /// Creates a union validator that accepts values matching any of the
  /// [_options]. Must have at least 2 options.
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VUnion(this._options, {super.message, super.invalidTypeMessage}) {
    assert(_options.length >= 2, 'Union must have at least 2 options.');
  }
  final List<VType> _options;

  @override
  String get typeName => 'union';

  @override
  bool get hasAsync =>
      super.hasAsync || _options.any((option) => option.hasAsync);

  @override
  VResult<Object?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final Object? preprocessed = runPreprocessors(value);

    final resolution =
        _resolveNull<Object>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final optionErrors = <List<VError>>[];

    for (final option in _options) {
      final result = option.safeParse(input);

      if (result.isValid) return _runPipeline(input as Object);

      optionErrors.add((result as VFailure).errors);
    }

    return VFailure<Object?>([
      VError(
        code: VUnionCode.invalid,
        message: V.t(VUnionCode.invalid),
        context: optionErrors,
      ),
    ]);
  }

  @override
  Future<VResult<Object?>> safeParseAsync(Object? value) async {
    final Object? preprocessed = await runPreprocessorsAsync(value);

    final resolution =
        _resolveNull<Object>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final optionErrors = <List<VError>>[];

    for (final option in _options) {
      final result = option.hasAsync
          ? await option.safeParseAsync(input)
          : option.safeParse(input);

      if (result.isValid) return _runPipelineAsync(input as Object);

      optionErrors.add((result as VFailure).errors);
    }

    return VFailure<Object?>([
      VError(
        code: VUnionCode.invalid,
        message: V.t(VUnionCode.invalid),
        context: optionErrors,
      ),
    ]);
  }
}
