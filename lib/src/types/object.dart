part of 'type.dart';

class _FieldEntry<T> {
  final String name;
  final Object? Function(T instance) extractor;
  final VType validator;

  const _FieldEntry({
    required this.name,
    required this.extractor,
    required this.validator,
  });
}

/// Validates class/entity instances of type [T] via type-safe field
/// extraction callbacks.
///
/// ```dart
/// final schema = V.object<User>()
///     .field('name', (u) => u.name, V.string().min(2))
///     .field('age', (u) => u.age, V.int().positive());
/// schema.validate(User(name: 'Jo', age: 25)); // true
/// ```
class VObject<T> extends VType<T> {
  final List<_FieldEntry<T>> _fields = [];

  VObject._({super.message});

  @override
  String get typeName => 'object';

  @override
  VObject<T> add(
    Validator<T> validator, {
    String? message,
    List<Object>? path,
  }) {
    super.add(validator, message: message, path: path);
    return this;
  }

  @override
  VObject<T> nullable() {
    super.nullable();
    return this;
  }

  @override
  VObject<T> defaultValue(T value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VObject<T> preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VObject<T> refine(
    bool Function(T value) check, {
    String? message,
    String? code,
  }) {
    super.refine(check, message: message, code: code);
    return this;
  }

  @override
  VObject<T> preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VObject<T> refineAsync(
    Future<bool> Function(T value) check, {
    String? message,
    String? code,
    Duration? timeout,
  }) {
    super.refineAsync(check, message: message, code: code, timeout: timeout);
    return this;
  }

  /// Returns an unmodifiable map of field names to their validators.
  Map<String, VType> get schema =>
      Map.fromEntries(_fields.map((f) => MapEntry(f.name, f.validator)));

  /// Extracts field values from [instance] into a `Map<String, dynamic>`.
  ///
  /// ```dart
  /// final data = schema.extract(User(name: 'Jo', age: 25));
  /// // {'name': 'Jo', 'age': 25}
  /// ```
  Map<String, dynamic> extract(T instance) => Map.fromEntries(
      _fields.map((f) => MapEntry(f.name, f.extractor(instance))));

  /// Creates a [VObject] — chain [field] to add type-safe field extractors.
  ///
  /// ```dart
  /// final schema = VObject<User>()
  ///     .field('name', (u) => u.name, V.string());
  /// ```
  factory VObject({String? message}) = VObject<T>._;

  /// Adds a field to the schema with a [name], an [extractor] to read its
  /// value from an instance of [T], and a [validator] schema.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('email', (u) => u.email, V.string().email())
  ///     .field('age', (u) => u.age, V.int().positive());
  /// ```
  VObject<T> field<F>(
    String name,
    F? Function(T instance) extractor,
    VType<F> validator,
  ) {
    _fields.add(_FieldEntry<T>(
      name: name,
      extractor: (instance) => extractor(instance),
      validator: validator,
    ));

    return this;
  }

  @override
  bool get hasAsync {
    if (super.hasAsync) return true;

    for (final field in _fields) {
      if (field.validator.hasAsync) return true;
    }

    return false;
  }

  @override
  VResult<T?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, value);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final T typed;

    try {
      typed = input as T;
    } catch (_) {
      return _typeError<T>(T.toString(), input!);
    }

    final errors = <VError>[];

    for (final field in _fields) {
      final fieldValue = field.extractor(typed);
      final result = field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          break;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return _runPipeline(typed);
  }

  @override
  Future<VResult<T?>> safeParseAsync(Object? value) async {
    final resolution = _resolveNull<T>(_defaultValue, _hasDefault, value);
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    final T typed;

    try {
      typed = input as T;
    } catch (_) {
      return _typeError<T>(T.toString(), input!);
    }

    final errors = <VError>[];

    for (final field in _fields) {
      final fieldValue = field.extractor(typed);
      final result = field.validator.hasAsync
          ? await field.validator.safeParseAsync(fieldValue)
          : field.validator.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          break;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [field.name, ...error.path]));
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return _runPipelineAsync(typed);
  }
}
