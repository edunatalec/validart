part of 'type.dart';

class VMap extends VType<Map<String, dynamic>> {
  final Map<String, VType> _schema;
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

  VMap refineField(
    bool Function(Map<String, dynamic> data) check, {
    required String path,
    String? message,
  }) {
    assert(
      _schema.containsKey(path),
      "The provided path '$path' does not exist in the schema.",
    );

    final msg = message ?? 'Invalid value';

    _addValidator(
      'custom',
      (value) => check(value) ? null : msg,
    );
    return this;
  }

  @override
  VResult<Map<String, dynamic>?> safeParse(Object? value) {
    if (value == null) {
      if (_isNullable) return const VSuccess<Map<String, dynamic>?>(null);
      if (_hasDefault) return VSuccess<Map<String, dynamic>?>(_defaultValue);
      if (_isOptional) return const VSuccess<Map<String, dynamic>?>(null);

      return const VFailure<Map<String, dynamic>?>([
        VError(code: 'required', message: 'Required'),
      ]);
    }

    if (value is! Map<String, dynamic>) {
      return VFailure<Map<String, dynamic>?>([
        VError(
          code: 'invalid_type',
          message:
              'Expected Map<String, dynamic>, received ${value.runtimeType}',
        ),
      ]);
    }

    final errors = <VError>[];
    final parsed = <String, dynamic>{};

    if (_isStrict) {
      for (final key in value.keys) {
        if (!_schema.containsKey(key)) {
          errors.add(VError(
            code: 'unrecognized_key',
            message: 'Unrecognized key "$key"',
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

    final pipelineResult = _runPipeline(parsed);

    return pipelineResult;
  }
}
