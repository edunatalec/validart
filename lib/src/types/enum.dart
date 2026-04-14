part of 'type.dart';

class VEnum<T extends Enum> extends VType<T> {
  final List<T> _values;

  VEnum(
    this._values, {
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  @override
  VResult<T?> safeParse(Object? value) {
    final nullResult = _nullCheck<T>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

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
