part of 'type.dart';

class VLiteral<T> extends VType<T> {
  final T _expected;

  VLiteral(this._expected);

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

    if (value == _expected) {
      return VSuccess<T?>(_expected);
    }

    return VFailure<T?>([
      VError(
        code: 'invalid_literal',
        message: 'Expected "$_expected", received "$value"',
      ),
    ]);
  }
}
