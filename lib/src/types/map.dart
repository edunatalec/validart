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
  VMap(this._schema) {
    assert(_schema.isNotEmpty, 'Schema must have at least one field.');
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
  /// ```dart
  /// final base = V.map({'name': V.string()});
  /// final extended = base.extend({'age': V.int()});
  /// ```
  VMap extend(Map<String, VType> extra) {
    return VMap({..._schema, ...extra});
  }

  /// Creates a new schema by merging with [other]'s fields.
  ///
  /// ```dart
  /// final a = V.map({'name': V.string()});
  /// final b = V.map({'age': V.int()});
  /// final merged = a.merge(b);
  /// ```
  VMap merge(VMap other) {
    return VMap({..._schema, ...other._schema});
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
    add(EqualFieldsValidator(field: field, other: other), message: message);
    return this;
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

    add(
      _RefineValidator<Map<String, dynamic>>(
        check: check,
        validatorCode: VCode.custom,
      ),
      message: message,
      path: [path],
    );
    return this;
  }

  @override
  VResult<Map<String, dynamic>?> safeParse(Object? value) {
    final nullResult = _nullCheck<Map<String, dynamic>>(
      _defaultValue,
      _hasDefault,
      value,
    );
    if (nullResult != null) return nullResult;

    if (value is! Map<String, dynamic>) {
      return _typeError<Map<String, dynamic>>(
        'Map<String, dynamic>',
        value!,
      );
    }

    final errors = <VError>[];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in value.keys) {
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
      final fieldValue = value[entry.key];
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
      if (value[rule.field] == rule.equals) {
        for (final entry in rule.then.entries) {
          final fieldValue = value[entry.key];
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
      for (final entry in value.entries) {
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
}
