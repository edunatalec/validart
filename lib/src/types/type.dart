import 'package:validart/src/error.dart';
import 'package:validart/src/result.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_code.dart';
import 'package:validart/src/validation_mode.dart';
import 'package:validart/src/validators/array/contains_all_validator.dart';
import 'package:validart/src/validators/array/max_length_list_validator.dart';
import 'package:validart/src/validators/array/min_length_list_validator.dart';
import 'package:validart/src/validators/array/unique_validator.dart';
import 'package:validart/src/validators/bool/is_false_validator.dart';
import 'package:validart/src/validators/map/equal_fields_validator.dart';
import 'package:validart/src/validators/object/equal_fields_validator.dart';
import 'package:validart/src/validators/bool/is_true_validator.dart';
import 'package:validart/src/validators/date/after_validator.dart';
import 'package:validart/src/validators/date/age_validator.dart';
import 'package:validart/src/validators/date/before_validator.dart';
import 'package:validart/src/validators/date/between_dates_validator.dart';
import 'package:validart/src/validators/date/weekday_validator.dart';
import 'package:validart/src/validators/date/weekend_validator.dart';
import 'package:validart/src/validators/number/between_validator.dart';
import 'package:validart/src/validators/number/decimal_validator.dart';
import 'package:validart/src/validators/number/even_validator.dart';
import 'package:validart/src/validators/number/finite_validator.dart';
import 'package:validart/src/validators/number/integer_double_validator.dart';
import 'package:validart/src/validators/number/max_validator.dart';
import 'package:validart/src/validators/number/min_validator.dart';
import 'package:validart/src/validators/number/multiple_of_validator.dart';
import 'package:validart/src/validators/number/negative_validator.dart';
import 'package:validart/src/validators/number/odd_validator.dart';
import 'package:validart/src/validators/number/positive_validator.dart';
import 'package:validart/src/validators/number/prime_validator.dart';
import 'package:validart/src/validators/string/alpha_validator.dart';
import 'package:validart/src/validators/string/alphanumeric_validator.dart';
import 'package:validart/src/validators/string/base64_validator.dart';
import 'package:validart/src/validators/string/card_brand_pattern.dart';
import 'package:validart/src/validators/string/card_validator.dart';
import 'package:validart/src/validators/string/contains_validator.dart';
import 'package:validart/src/validators/string/cvv_validator.dart';
import 'package:validart/src/validators/string/date_string_validator.dart';
import 'package:validart/src/validators/string/email_validator.dart';
import 'package:validart/src/validators/string/ends_with_validator.dart';
import 'package:validart/src/validators/string/equals_validator.dart';
import 'package:validart/src/validators/string/hex_color_validator.dart';
import 'package:validart/src/validators/string/iban_validator.dart';
import 'package:validart/src/validators/string/integer_string_validator.dart';
import 'package:validart/src/validators/string/ip_validator.dart';
import 'package:validart/src/validators/string/json_validator.dart';
import 'package:validart/src/validators/string/jwt_validator.dart';
import 'package:validart/src/validators/string/length_validator.dart';
import 'package:validart/src/validators/string/license_plate_pattern.dart';
import 'package:validart/src/validators/string/license_plate_validator.dart';
import 'package:validart/src/validators/string/mac_validator.dart';
import 'package:validart/src/validators/string/max_length_validator.dart';
import 'package:validart/src/validators/string/min_length_validator.dart';
import 'package:validart/src/validators/string/mongo_id_validator.dart';
import 'package:validart/src/validators/string/nano_id_validator.dart';
import 'package:validart/src/validators/string/not_empty_validator.dart';
import 'package:validart/src/validators/string/numeric_string_validator.dart';
import 'package:validart/src/validators/string/password_validator.dart';
import 'package:validart/src/validators/string/pattern_validator.dart';
import 'package:validart/src/validators/string/phone_pattern.dart';
import 'package:validart/src/validators/string/phone_validator.dart';
import 'package:validart/src/validators/string/postal_code_pattern.dart';
import 'package:validart/src/validators/string/postal_code_validator.dart';
import 'package:validart/src/validators/string/semver_validator.dart';
import 'package:validart/src/validators/string/slug_validator.dart';
import 'package:validart/src/validators/string/starts_with_validator.dart';
import 'package:validart/src/validators/string/tax_id_pattern.dart';
import 'package:validart/src/validators/string/tax_id_validator.dart';
import 'package:validart/src/validators/string/time_validator.dart';
import 'package:validart/src/validators/string/ulid_validator.dart';
import 'package:validart/src/validators/string/url_validator.dart';
import 'package:validart/src/validators/string/uuid_validator.dart';
import 'package:validart/src/validators/validator.dart';

part 'string.dart';
part 'bool.dart';
part 'number.dart';
part 'date.dart';
part 'array.dart';
part 'map.dart';
part 'object.dart';
part 'enum.dart';
part 'literal.dart';
part 'union.dart';
part 'transformed.dart';

/// Abstract base for all validation types.
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
abstract class VType<T> {
  /// Creates a [VType]. [message] overrides the default translation for
  /// the `required` error when input is `null` and the schema is neither
  /// `nullable()` nor has a `defaultValue`.
  ///
  /// Not to be confused with the `message` parameter on individual
  /// validator methods (`.email(message: ...)`, `.min(n, message: ...)`,
  /// `.refine(fn, message: ...)`, ...): that one customizes the error of
  /// a specific validator inside the pipeline; this one customizes the
  /// pre-validation `required` error fired by `_resolveNull`. Both can
  /// coexist on the same schema.
  VType({String? message}) : _message = message;

  final List<_PipelineStep<T>> _steps = [];
  bool _isNullable = false;
  T? _defaultValue;
  bool _hasDefault = false;
  final String? _message;

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

  /// Adds a [Validator] to the validation phase of the pipeline.
  ///
  /// Use [message] to override the default error message. Use [path] to
  /// attach the resulting error to a nested location instead of the root.
  ///
  /// ```dart
  /// V.string().add(const EmailValidator(), message: 'Not a valid email');
  /// ```
  VType<T> add(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
  }) {
    return _addStep(_ValidatorStep<T>(
      validator,
      messageOverride: message,
      path: path,
    ));
  }

  /// Adds an [AsyncValidator] to the validation phase.
  ///
  /// Makes the schema async-only: sync consumers (`parse`, `validate`,
  /// `safeParse`, `errors`) will throw `VAsyncRequiredException`; use the
  /// `*Async` variants.
  ///
  /// ```dart
  /// V.string().addAsync(const UsernameAvailableValidator());
  /// ```
  VType<T> addAsync(
    AsyncValidator<T> validator, {
    String? message,
    List<Object>? path,
  }) {
    _addStep(_AsyncValidatorStep<T>(
      validate: validator.validate,
      code: validator.code,
      messageOverride: message,
      path: path,
    ));

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
        message: V.t(_invalidTypeCode, {
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

    Object? input = value;

    for (final fn in _preprocessors) {
      input = fn(input);
    }

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
    Object? input = value;

    for (final fn in _preprocessors) {
      input = fn(input);
    }

    for (final fn in _asyncPreprocessors) {
      input = await fn(input);
    }

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

  VResult<T?> _runPipeline(T value) {
    T current = value;

    for (final step in _steps) {
      if (step case _PreTransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    final errors = <VError>[];

    for (final step in _steps) {
      if (step
          case _ValidatorStep<T>(
            :final validator,
            :final messageOverride,
            :final path
          )) {
        final params = validator.validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(validator.code, params);
          errors.add(VError(
            code: validator.code,
            message: message,
            path: path ?? const [],
          ));
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    for (final step in _steps) {
      if (step case _TransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    return VSuccess<T?>(current);
  }

  Future<VResult<T?>> _runPipelineAsync(T value) async {
    T current = value;

    for (final step in _steps) {
      if (step case _PreTransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    final errors = <VError>[];

    for (final step in _steps) {
      if (step
          case _ValidatorStep<T>(
            :final validator,
            :final messageOverride,
            :final path
          )) {
        final params = validator.validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(validator.code, params);
          errors.add(VError(
            code: validator.code,
            message: message,
            path: path ?? const [],
          ));
        }
      } else if (step
          case _AsyncValidatorStep<T>(
            :final validate,
            :final code,
            :final messageOverride,
            :final path
          )) {
        final params = await validate(current);

        if (params != null) {
          final message = messageOverride ?? V.t(code, params);
          errors.add(VError(
            code: code,
            message: message,
            path: path ?? const [],
          ));
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    for (final step in _steps) {
      if (step case _TransformStep<T>(:final transform)) {
        current = transform(current);
      }
    }

    return VSuccess<T?>(current);
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
  }) {
    return add(
      _RefineValidator<T>(check: check, validatorCode: code ?? VCode.custom),
      message: message,
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
  }) {
    _addStep(_AsyncValidatorStep<T>(
      validate: (value) async {
        final future = check(value);
        final result = timeout != null
            ? await future.timeout(timeout, onTimeout: () => false)
            : await future;

        return result ? null : {};
      },
      code: code ?? VCode.custom,
      messageOverride: message,
    ));

    return this;
  }

  VType<T> _preTransform(T Function(T value) fn) {
    _addStep(_PreTransformStep<T>(transform: fn));
    return this;
  }
}

class _NullableWrapper<T> extends VType<T> {
  final VType<T> _inner;

  _NullableWrapper(this._inner);

  @override
  String get typeName => _inner.typeName;

  @override
  VResult<T?> safeParse(Object? value) {
    if (value == null) return VSuccess<T?>(null);

    return _inner.safeParse(value);
  }
}

class _RefineValidator<T> extends Validator<T> {
  final bool Function(T value) check;
  final String validatorCode;

  const _RefineValidator({
    required this.check,
    required this.validatorCode,
  });

  @override
  String get code => validatorCode;

  @override
  Map<String, dynamic>? validate(T value) => check(value) ? null : {};
}

sealed class _PipelineStep<T> {
  const _PipelineStep();
}

final class _PreTransformStep<T> extends _PipelineStep<T> {
  final T Function(T value) transform;

  const _PreTransformStep({required this.transform});
}

final class _ValidatorStep<T> extends _PipelineStep<T> {
  final Validator<T> validator;
  final String? messageOverride;
  final List<Object>? path;

  const _ValidatorStep(this.validator, {this.messageOverride, this.path});
}

final class _AsyncValidatorStep<T> extends _PipelineStep<T> {
  final Future<Map<String, dynamic>?> Function(T value) validate;
  final String code;
  final String? messageOverride;
  final List<Object>? path;

  const _AsyncValidatorStep({
    required this.validate,
    required this.code,
    this.messageOverride,
    this.path,
  });
}

final class _TransformStep<T> extends _PipelineStep<T> {
  final T Function(T value) transform;

  const _TransformStep({required this.transform});
}
