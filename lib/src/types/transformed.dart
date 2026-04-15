part of 'type.dart';

/// Wraps a schema and transforms its output to a different type.
///
/// Created via [VType.transform]. Runs the inner schema's full pipeline,
/// then applies the transform function to the result.
///
/// ```dart
/// final schema = V.string().transform<int>((v) => int.parse(v));
/// schema.parse('42'); // 42
/// ```
class VTransformed<I, O> extends VType<O> {
  final VType<I> _inner;
  final O Function(I value) _transformFn;

  /// Creates a transformed validator wrapping [_inner] with [_transformFn].
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
