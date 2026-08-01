import '../error.dart';
import '../result.dart';
import '../v.dart';
import '../v_code.dart';
import '../validation_mode.dart';
import '../validators/array/contains_all_validator.dart';
import '../validators/array/distinct_validator.dart';
import '../validators/array/max_length_list_validator.dart';
import '../validators/array/min_length_list_validator.dart';
import '../validators/array/unique_validator.dart';
import '../validators/bool/is_false_validator.dart';
import '../validators/bool/is_true_validator.dart';
import '../validators/date/after_today_validator.dart';
import '../validators/date/after_validator.dart';
import '../validators/date/age_validator.dart';
import '../validators/date/before_today_validator.dart';
import '../validators/date/before_validator.dart';
import '../validators/date/between_dates_validator.dart';
import '../validators/date/is_today_validator.dart';
import '../validators/date/same_day_as_validator.dart';
import '../validators/date/weekday_validator.dart';
import '../validators/date/weekend_validator.dart';
import '../validators/map/equal_fields_validator.dart';
import '../validators/number/between_validator.dart';
import '../validators/number/decimal_validator.dart';
import '../validators/number/even_validator.dart';
import '../validators/number/finite_validator.dart';
import '../validators/number/integer_double_validator.dart';
import '../validators/number/max_validator.dart';
import '../validators/number/min_validator.dart';
import '../validators/number/multiple_of_validator.dart';
import '../validators/number/negative_validator.dart';
import '../validators/number/odd_validator.dart';
import '../validators/number/positive_validator.dart';
import '../validators/number/prime_validator.dart';
import '../validators/object/equal_fields_validator.dart';
import '../validators/string/alpha_validator.dart';
import '../validators/string/alphanumeric_validator.dart';
import '../validators/string/base64_validator.dart';
import '../validators/string/card_brand_pattern.dart';
import '../validators/string/card_validator.dart';
import '../validators/string/contains_validator.dart';
import '../validators/string/cvv_validator.dart';
import '../validators/string/date_string_validator.dart';
import '../validators/string/domain_validator.dart';
import '../validators/string/email_validator.dart';
import '../validators/string/ends_with_validator.dart';
import '../validators/string/equals_validator.dart';
import '../validators/string/hex_color_validator.dart';
import '../validators/string/iban_validator.dart';
import '../validators/string/integer_string_validator.dart';
import '../validators/string/ip_validator.dart';
import '../validators/string/json_validator.dart';
import '../validators/string/jwt_validator.dart';
import '../validators/string/length_validator.dart';
import '../validators/string/license_plate_pattern.dart';
import '../validators/string/license_plate_validator.dart';
import '../validators/string/mac_validator.dart';
import '../validators/string/max_length_validator.dart';
import '../validators/string/min_length_validator.dart';
import '../validators/string/mongo_id_validator.dart';
import '../validators/string/nano_id_validator.dart';
import '../validators/string/not_empty_validator.dart';
import '../validators/string/numeric_string_validator.dart';
import '../validators/string/password_validator.dart';
import '../validators/string/pattern_validator.dart';
import '../validators/string/phone_pattern.dart';
import '../validators/string/phone_validator.dart';
import '../validators/string/postal_code_pattern.dart';
import '../validators/string/postal_code_validator.dart';
import '../validators/string/semver_validator.dart';
import '../validators/string/slug_validator.dart';
import '../validators/string/starts_with_validator.dart';
import '../validators/string/tax_id_pattern.dart';
import '../validators/string/tax_id_validator.dart';
import '../validators/string/time_validator.dart';
import '../validators/string/ulid_validator.dart';
import '../validators/string/url_validator.dart';
import '../validators/string/uuid_validator.dart';
import '../validators/validator.dart';

part 'array.dart';
part 'bool.dart';
part 'date.dart';
part 'enum.dart';
part 'literal.dart';
part 'map.dart';
part 'number.dart';
part 'object.dart';
part 'string.dart';
part 'transformed.dart';
part 'union.dart';

/// Controls when a [VMap.refineField], [VObject.refineField] or
/// [VObject.refineFieldRaw] callback runs in the container pipeline.
///
/// {@category Core}
///
/// - [RefineStage.post] (default): runs **after** every declared field has
///   been validated and transformed. Callback sees parsed values. Gated by
///   `dependsOn` — skipped when any declared dependency (including the
///   refine's own `path`) failed per-field validation.
/// - [RefineStage.pre]: runs **before** any per-field iteration. Callback
///   sees the input as it arrived (no preprocess / transforms applied).
///   Always runs once the type check passed; `dependsOn` is not accepted
///   (no field has been validated yet, so there is nothing to gate on).
///
/// Use [RefineStage.pre] for rules that depend on the raw input — original
/// casing, whitespace, pre-coercion shape. The classic case is a field
/// declared as `V.string().toLowerCase().email()` paired with a check that
/// must see the user's original casing.
///
/// See also:
///
///  * [VMap], which accepts a stage on its field-level refine.
///  * [VObject], which also exposes a raw-map refine for the same purpose.
enum RefineStage {
  /// Runs after per-field validation/transforms. Callback sees parsed
  /// values; `dependsOn` gates execution.
  post,

  /// Runs before any per-field iteration. Callback sees raw input;
  /// `dependsOn` is not accepted.
  pre,
}

/// Abstract base for all validation types.
///
/// {@category Core}
///
/// The pipeline executes in three phases:
///
/// 1. **Pre-processing** — transforms that clean or normalize the value
///    (e.g., `trim`, `toLowerCase`). Always runs before validation.
/// 2. **Validation** — validators that check constraints on the value
///    (e.g., `email`, `min`, `max`). Collects all errors.
/// 3. **Post-processing** — transforms that modify the validated value.
///    Only runs if validation passes.
///
/// ```dart
/// final schema = V.string()
///   ..trim()       // phase 1: pre-processing
///   ..email();     // phase 2: validation
/// ```
///
/// See also:
///
///  * [V], the entry point that creates every concrete schema.
///  * [VResult], what the safe-parse family returns.
///  * [Validator], the extension point for a custom rule.
abstract class VType<T> {
  /// Creates a [VType].
  ///
  /// - [message] overrides the default translation for the `required`
  ///   error when input is `null` and the schema is neither `nullable()`
  ///   nor has a `defaultValue`.
  /// - [invalidTypeMessage] overrides the default translation for the
  ///   `invalid_type` error when input is non-null but not assignable
  ///   to the schema's `T` (e.g. `42` against `V.string()`). When
  ///   `null`, the locale template (`'Expected {expected}, received
  ///   {received}'`) is used. Following Zod's `required_error` /
  ///   `invalid_type_error` separation: `required` is typically a
  ///   user-facing label, while `invalid_type` is a developer-facing
  ///   signal — keep them separate when the messages should differ.
  ///
  /// Both are independent of validator-level `message` arguments
  /// (`.email(message: ...)`, `.min(n, message: ...)`, ...) which
  /// customize errors *inside* the validation pipeline. The two factory
  /// arguments customize errors emitted *before* the pipeline runs.
  VType({String? message, String? invalidTypeMessage})
      : _message = message,
        _invalidTypeMessage = invalidTypeMessage;

  final List<_PipelineStep<T>> _steps = [];
  bool _isNullable = false;
  T? _defaultValue;
  bool _hasDefault = false;
  final String? _message;
  final String? _invalidTypeMessage;

  /// Optional coercion function to convert input to the expected type.
  T Function(Object value)? coercer;

  final List<Object? Function(Object?)> _preprocessors = [];
  final List<Future<Object?> Function(Object?)> _asyncPreprocessors = [];

  /// Type-specific prefix used to build error codes for `required` and
  /// `invalid_type`. Concrete subclasses return literals like `'string'`,
  /// `'int'`, `'bool'`. Wrappers delegate to the inner schema.
  ///
  /// Exposed so third-party schemas can plug into the prefixed-code
  /// mechanism — not intended for callers of existing schemas.
  String get typeName;

  /// Error code emitted when the value is `null` and the schema is not
  /// nullable and has no default.
  String get _requiredCode => '$typeName.required';

  /// Error code emitted when the value has the wrong runtime type.
  String get _invalidTypeCode => '$typeName.invalid_type';

  VType<T> _addStep(_PipelineStep<T> step) {
    _steps.add(step);
    return this;
  }

  /// Returns `true` if the pipeline contains any async step. When `true`,
  /// the synchronous consumers (`parse`, `validate`, `safeParse`, `errors`)
  /// throw [VAsyncRequiredException] and the caller must use the `*Async`
  /// variants instead.
  bool get hasAsync =>
      _asyncPreprocessors.isNotEmpty ||
      _steps.any((s) => s is _AsyncValidatorStep<T>);

  /// Returns `true` if `null` is accepted by this schema (set via [nullable]).
  bool get isNullable => _isNullable;

  /// Returns `true` if a default value was configured via [defaultValue].
  /// When `true`, [defaultValueOrNull] holds the configured value.
  bool get hasDefault => _hasDefault;

  /// The configured default value, or `null` when none was set.
  /// Check [hasDefault] first to distinguish "no default" from
  /// `defaultValue(null)` (which is nonsensical but allowed by the type).
  T? get defaultValueOrNull => _hasDefault ? _defaultValue : null;

  /// Returns `true` if at least one preprocessor (sync or async) was
  /// registered via [preprocess] / [preprocessAsync]. Useful for consumers
  /// that want to short-circuit a snapshot/preprocess step when there is
  /// nothing to run — e.g. `valiform`'s per-field validator only mounts
  /// the container preprocess closure when this is `true`.
  bool get hasPreprocessors =>
      _preprocessors.isNotEmpty || _asyncPreprocessors.isNotEmpty;

  /// Adds a [Validator] to the validation phase of the pipeline.
  ///
  /// Use [message] to override the default error message. Use [path] to
  /// attach the resulting error to a nested location instead of the root.
  /// Use [dependsOn] (only meaningful inside [VMap]/[VObject]) to declare
  /// which schema field keys this validator depends on; the validator is
  /// skipped only when one of those specific fields fails. When omitted,
  /// the conservative rule applies (skip on any field error).
  ///
  /// ```dart
  /// V.string().add(const EmailValidator(), message: 'Not a valid email');
  /// ```
  VType<T> add(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    return _addStep(
      _ValidatorStep<T>(
        validator,
        messageOverride: message,
        path: path,
        dependsOn: dependsOn,
      ),
    );
  }

  /// Adds a [Validator] that runs in the **raw** validation phase —
  /// before any per-field iteration in container schemas ([VMap] /
  /// [VObject]). The callback inside [validator] sees the input as it
  /// arrived (after container preprocess and type check), not the
  /// post-pipeline parsed value that [add] sees.
  ///
  /// Used by [VMap.refineField] with [RefineStage.pre] and by
  /// [VObject.refineFieldRaw]. Outside
  /// of container types this step never runs, so calling [addRaw] on a
  /// primitive schema is a no-op semantically (kept here for API
  /// uniformity).
  ///
  /// Use [message] to override the default error message. Use [path] to
  /// attach the resulting error to a field path instead of the root.
  /// There is no `dependsOn` parameter: raw validators run before any
  /// field has been validated, so there are no failures to gate on —
  /// they always execute when reached.
  VType<T> addRaw(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
  }) {
    return _addStep(
      _RawValidatorStep<T>(
        validator,
        messageOverride: message,
        path: path,
      ),
    );
  }

  /// Adds an [AsyncValidator] to the validation phase.
  ///
  /// Makes the schema async-only: sync consumers (`parse`, `validate`,
  /// `safeParse`, `errors`) will throw [VAsyncRequiredException]; use the
  /// `*Async` variants. See [add] for the meaning of [dependsOn].
  ///
  /// ```dart
  /// V.string().addAsync(const UsernameAvailableValidator());
  /// ```
  VType<T> addAsync(
    AsyncValidator<T> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    _addStep(
      _AsyncValidatorStep<T>(
        validate: validator.validate,
        code: validator.code,
        messageOverride: message,
        path: path,
        dependsOn: dependsOn,
      ),
    );

    return this;
  }

  /// Resolves null input against `_hasDefault` / `_isNullable`.
  ///
  /// Returns a record with `earlyReturn` (if the pipeline should return
  /// immediately — either with null for nullable, or a required error)
  /// and `input` (the effective input to continue with — either the
  /// original value or the substituted default).
  ({VResult<S?>? earlyReturn, Object? input}) _resolveNull<S>(
    S? defaultVal,
    bool hasDefault,
    Object? value,
  ) {
    if (value != null) return (earlyReturn: null, input: value);

    if (hasDefault) return (earlyReturn: null, input: defaultVal);

    if (_isNullable) {
      return (earlyReturn: VSuccess<S?>(null), input: null);
    }

    return (
      earlyReturn: VFailure<S?>([
        VError(
          code: _requiredCode,
          message: _message ?? V.t(_requiredCode),
        ),
      ]),
      input: null,
    );
  }

  VFailure<S?> _typeError<S>(String expected, Object value) {
    return VFailure<S?>([
      VError(
        code: _invalidTypeCode,
        message: _invalidTypeMessage ??
            V.t(_invalidTypeCode, {
              'expected': expected,
              'received': value.runtimeType.toString(),
            }),
      ),
    ]);
  }

  /// Parses [value] and returns the result, or throws a [VException] on
  /// failure.
  ///
  /// ```dart
  /// final name = V.string().min(2).parse('Jo'); // 'Jo'
  /// V.string().min(5).parse('Jo'); // throws VException
  /// ```
  T? parse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'parse',
        suggestion: 'parseAsync',
      );
    }

    final result = safeParse(value);

    if (result case VFailure(:final errors)) {
      throw VException(errors);
    }

    return (result as VSuccess<T?>).value;
  }

  /// Runs the synchronous preprocessor chain registered via [preprocess]
  /// against [value] and returns the result. Does NOT run `_resolveNull`,
  /// validators, or transforms — only the preprocess stage.
  ///
  /// Useful for consumers that need to mirror the schema's preprocess
  /// stage in their own scoped pipeline. For example, `valiform` calls
  /// this on a [VMap] / [VObject] to apply container-level preprocess
  /// before running per-field validators (matching the order
  /// [safeParse] uses internally).
  ///
  /// Throws [VAsyncRequiredException] when the schema has any async
  /// preprocessor — use [runPreprocessorsAsync] instead.
  ///
  /// ```dart
  /// final schema = V.string().preprocess((v) => (v as String).trim());
  /// schema.runPreprocessors('  hi  '); // 'hi'
  /// ```
  Object? runPreprocessors(Object? value) {
    if (_asyncPreprocessors.isNotEmpty) {
      throw const VAsyncRequiredException(
        methodName: 'runPreprocessors',
        suggestion: 'runPreprocessorsAsync',
      );
    }

    Object? input = value;

    for (final fn in _preprocessors) {
      input = fn(input);
    }

    return input;
  }

  /// Async variant of [runPreprocessors]: runs sync preprocessors first,
  /// then async preprocessors, in the order they were registered.
  ///
  /// ```dart
  /// final schema = V.string()
  ///   .preprocess((v) => (v as String).trim())
  ///   .preprocessAsync((v) async => (v as String).toLowerCase());
  /// await schema.runPreprocessorsAsync('  HI  '); // 'hi'
  /// ```
  Future<Object?> runPreprocessorsAsync(Object? value) async {
    Object? input = value;

    for (final fn in _preprocessors) {
      input = fn(input);
    }

    for (final fn in _asyncPreprocessors) {
      input = await fn(input);
    }

    return input;
  }

  /// Parses [value] and returns a [VResult] without throwing.
  ///
  /// Returns [VSuccess] with the parsed value, or [VFailure] with the list
  /// of errors.
  ///
  /// ```dart
  /// final result = V.string().email().safeParse('user@mail.com');
  ///
  /// switch (result) {
  ///   case VSuccess(:final value):
  ///     print(value);
  ///   case VFailure(:final errors):
  ///     print(errors);
  /// }
  /// ```
  VResult<T?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    Object? input = runPreprocessors(value);

    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, input);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    input = resolution.input;

    final T typed;

    if (coercer != null) {
      try {
        typed = coercer!(input!);
      } catch (_) {
        return _typeError<T>(T.toString(), input!);
      }
    } else {
      try {
        typed = input as T;
      } catch (_) {
        return _typeError<T>(T.toString(), input!);
      }
    }

    return _runPipeline(typed);
  }

  /// Async variant of [safeParse]. Use this when the schema has async
  /// validators (added via `refineAsync`).
  ///
  /// ```dart
  /// final result = await schema.safeParseAsync(value);
  /// ```
  Future<VResult<T?>> safeParseAsync(Object? value) async {
    Object? input = await runPreprocessorsAsync(value);

    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, input);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    input = resolution.input;

    final T typed;

    if (coercer != null) {
      try {
        typed = coercer!(input!);
      } catch (_) {
        return _typeError<T>(T.toString(), input!);
      }
    } else {
      try {
        typed = input as T;
      } catch (_) {
        return _typeError<T>(T.toString(), input!);
      }
    }

    return _runPipelineAsync(typed);
  }

  /// Async variant of [parse]. Throws [VException] on failure.
  ///
  /// ```dart
  /// final email = await schema.parseAsync('user@mail.com');
  /// ```
  Future<T?> parseAsync(Object? value) async {
    final result = await safeParseAsync(value);

    if (result case VFailure(:final errors)) {
      throw VException(errors);
    }

    return (result as VSuccess<T?>).value;
  }

  /// Async variant of [validate]. Returns `true` if the value passes.
  ///
  /// ```dart
  /// final ok = await schema.validateAsync('user@mail.com');
  /// ```
  Future<bool> validateAsync(Object? value) async =>
      (await safeParseAsync(value)).isValid;

  /// Async variant of [errors]. Returns the list of errors, or `null`
  /// when valid.
  ///
  /// ```dart
  /// final errs = await schema.errorsAsync('bad');
  /// if (errs != null) print(errs.first.message);
  /// ```
  Future<List<VError>?> errorsAsync(Object? value) async {
    final result = await safeParseAsync(value);

    if (result case VFailure(:final errors)) return errors;

    return null;
  }

  /// Runs every [_RawValidatorStep] registered on this schema against
  /// [input], returning the resulting [VError]s (if any). Used by
  /// container types (VMap, VObject) between the type check and the
  /// per-field iteration in `safeParse` / `safeParseAsync`.
  ///
  /// Always runs every registered raw step — raw validators have no
  /// `dependsOn` because they execute before any field can fail.
  List<VError> _runRawValidators(T input) {
    final errors = <VError>[];

    for (final step in _steps) {
      if (step
          case _RawValidatorStep<T>(
            :final validator,
            :final messageOverride,
            :final path,
          )) {
        final params = validator.validate(input);

        if (params != null) {
          final message = messageOverride ?? V.t(validator.code, params);
          errors.add(
            VError(
              code: validator.code,
              message: message,
              path: path ?? const [],
            ),
          );
        }
      }
    }

    return errors;
  }

  /// Runs the pipeline on [value]. Container types (VMap/VObject) pass
  /// [carriedErrors] (field-level errors already collected) and
  /// [failedFieldPaths] (the first-segment field names that failed) so
  /// entity-level validators with declared `dependsOn` can decide whether
  /// to skip. A validator without `dependsOn` is skipped if
  /// [failedFieldPaths] is non-empty (conservative legacy behavior).
  VResult<T?> _runPipeline(
    T value, {
    List<VError> carriedErrors = const [],
    Set<String> failedFieldPaths = const {},
  }) {
    T current = value;

    for (final step in _steps) {
      if (step case _PreTransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    final errors = <VError>[...carriedErrors];

    for (final step in _steps) {
      if (step
          case _ValidatorStep<T>(
            :final validator,
            :final messageOverride,
            :final path,
            :final dependsOn,
          )) {
        if (_shouldSkipForFailedFields(dependsOn, failedFieldPaths)) {
          continue;
        }

        final params = validator.validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(validator.code, params);
          errors.add(
            VError(
              code: validator.code,
              message: message,
              path: path ?? const [],
            ),
          );
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return VSuccess<T?>(current);
  }

  /// Async sibling of [_runPipeline]. See [_runPipeline] for the meaning
  /// of [carriedErrors] / [failedFieldPaths].
  Future<VResult<T?>> _runPipelineAsync(
    T value, {
    List<VError> carriedErrors = const [],
    Set<String> failedFieldPaths = const {},
  }) async {
    T current = value;

    for (final step in _steps) {
      if (step case _PreTransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    final errors = <VError>[...carriedErrors];

    for (final step in _steps) {
      if (step
          case _ValidatorStep<T>(
            :final validator,
            :final messageOverride,
            :final path,
            :final dependsOn,
          )) {
        if (_shouldSkipForFailedFields(dependsOn, failedFieldPaths)) {
          continue;
        }

        final params = validator.validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(validator.code, params);
          errors.add(
            VError(
              code: validator.code,
              message: message,
              path: path ?? const [],
            ),
          );
        }
      } else if (step
          case _AsyncValidatorStep<T>(
            :final validate,
            :final code,
            :final messageOverride,
            :final path,
            :final dependsOn,
          )) {
        if (_shouldSkipForFailedFields(dependsOn, failedFieldPaths)) {
          continue;
        }

        final params = await validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(code, params);
          errors.add(
            VError(
              code: code,
              message: message,
              path: path ?? const [],
            ),
          );
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return VSuccess<T?>(current);
  }

  /// Returns `true` when a step should be skipped because its declared
  /// dependencies (or, when none declared, ANY field) failed validation.
  /// This is the gate that lets `equalFields` / `refineField` (which
  /// declare `dependsOn`) run alongside unrelated field errors, while
  /// keeping generic `refine` (no `dependsOn`) conservative.
  static bool _shouldSkipForFailedFields(
    Set<String>? dependsOn,
    Set<String> failedFieldPaths,
  ) {
    if (failedFieldPaths.isEmpty) return false;
    if (dependsOn == null) return true;

    for (final dep in dependsOn) {
      if (failedFieldPaths.contains(dep)) return true;
    }

    return false;
  }

  /// Returns `true` if [value] passes all validations.
  ///
  /// ```dart
  /// V.string().email().validate('user@mail.com'); // true
  /// V.string().email().validate('invalid');        // false
  /// ```
  bool validate(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'validate',
        suggestion: 'validateAsync',
      );
    }

    return safeParse(value).isValid;
  }

  /// Maps this type through a generic function, preserving the inner type.
  R mapType<R>(R Function<U>(VType<U> type) fn) => fn<T>(this);

  /// Returns the list of [VError]s for [value], or `null` if valid.
  ///
  /// ```dart
  /// final errors = V.string().email().errors('invalid');
  /// // [VError(invalid_email: Invalid email address)]
  /// ```
  List<VError>? errors(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'errors',
        suggestion: 'errorsAsync',
      );
    }

    final result = safeParse(value);

    if (result case VFailure(:final errors)) return errors;

    return null;
  }

  /// Marks this schema as nullable, allowing `null` to pass validation.
  ///
  /// When combined with [defaultValue], the default value wins — `nullable`
  /// only applies when no default is set.
  ///
  /// ```dart
  /// V.string().nullable().parse(null); // null
  /// ```
  VType<T> nullable() {
    _isNullable = true;
    return this;
  }

  /// Sets a default value to use when the input is `null`.
  ///
  /// Takes precedence over [nullable]: if both are set, the default is
  /// returned on null input.
  ///
  /// ```dart
  /// V.string().defaultValue('N/A').parse(null); // 'N/A'
  /// ```
  VType<T> defaultValue(T value) {
    _defaultValue = value;
    _hasDefault = true;
    return this;
  }

  /// Applies a function to the raw input before type checking.
  ///
  /// Runs before everything else in the pipeline, including coercion and
  /// null checks. Multiple calls chain in the order they were added.
  ///
  /// ```dart
  /// V.string()
  ///   .preprocess((v) => (v as String?)?.trim())
  ///   .email()
  ///   .parse('  user@mail.com  '); // 'user@mail.com'
  /// ```
  VType<T> preprocess(Object? Function(Object? value) fn) {
    _preprocessors.add(fn);

    return this;
  }

  /// Async variant of [preprocess]. The function can return a [Future] —
  /// the raw input is transformed before type checking.
  ///
  /// Adding an async preprocessor makes the schema async-only.
  ///
  /// ```dart
  /// V.string().preprocessAsync((raw) async {
  ///   return await api.resolveAlias(raw as String);
  /// });
  /// ```
  VType<T> preprocessAsync(Future<Object?> Function(Object? value) fn) {
    _asyncPreprocessors.add(fn);

    return this;
  }

  /// Creates a [VTransformed] that converts the validated value to type [O].
  ///
  /// Runs in the post-processing phase, after all validations pass.
  ///
  /// ```dart
  /// final schema = V.string().transform<int>((v) => int.parse(v));
  /// schema.parse('42'); // 42
  /// ```
  VTransformed<T, O> transform<O>(O Function(T value) fn) =>
      VTransformed<T, O>(this, fn);

  /// Async variant of [transform]. The transform function returns a
  /// [Future] — the schema becomes async-only.
  ///
  /// ```dart
  /// final schema = V.string().uuid().transformAsync<User>(
  ///   (id) async => await db.loadUser(id),
  /// );
  /// await schema.parseAsync('550e8400-...'); // User
  /// ```
  VTransformedAsync<T, O> transformAsync<O>(
    Future<O> Function(T value) fn,
  ) =>
      VTransformedAsync<T, O>(this, fn);

  /// Adds a custom validation check.
  ///
  /// Runs in the validation phase. Returns an error if [check] returns
  /// `false`.
  ///
  /// ```dart
  /// V.string().refine(
  ///   (v) => v.contains('@'),
  ///   message: 'Must contain @',
  /// );
  /// ```
  VType<T> refine(
    bool Function(T value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    return add(
      _RefineValidator<T>(check: check, validatorCode: code ?? VCode.custom),
      message: message,
      dependsOn: dependsOn,
    );
  }

  /// Adds an async custom validation check.
  ///
  /// Runs in the validation phase. Returns an error if [check] completes
  /// with `false`. When [timeout] is provided, the check is bounded by
  /// that duration — exceeding it counts as a failure (same code/message
  /// as a regular `false` return).
  ///
  /// A schema with at least one `refineAsync` step becomes async-only —
  /// the sync consumers (`parse`, `validate`, `safeParse`, `errors`) will
  /// throw [VAsyncRequiredException]; use the `*Async` variants.
  ///
  /// ```dart
  /// V.string().email().refineAsync(
  ///   (email) async => !await db.emailExists(email),
  ///   message: 'Email already registered',
  ///   code: 'email_taken',
  ///   timeout: const Duration(seconds: 5),
  /// );
  /// ```
  VType<T> refineAsync(
    Future<bool> Function(T value) check, {
    String? message,
    String? code,
    Duration? timeout,
    Set<String>? dependsOn,
  }) {
    _addStep(
      _AsyncValidatorStep<T>(
        validate: (value) async {
          final future = check(value);
          final result = timeout != null
              ? await future.timeout(timeout, onTimeout: () => false)
              : await future;

          return result ? null : {};
        },
        code: code ?? VCode.custom,
        messageOverride: message,
        dependsOn: dependsOn,
      ),
    );

    return this;
  }

  VType<T> _preTransform(T Function(T value) fn) {
    _addStep(_PreTransformStep<T>(transform: fn));
    return this;
  }
}

class _NullableWrapper<T> extends VType<T> {
  _NullableWrapper(this._inner);
  final VType<T> _inner;

  @override
  String get typeName => _inner.typeName;

  @override
  bool get hasAsync => _inner.hasAsync;

  /// Mirrors `.nullable()` semantics: a non-null value runs the inner
  /// pipeline, and a null input is delegated to the inner whenever it
  /// already has its own null handling (`defaultValue` or `nullable`),
  /// so the default substitution / nullable short-circuit isn't
  /// silently bypassed. Otherwise the wrapper itself absorbs the null.
  @override
  VResult<T?> safeParse(Object? value) {
    if (value != null) return _inner.safeParse(value);

    if (_inner._hasDefault || _inner._isNullable) {
      return _inner.safeParse(value);
    }

    return VSuccess<T?>(null);
  }

  @override
  Future<VResult<T?>> safeParseAsync(Object? value) async {
    if (value != null) return _inner.safeParseAsync(value);

    if (_inner._hasDefault || _inner._isNullable) {
      return _inner.safeParseAsync(value);
    }

    return VSuccess<T?>(null);
  }
}

class _RefineValidator<T> extends Validator<T> {
  const _RefineValidator({
    required this.check,
    required this.validatorCode,
  });

  final bool Function(T value) check;
  final String validatorCode;

  @override
  String get code => validatorCode;

  @override
  Map<String, dynamic>? validate(T value) => check(value) ? null : {};
}

sealed class _PipelineStep<T> {
  const _PipelineStep();
}

final class _PreTransformStep<T> extends _PipelineStep<T> {
  const _PreTransformStep({required this.transform});

  final T Function(T value) transform;
}

final class _ValidatorStep<T> extends _PipelineStep<T> {
  const _ValidatorStep(
    this.validator, {
    this.messageOverride,
    this.path,
    this.dependsOn,
  });

  final Validator<T> validator;
  final String? messageOverride;
  final List<Object>? path;

  /// When non-null, this step is skipped if any field key in [dependsOn]
  /// is present in the container's `failedFieldPaths` set. When `null`
  /// (default), the conservative rule applies — the step is skipped if
  /// any field at all has failed.
  final Set<String>? dependsOn;
}

final class _AsyncValidatorStep<T> extends _PipelineStep<T> {
  const _AsyncValidatorStep({
    required this.validate,
    required this.code,
    this.messageOverride,
    this.path,
    this.dependsOn,
  });

  final Future<Map<String, dynamic>?> Function(T value) validate;
  final String code;
  final String? messageOverride;
  final List<Object>? path;

  /// See [_ValidatorStep.dependsOn].
  final Set<String>? dependsOn;
}

/// Validator step that runs **before** any per-field iteration in a
/// container schema ([VMap] / [VObject]). Receives the raw input —
/// after the container preprocess and type check, but before each
/// field's own pipeline (preprocess, validators, transforms) runs.
///
/// In contrast, [_ValidatorStep] runs inside `_runPipeline` after the
/// per-field iteration, so its callback sees parsed (post-pipeline)
/// values. Use [_RawValidatorStep] for entity-level rules that need to
/// inspect the original casing / whitespace / shape of the input
/// (e.g. comparing a field's raw value against an expected literal
/// before a `.toLowerCase()` transform changes it).
///
/// Always runs when reached — there are no per-field failures yet to
/// gate on, so [_RawValidatorStep] does not carry a `dependsOn` set.
final class _RawValidatorStep<T> extends _PipelineStep<T> {
  const _RawValidatorStep(
    this.validator, {
    this.messageOverride,
    this.path,
  });

  final Validator<T> validator;
  final String? messageOverride;
  final List<Object>? path;
}

/// Extracts the first path segment from each error in [errors] as a string,
/// dropping errors with empty paths. Used by container types ([VMap],
/// [VObject]) to compute the set of failed top-level field names that
/// `_runPipeline` consults to decide whether entity-level validators
/// (those declaring `dependsOn`) should run.
Set<String> _firstSegments(List<VError> errors) {
  final out = <String>{};

  for (final error in errors) {
    if (error.path.isEmpty) continue;
    out.add(error.path.first.toString());
  }

  return out;
}
