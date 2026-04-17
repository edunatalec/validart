import 'package:validart/src/error.dart';
import 'package:validart/src/result.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/array/contains_all_validator.dart';
import 'package:validart/src/validators/array/max_length_list_validator.dart';
import 'package:validart/src/validators/array/min_length_list_validator.dart';
import 'package:validart/src/validators/array/unique_validator.dart';
import 'package:validart/src/validators/bool/is_false_validator.dart';
import 'package:validart/src/validators/map/equal_fields_validator.dart';
import 'package:validart/src/validators/bool/is_true_validator.dart';
import 'package:validart/src/validators/date/after_validator.dart';
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
import 'package:validart/src/validators/string/card_validator.dart';
import 'package:validart/src/validators/string/contains_validator.dart';
import 'package:validart/src/validators/string/date_string_validator.dart';
import 'package:validart/src/validators/string/email_validator.dart';
import 'package:validart/src/validators/string/ends_with_validator.dart';
import 'package:validart/src/validators/string/equals_validator.dart';
import 'package:validart/src/validators/string/ip_validator.dart';
import 'package:validart/src/validators/string/jwt_validator.dart';
import 'package:validart/src/validators/string/length_validator.dart';
import 'package:validart/src/validators/string/max_length_validator.dart';
import 'package:validart/src/validators/string/min_length_validator.dart';
import 'package:validart/src/validators/string/not_empty_validator.dart';
import 'package:validart/src/validators/string/password_validator.dart';
import 'package:validart/src/validators/string/pattern_validator.dart';
import 'package:validart/src/validators/string/phone_validator.dart';
import 'package:validart/src/validators/string/slug_validator.dart';
import 'package:validart/src/validators/string/starts_with_validator.dart';
import 'package:validart/src/validators/string/time_validator.dart';
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
  final List<_PipelineStep<T>> _steps = [];
  bool _isNullable = false;
  T? _defaultValue;
  bool _hasDefault = false;

  /// Optional coercion function to convert input to the expected type.
  T Function(Object value)? coercer;

  Object? Function(Object?)? _preprocessor;

  VType<T> _addStep(_PipelineStep<T> step) {
    _steps.add(step);
    return this;
  }

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

  VResult<S?>? _nullCheck<S>(S? defaultVal, bool hasDefault, Object? value) {
    if (value != null) return null;

    if (hasDefault) return VSuccess<S?>(defaultVal);
    if (_isNullable) return VSuccess<S?>(null);

    return VFailure<S?>([
      VError(code: VCode.required, message: V.t(VCode.required)),
    ]);
  }

  VFailure<S?> _typeError<S>(String expected, Object value) {
    return VFailure<S?>([
      VError(
        code: VCode.invalidType,
        message: V.t(VCode.invalidType, {
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
    final input = _preprocessor != null ? _preprocessor!(value) : value;

    final nullResult = _nullCheck<T>(_defaultValue, _hasDefault, input);
    if (nullResult != null) return nullResult;

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

  /// Returns `true` if [value] passes all validations.
  ///
  /// ```dart
  /// V.string().email().validate('user@mail.com'); // true
  /// V.string().email().validate('invalid');        // false
  /// ```
  bool validate(Object? value) => safeParse(value).isValid;

  /// Maps this type through a generic function, preserving the inner type.
  R mapType<R>(R Function<U>(VType<U> type) fn) => fn<T>(this);

  /// Returns the list of [VError]s for [value], or `null` if valid.
  ///
  /// ```dart
  /// final errors = V.string().email().errors('invalid');
  /// // [VError(invalid_email: Invalid email address)]
  /// ```
  List<VError>? errors(Object? value) {
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
    final previous = _preprocessor;

    _preprocessor = previous == null ? fn : (value) => fn(previous(value));

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

  VType<T> _preTransform(T Function(T value) fn) {
    _addStep(_PreTransformStep<T>(transform: fn));
    return this;
  }
}

class _NullableWrapper<T> extends VType<T> {
  final VType<T> _inner;

  _NullableWrapper(this._inner);

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

final class _TransformStep<T> extends _PipelineStep<T> {
  final T Function(T value) transform;

  const _TransformStep({required this.transform});
}
