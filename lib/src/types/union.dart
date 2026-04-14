part of 'type.dart';

class VUnion extends VType<Object> {
  final List<VType> _options;

  VUnion(this._options) {
    assert(_options.length >= 2, 'Union must have at least 2 options.');
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

    return VFailure<Object?>([
      VError(
        code: VCode.invalidUnion,
        message: V.t(VCode.invalidUnion),
      ),
    ]);
  }
}
