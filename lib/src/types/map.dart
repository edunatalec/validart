part of 'type.dart';

class _WhenRule {
  final String field;
  final Object? equals;
  final Map<String, VType> then;

  const _WhenRule({
    required this.field,
    required this.equals,
    required this.then,
  });
}

/// Validates `Map<String, dynamic>` values against a field schema.
///
/// Errors from individual fields include the field name in their path.
///
/// ```dart
/// final schema = V.map({
///   'name': V.string().min(2),
///   'age': V.int().positive(),
/// });
/// schema.parse({'name': 'Jo', 'age': 25});
/// ```
class VMap extends VType<Map<String, dynamic>> {
  final Map<String, VType> _schema;
  final List<_WhenRule> _whenRules = [];
  bool _isStrict = false;
  bool _isPassthrough = false;

  /// Creates a map validator with the given field [_schema].
  ///
  /// Pass [message] to override the default translation used
  /// when the input is `null`.
  VMap(this._schema, {super.message}) {
    assert(_schema.isNotEmpty, 'Schema must have at least one field.');
  }

  @override
  VMap add(
    Validator<Map<String, dynamic>> validator, {
    String? message,
    List<Object>? path,
  }) {
    super.add(validator, message: message, path: path);
    return this;
  }

  @override
  VMap nullable() {
    super.nullable();
    return this;
  }

  @override
  VMap defaultValue(Map<String, dynamic> value) {
    super.defaultValue(value);
    return this;
  }

  @override
  VMap preprocess(Object? Function(Object? value) fn) {
    super.preprocess(fn);
    return this;
  }

  @override
  VMap refine(
    bool Function(Map<String, dynamic> value) check, {
    String? message,
    String? code,
  }) {
    super.refine(check, message: message, code: code);
    return this;
  }

  @override
  VMap preprocessAsync(Future<Object?> Function(Object? value) fn) {
    super.preprocessAsync(fn);
    return this;
  }

  @override
  VMap refineAsync(
    Future<bool> Function(Map<String, dynamic> value) check, {
    String? message,
    String? code,
    Duration? timeout,
  }) {
    super.refineAsync(check, message: message, code: code, timeout: timeout);
    return this;
  }

  /// Returns an unmodifiable view of the field schema.
  Map<String, VType> get schema => Map.unmodifiable(_schema);

  /// The conditional validation rules added via [when].
  List<({String field, Object? equals, Map<String, VType> then})>
      get whenRules => _whenRules
          .map((r) => (field: r.field, equals: r.equals, then: r.then))
          .toList();

  /// Creates a new schema containing only the specified [keys].
  ///
  /// ```dart
  /// final full = V.map({'name': V.string(), 'age': V.int()});
  /// final partial = full.pick(['name']); // only validates 'name'
  /// ```
  VMap pick(List<String> keys) {
    final picked = <String, VType>{};

    for (final key in keys) {
      if (_schema.containsKey(key)) {
        picked[key] = _schema[key]!;
      }
    }

    return VMap(picked);
  }

  /// Creates a new schema excluding the specified [keys].
  ///
  /// ```dart
  /// final full = V.map({'name': V.string(), 'age': V.int()});
  /// final reduced = full.omit(['age']); // only validates 'name'
  /// ```
  VMap omit(List<String> keys) {
    final omitted = Map<String, VType>.from(_schema);

    for (final key in keys) {
      omitted.remove(key);
    }

    return VMap(omitted);
  }

  /// Creates a new schema by adding [extra] fields to the current schema.
  ///
  /// Preserves all pipeline state from the base schema: validators added via
  /// `add`/`equalFields`/`refineField`/`refine`, `when` rules, `strict` and
  /// `passthrough` flags, `nullable`, `defaultValue`, and preprocessors.
  ///
  /// ```dart
  /// final base = V.map({'name': V.string()});
  /// final extended = base.extend({'age': V.int()});
  /// ```
  VMap extend(Map<String, VType> extra) {
    final result = VMap({..._schema, ...extra});
    _copyMapStateTo(result);
    return result;
  }

  /// Creates a new schema by merging with [other]'s fields.
  ///
  /// Combines pipeline state from both schemas: `when` rules, validator
  /// steps, and preprocessors are concatenated (base first, then other).
  /// Boolean flags (`strict`, `passthrough`, `nullable`) are OR-ed. If both
  /// sides set `defaultValue`, [other]'s wins.
  ///
  /// ```dart
  /// final a = V.map({'name': V.string()});
  /// final b = V.map({'age': V.int()});
  /// final merged = a.merge(b);
  /// ```
  VMap merge(VMap other) {
    final result = VMap({..._schema, ...other._schema});
    _copyMapStateTo(result);
    other._copyMapStateTo(result);
    return result;
  }

  void _copyMapStateTo(VMap target) {
    target._whenRules.addAll(_whenRules);
    target._steps.addAll(_steps);
    target._preprocessors.addAll(_preprocessors);

    if (_isStrict) target._isStrict = true;
    if (_isPassthrough) target._isPassthrough = true;
    if (_isNullable) target._isNullable = true;

    if (_hasDefault) {
      target._defaultValue = _defaultValue;
      target._hasDefault = true;
    }
  }

  /// Creates a new schema where all fields are nullable.
  ///
  /// Does not mutate the original schema — inner validators are wrapped so
  /// that the base schema continues to reject null.
  ///
  /// ```dart
  /// final schema = V.map({'name': V.string()}).partial();
  /// schema.parse({'name': null}); // {'name': null}
  /// ```
  VMap partial() {
    final partialSchema = <String, VType>{};

    for (final entry in _schema.entries) {
      partialSchema[entry.key] = entry.value.mapType<VType>(
        <U>(inner) => _NullableWrapper<U>(inner),
      );
    }

    return VMap(partialSchema);
  }

  /// Rejects keys not present in the schema.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).strict()
  ///   .validate({'name': 'Jo', 'extra': true}); // false
  /// ```
  VMap strict() {
    _isStrict = true;
    return this;
  }

  /// Allows extra keys not in the schema to pass through to the result.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).passthrough()
  ///   .parse({'name': 'Jo', 'extra': true}); // {'name': 'Jo', 'extra': true}
  /// ```
  VMap passthrough() {
    _isPassthrough = true;
    return this;
  }

  /// Applies conditional validation rules based on a field's value.
  ///
  /// When [field] equals [equals], the [then] validators are applied.
  ///
  /// ```dart
  /// V.map({
  ///   'type': V.string(),
  ///   'value': V.string(),
  /// }).when('type', equals: 'email', then: {
  ///   'value': V.string().email(),
  /// });
  /// ```
  VMap when(
    String field, {
    required Object? equals,
    required Map<String, VType> then,
  }) {
    assert(
      _schema.containsKey(field),
      "The provided field '$field' does not exist in the schema.",
    );
    _whenRules.add(_WhenRule(field: field, equals: equals, then: then));
    return this;
  }

  /// Creates a [VArray] schema that validates a `List<Map<String, dynamic>>`.
  ///
  /// ```dart
  /// V.map({'name': V.string()}).array().parse([{'name': 'Jo'}]);
  /// ```
  VArray<Map<String, dynamic>> array() => VArray<Map<String, dynamic>>(this);

  /// Validates that two fields have equal values.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.map({
  ///   'password': V.string(),
  ///   'confirm': V.string(),
  /// }).equalFields('password', 'confirm');
  /// ```
  VMap equalFields(String field, String other, {String? message}) {
    assert(
      _schema.containsKey(field),
      "The provided field '$field' does not exist in the schema.",
    );
    assert(
      _schema.containsKey(other),
      "The provided field '$other' does not exist in the schema.",
    );
    return add(
      EqualFieldsValidator(field: field, other: other),
      message: message,
    );
  }

  /// Adds a custom validation that targets a specific field path.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.map({
  ///   'age': V.int(),
  /// }).refineField(
  ///   (data) => (data['age'] as int) >= 18,
  ///   path: 'age',
  ///   message: 'Must be at least 18',
  /// );
  /// ```
  VMap refineField(
    bool Function(Map<String, dynamic> data) check, {
    required String path,
    String? message,
  }) {
    assert(
      _schema.containsKey(path),
      "The provided path '$path' does not exist in the schema.",
    );

    return add(
      _RefineValidator<Map<String, dynamic>>(
        check: check,
        validatorCode: VCode.custom,
      ),
      message: message,
      path: [path],
    );
  }

  @override
  bool get hasAsync {
    if (super.hasAsync) return true;

    for (final field in _schema.values) {
      if (field.hasAsync) return true;
    }

    for (final rule in _whenRules) {
      for (final field in rule.then.values) {
        if (field.hasAsync) return true;
      }
    }

    return false;
  }

  @override
  VResult<Map<String, dynamic>?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    final resolution = _resolveNull<Map<String, dynamic>>(
      _defaultValue,
      _hasDefault,
      value,
    );
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        input!,
      );
    }

    final errors = <VError>[];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in input.keys) {
        if (!_schema.containsKey(key)) {
          errors.add(VError(
            code: VCode.unrecognizedKey,
            message: V.t(VCode.unrecognizedKey, {'key': key}),
            path: [key],
          ));
        }
      }
    }

    for (final entry in _schema.entries) {
      final fieldValue = input[entry.key];
      final result = entry.value.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[entry.key] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(
              path: [entry.key, ...error.path],
            ));
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] == rule.equals) {
        for (final entry in rule.then.entries) {
          final fieldValue = input[entry.key];
          final result = entry.value.safeParse(fieldValue);

          switch (result) {
            case VSuccess():
              parsed[entry.key] = result.value;
            case VFailure():
              for (final error in result.errors) {
                errors.add(error.copyWith(
                  path: [entry.key, ...error.path],
                ));
              }
          }
        }
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!_schema.containsKey(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    if (errors.isNotEmpty) {
      return VFailure<Map<String, dynamic>?>(errors);
    }

    return _runPipeline(parsed);
  }

  @override
  Future<VResult<Map<String, dynamic>?>> safeParseAsync(Object? value) async {
    final resolution = _resolveNull<Map<String, dynamic>>(
      _defaultValue,
      _hasDefault,
      value,
    );
    if (resolution.earlyReturn != null) return resolution.earlyReturn!;
    final input = resolution.input;

    if (input is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        input!,
      );
    }

    final errors = <VError>[];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in input.keys) {
        if (!_schema.containsKey(key)) {
          errors.add(VError(
            code: VCode.unrecognizedKey,
            message: V.t(VCode.unrecognizedKey, {'key': key}),
            path: [key],
          ));
        }
      }
    }

    for (final entry in _schema.entries) {
      final fieldValue = input[entry.key];
      final result = entry.value.hasAsync
          ? await entry.value.safeParseAsync(fieldValue)
          : entry.value.safeParse(fieldValue);

      switch (result) {
        case VSuccess():
          parsed[entry.key] = result.value;
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(
              path: [entry.key, ...error.path],
            ));
          }
      }
    }

    for (final rule in _whenRules) {
      if (input[rule.field] == rule.equals) {
        for (final entry in rule.then.entries) {
          final fieldValue = input[entry.key];
          final result = entry.value.hasAsync
              ? await entry.value.safeParseAsync(fieldValue)
              : entry.value.safeParse(fieldValue);

          switch (result) {
            case VSuccess():
              parsed[entry.key] = result.value;
            case VFailure():
              for (final error in result.errors) {
                errors.add(error.copyWith(
                  path: [entry.key, ...error.path],
                ));
              }
          }
        }
      }
    }

    if (_isPassthrough) {
      for (final entry in input.entries) {
        if (!_schema.containsKey(entry.key)) {
          parsed[entry.key] = entry.value;
        }
      }
    }

    if (errors.isNotEmpty) {
      return VFailure<Map<String, dynamic>?>(errors);
    }

    return _runPipelineAsync(parsed);
  }
}
