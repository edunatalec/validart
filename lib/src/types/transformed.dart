part of 'type.dart';

class VTransformed<I, O> extends VType<O> {
  final VType<I> _inner;
  final O Function(I value) _transformFn;

  VTransformed(this._inner, this._transformFn);

  @override
  VResult<O?> safeParse(Object? value) {
    final result = _inner.safeParse(value);

    switch (result) {
      case VSuccess(:final value):
        if (value == null) return VSuccess<O?>(null);
        return VSuccess<O?>(_transformFn(value as I));
      case VFailure(:final errors):
        return VFailure<O?>(errors);
    }
  }
}
