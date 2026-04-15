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

  VObject._({required List<_FieldEntry<T>> fields}) : _fields = fields;

  Map<String, VType> get schema =>
      Map.fromEntries(_fields.map((f) => MapEntry(f.name, f.validator)));

  Map<String, dynamic> extract(T instance) => Map.fromEntries(
      _fields.map((f) => MapEntry(f.name, f.extractor(instance))));

  factory VObject({void Function(VObjectBuilder<T> o)? configure}) {
    final List<_FieldEntry<T>> fields;
    if (configure != null) {
      final builder = VObjectBuilder<T>();
      configure(builder);
      fields = builder._build();
    } else {
      fields = [];
    }
    return VObject._(fields: fields);
  }

  @override
  VResult<T?> safeParse(Object? value) {
    final nullResult = _nullCheck<T>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

    final T typed;

    try {
      typed = value as T;
    } catch (_) {
      return _typeError<T>(T.toString(), value!);
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
