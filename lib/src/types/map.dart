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

class VMap extends VType<Map<String, dynamic>> {
  final Map<String, VType> _schema;
  final List<_WhenRule> _whenRules = [];
  bool _isStrict = false;
  bool _isPassthrough = false;

  VMap(this._schema) {
    assert(_schema.isNotEmpty, 'Schema must have at least one field.');
  }

  Map<String, VType> get schema => Map.unmodifiable(_schema);

  VMap pick(List<String> keys) {
    final picked = <String, VType>{};
    for (final key in keys) {
      if (_schema.containsKey(key)) {
        picked[key] = _schema[key]!;
      }
    }
    return VMap(picked);
  }

  VMap omit(List<String> keys) {
    final omitted = Map<String, VType>.from(_schema);
    for (final key in keys) {
      omitted.remove(key);
    }
    return VMap(omitted);
  }

  VMap extend(Map<String, VType> extra) {
    return VMap({..._schema, ...extra});
  }

  VMap merge(VMap other) {
    return VMap({..._schema, ...other._schema});
  }

  VMap partial() {
    final partialSchema = <String, VType>{};
    for (final entry in _schema.entries) {
      partialSchema[entry.key] = entry.value..optional();
    }
    return VMap(partialSchema);
  }

  VMap strict() {
    _isStrict = true;
    return this;
  }

  VMap passthrough() {
    _isPassthrough = true;
    return this;
  }

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

  VArray<Map<String, dynamic>> array() => VArray<Map<String, dynamic>>(this);

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
