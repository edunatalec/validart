part of 'type.dart';

class VEnum<T extends Enum> extends VType<T> {
  final List<T> _values;

  VEnum(this._values);

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

    if (value is T && _values.contains(value)) {
      return _runPipeline(value);
    }

    return VFailure<T?>([
      VError(
        code: 'invalid_enum',
        message:
            'Invalid value. Expected one of: ${_values.map((v) => v.name).join(', ')}',
      ),
    ]);
  }

  VArray<T> array() => VArray<T>(this);
}
