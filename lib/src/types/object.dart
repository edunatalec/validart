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

/// Builder for defining type-safe field extraction rules on [VObject].
///
/// ```dart
/// V.object<User>(configure: (o) {
///   o.field('name', (u) => u.name, V.string().min(2));
///   o.field('age', (u) => u.age, V.int().positive());
/// });
/// ```
class VObjectBuilder<T> {
  final List<_FieldEntry<T>> _fields = [];

  /// Adds a field with a [name], an [extractor] to get its value from [T],
  /// and a [validator] schema.
  ///
  /// ```dart
  /// o.field('email', (u) => u.email, V.string().email());
  /// ```
  VObjectBuilder<T> field<F>(
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

  List<_FieldEntry<T>> _build() => List.unmodifiable(_fields);
}

/// Validates class/entity instances of type [T] via type-safe field
/// extraction callbacks.
///
/// ```dart
/// final schema = V.object<User>(configure: (o) {
///   o.field('name', (u) => u.name, V.string().min(2));
///   o.field('age', (u) => u.age, V.int().positive());
/// });
/// schema.validate(User(name: 'Jo', age: 25)); // true
/// ```
class VObject<T> extends VType<T> {
  final List<_FieldEntry<T>> _fields;

  VObject._({required List<_FieldEntry<T>> fields, super.message})
      : _fields = fields;

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

  /// Creates a [VObject] with optional field [configure] callback.
  ///
  /// ```dart
  /// final schema = VObject<User>(configure: (o) {
  ///   o.field('name', (u) => u.name, V.string());
  /// });
  /// ```
  factory VObject({
    void Function(VObjectBuilder<T> o)? configure,
    String? message,
  }) {
    final List<_FieldEntry<T>> fields;
    if (configure != null) {
      final builder = VObjectBuilder<T>();
      configure(builder);
      fields = builder._build();
    } else {
      fields = [];
    }
    return VObject._(fields: fields, message: message);
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
