import 'dart:math' as math;

import 'package:validart/src/error.dart';
import 'package:validart/src/messages/messages.dart';
import 'package:validart/src/result.dart';

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

typedef Validator<T> = String? Function(T value);

abstract class VType<T> {
  final List<_PipelineStep<T>> _steps = [];
  bool _isOptional = false;
  bool _isNullable = false;
  T? _defaultValue;
  bool _hasDefault = false;
  T Function(Object value)? coercer;

  VType<T> _addStep(_PipelineStep<T> step) {
    _steps.add(step);
    return this;
  }

  VType<T> _addValidator(String code, Validator<T> check) {
    return _addStep(_ValidationStep<T>(code: code, check: check));
  }

  T? parse(Object? value) {
    final result = safeParse(value);

    if (result case VFailure(:final errors)) {
      throw VException(errors);
    }

    return (result as VSuccess<T?>).value;
  }

  VResult<T?> safeParse(Object? value) {
    if (value == null) {
      if (_isNullable) return VSuccess<T?>(null);
      if (_hasDefault) return VSuccess<T?>(_defaultValue);
      if (_isOptional) return VSuccess<T?>(null);

      return VFailure<T?>([
        const VError(code: 'required', message: 'Required'),
      ]);
    }

    final T typed;

    if (coercer != null) {
      try {
        typed = coercer!(value);
      } catch (_) {
        return VFailure<T?>([
          VError(
            code: 'invalid_type',
            message: 'Expected ${T.toString()}, received ${value.runtimeType}',
          ),
        ]);
      }
    } else {
      try {
        typed = value as T;
      } catch (_) {
        return VFailure<T?>([
          VError(
            code: 'invalid_type',
            message: 'Expected ${T.toString()}, received ${value.runtimeType}',
          ),
        ]);
      }
    }

    return _runPipeline(typed);
  }

  VResult<T?> _runPipeline(T value) {
    final errors = <VError>[];
    T current = value;

    for (final step in _steps) {
      switch (step) {
        case _ValidationStep<T>(:final code, :final check):
          final error = check(current);
          if (error != null) {
            errors.add(VError(code: code, message: error));
          }
        case _TransformStep<T>(:final transform):
          if (errors.isEmpty) {
            current = transform(current);
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return VSuccess<T?>(current);
  }

  bool validate(Object? value) => safeParse(value).isValid;

  List<VError>? errors(Object? value) {
    final result = safeParse(value);

    if (result case VFailure(:final errors)) return errors;

    return null;
  }

  VType<T> optional() {
    _isOptional = true;
    return this;
  }

  VType<T> nullable() {
    _isNullable = true;
    return this;
  }

  VType<T> defaultValue(T value) {
    _defaultValue = value;
    _hasDefault = true;
    return this;
  }

  VType<T> refine(
    bool Function(T value) check, {
    String? message,
    String? code,
  }) {
    final msg = message ?? 'Invalid value';

    return _addValidator(
      code ?? 'custom',
      (value) => check(value) ? null : msg,
    );
  }

  VType<T> _transform(T Function(T value) fn) {
    _addStep(_TransformStep<T>(transform: fn));
    return this;
  }
}

sealed class _PipelineStep<T> {
  const _PipelineStep();
}

final class _ValidationStep<T> extends _PipelineStep<T> {
  final String code;
  final Validator<T> check;

  const _ValidationStep({
    required this.code,
    required this.check,
  });
}

final class _TransformStep<T> extends _PipelineStep<T> {
  final T Function(T value) transform;

  const _TransformStep({required this.transform});
}
