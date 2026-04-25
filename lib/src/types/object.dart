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

class _ObjectWhenRule<T> {
  final String field;
  final Object? equals;
  final Map<String, VType> then;

  const _ObjectWhenRule({
    required this.field,
    required this.equals,
    required this.then,
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
  final List<_ObjectWhenRule<T>> _whenRules = [];

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

  /// Creates a [VArray] schema that validates a `List<T>` using this
  /// schema as the element validator.
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .array()
  ///     .validate([User(name: 'Jo'), User(name: 'Ana')]);
  /// ```
  VArray<T> array() => VArray<T>(this);

  /// Requires the fields named [fieldA] and [fieldB] to compare equal
  /// via `==`. Both names must already be declared via [field] before
  /// calling this method.
  ///
  /// ```dart
  /// V.object<SignUpDto>()
  ///     .field('password', (d) => d.password, V.string().password())
  ///     .field('confirm', (d) => d.confirm, V.string())
  ///     .equalFields('password', 'confirm');
  /// ```
  VObject<T> equalFields(String fieldA, String fieldB, {String? message}) {
    final entryA = _fields.firstWhere(
      (f) => f.name == fieldA,
      orElse: () => throw ArgumentError(
        "The provided field '$fieldA' does not exist in the schema.",
      ),
    );
    final entryB = _fields.firstWhere(
      (f) => f.name == fieldB,
      orElse: () => throw ArgumentError(
        "The provided field '$fieldB' does not exist in the schema.",
      ),
    );

    return add(
      ObjectEqualFieldsValidator<T>(
        fieldA: fieldA,
        fieldB: fieldB,
        extractorA: entryA.extractor,
        extractorB: entryB.extractor,
      ),
      message: message,
    );
  }

  /// The conditional validation rules added via [when].
  List<({String field, Object? equals, Map<String, VType> then})>
      get whenRules => _whenRules
          .map((r) => (field: r.field, equals: r.equals, then: r.then))
          .toList();

  /// Creates a new schema containing only the fields named in [keys].
  ///
  /// Preserves all pipeline state from the base schema (validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `nullable`,
  /// `defaultValue`, and preprocessors).
  ///
  /// ```dart
  /// final full = V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .field('age', (u) => u.age, V.int());
  /// final partial = full.pick(['name']); // only validates 'name'
  /// ```
  VObject<T> pick(List<String> keys) {
    final result = VObject<T>._();

    for (final entry in _fields) {
      if (keys.contains(entry.name)) result._fields.add(entry);
    }

    _copyObjectStateTo(result);

    return result;
  }

  /// Creates a new schema excluding the fields named in [keys].
  ///
  /// Preserves all pipeline state from the base schema (validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `nullable`,
  /// `defaultValue`, and preprocessors).
  ///
  /// ```dart
  /// final full = V.object<User>()
  ///     .field('name', (u) => u.name, V.string())
  ///     .field('age', (u) => u.age, V.int());
  /// final reduced = full.omit(['age']); // only validates 'name'
  /// ```
  VObject<T> omit(List<String> keys) {
    final result = VObject<T>._();

    for (final entry in _fields) {
      if (!keys.contains(entry.name)) result._fields.add(entry);
    }

    _copyObjectStateTo(result);

    return result;
  }

  /// Creates a new schema by merging with [other]'s fields.
  ///
  /// Combines pipeline state from both schemas: `when` rules, validator
  /// steps, and preprocessors are concatenated (base first, then [other]).
  /// Boolean flags (`nullable`) are OR-ed. If both sides set `defaultValue`,
  /// [other]'s wins. If both sides declare a field with the same name,
  /// [other]'s entry appears twice in `_fields` — callers are expected to
  /// merge schemas that do not overlap.
  ///
  /// ```dart
  /// final base = V.object<User>().field('id', (u) => u.id, V.string().uuid());
  /// final audit = V.object<User>().field('createdAt', (u) => u.createdAt, V.date());
  /// final full = base.merge(audit);
  /// ```
  VObject<T> merge(VObject<T> other) {
    final result = VObject<T>._();
    result._fields.addAll(_fields);
    result._fields.addAll(other._fields);
    _copyObjectStateTo(result);
    other._copyObjectStateTo(result);

    return result;
  }

  void _copyObjectStateTo(VObject<T> target) {
    target._whenRules.addAll(_whenRules);
    target._steps.addAll(_steps);
    target._preprocessors.addAll(_preprocessors);

    if (_isNullable) target._isNullable = true;

    if (_hasDefault) {
      target._defaultValue = _defaultValue;
      target._hasDefault = true;
    }
  }

  /// Applies conditional validation rules based on a field's value. When the
  /// value read from [field] equals [equals], every validator in [then] is
  /// applied to the corresponding field in addition to its baseline
  /// validator. Both [field] and every key in [then] must already be
  /// declared on the schema.
  ///
  /// ```dart
  /// V.object<TaxPayer>()
  ///     .field('country', (t) => t.country, V.string())
  ///     .field('taxId', (t) => t.taxId, V.string())
  ///     .when('country', equals: 'US', then: {
  ///       'taxId': V.string().taxId(patterns: [const UsSsnPattern()]),
  ///     });
  /// ```
  VObject<T> when(
    String field, {
    required Object? equals,
    required Map<String, VType> then,
  }) {
    assert(
      _fields.any((f) => f.name == field),
      "The provided field '$field' does not exist in the schema.",
    );

    for (final key in then.keys) {
      assert(
        _fields.any((f) => f.name == key),
        "The provided 'then' field '$key' does not exist in the schema.",
      );
    }

    _whenRules.add(
      _ObjectWhenRule<T>(field: field, equals: equals, then: then),
    );

    return this;
  }

  /// Adds a custom validation targeting a specific field [path]. The [check]
  /// receives the whole instance and the emitted error is scoped to [path].
  ///
  /// ```dart
  /// V.object<User>()
  ///     .field('age', (u) => u.age, V.int())
  ///     .refineField(
  ///       (u) => u.age >= 18,
  ///       path: 'age',
  ///       message: 'Must be at least 18',
  ///     );
  /// ```
  VObject<T> refineField(
    bool Function(T instance) check, {
    required String path,
    String? message,
  }) {
    assert(
      _fields.any((f) => f.name == path),
      "The provided path '$path' does not exist in the schema.",
    );

    return add(
      _RefineValidator<T>(check: check, validatorCode: VCode.custom),
      message: message,
      path: [path],
    );
  }

  @override
  bool get hasAsync {
    if (super.hasAsync) return true;

    for (final field in _fields) {
      if (field.validator.hasAsync) return true;
    }

    for (final rule in _whenRules) {
      for (final validator in rule.then.values) {
        if (validator.hasAsync) return true;
      }
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

    for (final rule in _whenRules) {
      final ruleField = _fields.firstWhere((f) => f.name == rule.field);
      final conditionValue = ruleField.extractor(typed);

      if (conditionValue != rule.equals) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
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

    for (final rule in _whenRules) {
      final ruleField = _fields.firstWhere((f) => f.name == rule.field);
      final conditionValue = ruleField.extractor(typed);

      if (conditionValue != rule.equals) continue;

      for (final thenEntry in rule.then.entries) {
        final targetField = _fields.firstWhere((f) => f.name == thenEntry.key);
        final fieldValue = targetField.extractor(typed);
        final result = thenEntry.value.hasAsync
            ? await thenEntry.value.safeParseAsync(fieldValue)
            : thenEntry.value.safeParse(fieldValue);

        switch (result) {
          case VSuccess():
            break;
          case VFailure():
            for (final error in result.errors) {
              errors.add(error.copyWith(path: [thenEntry.key, ...error.path]));
            }
        }
      }
    }

    if (errors.isNotEmpty) return VFailure<T?>(errors);

    return _runPipelineAsync(typed);
  }
}
