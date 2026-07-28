part of 'type.dart';

/// Validates `List<T>` values, applying the element schema to each item.
///
/// Errors from individual elements include the array index in their path.
///
/// ```dart
/// final schema = V.string().email().array().min(1);
/// schema.parse(['user@mail.com']); // ['user@mail.com']
/// ```
class VArray<T> extends VType<List<T>> {
  /// Creates an array validator with the given element [_element] schema.
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VArray(this._element, {super.message, super.invalidTypeMessage});

  final VType<T> _element;

  @override
  String get typeName => 'array';

  @override
  VArray<T> add(
    Validator<List<T>> validator, {
    String? message,
    List<Object>? path,
    Set<String>? dependsOn,
  }) {
    super.add(validator, message: message, path: path, dependsOn: dependsOn);
    return this;
  }

  @override
  VArray<T> nullable() {
    super.nullable();
    return this;
  }

  @override
  VArray<T> defaultValue(List<T> value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VArray<T> preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VArray<T> refine(
    bool Function(List<T> value) check, {
    String? message,
    String? code,
    Set<String>? dependsOn,
  }) {
    super.refine(check, message: message, code: code, dependsOn: dependsOn);
    return this;
  }

  @override
  VArray<T> preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VArray<T> refineAsync(
    Future<bool> Function(List<T> value) check, {
    String? message,
    String? code,
    Duration? timeout,
    Set<String>? dependsOn,
  }) {
    super.refineAsync(
      check,
      message: message,
      code: code,
      timeout: timeout,
      dependsOn: dependsOn,
    );
    return this;
  }

  /// Validates that the list has at least [length] elements.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().array().min(2).validate(['a', 'b']); // true
  /// V.string().array().min(2).validate(['a']);       // false
  /// ```
  VArray<T> min(int length, {String Function(int)? message}) {
    return add(
      MinLengthListValidator<T>(min: length),
      message: message?.call(length),
    );
  }

  /// Validates that the list has at most [length] elements.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().array().max(3).validate(['a', 'b']); // true
  /// V.string().array().max(1).validate(['a', 'b']); // false
  /// ```
  VArray<T> max(int length, {String Function(int)? message}) {
    return add(
      MaxLengthListValidator<T>(max: length),
      message: message?.call(length),
    );
  }

  /// Validates that all elements in the list are unique.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().array().unique().validate([1, 2, 3]); // true
  /// V.int().array().unique().validate([1, 1, 2]); // false
  /// ```
  VArray<T> unique({String? message}) {
    return add(UniqueValidator<T>(), message: message);
  }

  /// Validates that all elements are distinct **by the value returned
  /// from [by]**. Use this when elements are `Map` or class instances
  /// and uniqueness depends on a property (an `id`, an `email`, ...)
  /// rather than reference equality.
  ///
  /// Emits the same error code as [unique] (`array.unique`); the
  /// failure mode is identical — the array contains duplicates. The
  /// returned value of [by] must implement `==` / `hashCode` correctly
  /// for the comparison to be meaningful.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.map({'id': V.int(), 'name': V.string()})
  ///     .array()
  ///     .distinct((m) => m['id'])
  ///     .validate([
  ///       {'id': 1, 'name': 'a'},
  ///       {'id': 2, 'name': 'b'},
  ///     ]); // true
  ///
  /// V.object<User>()
  ///     .field('id', (u) => u.id, V.string())
  ///     .array()
  ///     .distinct((u) => u.id)
  ///     .validate([userA, userB]);
  /// ```
  VArray<T> distinct(
    Object Function(T element) by, {
    String? message,
  }) {
    return add(DistinctValidator<T>(by: by), message: message);
  }

  /// Validates that the list contains all elements from [required].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().array().contains([1, 2]).validate([1, 2, 3]); // true
  /// V.int().array().contains([1, 2]).validate([1, 3]);     // false
  /// ```
  VArray<T> contains(List<T> required, {String? message}) {
    return add(ContainsAllValidator<T>(required: required), message: message);
  }

  @override
  bool get hasAsync => super.hasAsync || _element.hasAsync;

  @override
  VResult<List<T>?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final Object? preprocessed = runPreprocessors(value);

    final resolution =
        _resolveNull<List<T>>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! List) {
      return _typeError<List<T>>('List<${T.toString()}>', input!);
    }

    final errors = <VError>[];
    final List<T> parsed = [];

    for (int i = 0; i < input.length; i++) {
      final result = _element.safeParse(input[i]);

      switch (result) {
        case VSuccess():
          parsed.add(result.value as T);
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [i, ...error.path]));
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<List<T>?>(errors);

    return _runPipeline(parsed);
  }

  @override
  Future<VResult<List<T>?>> safeParseAsync(Object? value) async {
    final Object? preprocessed = await runPreprocessorsAsync(value);

    final resolution =
        _resolveNull<List<T>>(_defaultValue, _hasDefault, preprocessed);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! List) {
      return _typeError<List<T>>('List<${T.toString()}>', input!);
    }

    final errors = <VError>[];
    final List<T> parsed = [];

    for (int i = 0; i < input.length; i++) {
      final result = _element.hasAsync
          ? await _element.safeParseAsync(input[i])
          : _element.safeParse(input[i]);

      switch (result) {
        case VSuccess():
          parsed.add(result.value as T);
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [i, ...error.path]));
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<List<T>?>(errors);

    return _runPipelineAsync(parsed);
  }
}
