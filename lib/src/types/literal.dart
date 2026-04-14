part of 'type.dart';

class VLiteral<T> extends VType<T> {
  final T _expected;

  VLiteral(
    this._expected, {
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
