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

class VObjectBuilder<T> {
  final List<_FieldEntry<T>> _fields = [];

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

class VObject<T> extends VType<T> {
  final List<_FieldEntry<T>> _fields;

  VObject._(this._fields);

  factory VObject([void Function(VObjectBuilder<T> o)? configure]) {
    if (configure == null) return VObject._([]);

    final builder = VObjectBuilder<T>();
    configure(builder);
    return VObject._(builder._build());
  }

  @override
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
}
