part of 'type.dart';

class VUnion extends VType<Object> {
  final List<VType> _options;

  VUnion(
    this._options, {
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) {
    assert(_options.length >= 2, 'Union must have at least 2 options.');
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  @override
  VResult<Object?> safeParse(Object? value) {
    final nullResult = _nullCheck<Object>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

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
