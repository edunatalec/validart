part of 'type.dart';

class VLiteral<T> extends VType<T> {
  final T _expected;

  VLiteral(this._expected);

  @override
  VResult<T?> safeParse(Object? value) {
    final nullResult = _nullCheck<T>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

    if (value == _expected) {
      return VSuccess<T?>(_expected);
    }

    return VFailure<T?>([
      VError(
        code: VCode.invalidLiteral,
        message: V.t(VCode.invalidLiteral, {
          'expected': _expected,
          'received': value,
        }),
      ),
    ]);
  }
}
