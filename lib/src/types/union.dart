part of 'type.dart';

class VUnion extends VType<Object> {
  final List<VType> _options;

  VUnion(this._options) {
    assert(_options.length >= 2, 'Union must have at least 2 options.');
  }

  @override
  VResult<Object?> safeParse(Object? value) {
    if (value == null) {
      if (_isNullable) return const VSuccess<Object?>(null);
      if (_hasDefault) return VSuccess<Object?>(_defaultValue);
      if (_isOptional) return const VSuccess<Object?>(null);

      return const VFailure<Object?>([
        VError(code: 'required', message: 'Required'),
      ]);
    }

    for (final option in _options) {
      final result = option.safeParse(value);
      if (result.isValid) {
        return VSuccess<Object?>(value);
      }
    }

    return const VFailure<Object?>([
      VError(
        code: 'invalid_union',
        message: 'Value does not match any of the union types',
      ),
    ]);
  }
}
