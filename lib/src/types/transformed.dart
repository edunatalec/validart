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
  String get typeName => _inner.typeName;

  @override
  bool get hasAsync => super.hasAsync || _inner.hasAsync;

  @override
  VResult<O?> safeParse(Object? value) {
    if (hasAsync) {
      throw const VAsyncRequiredException(
        methodName: 'safeParse',
        suggestion: 'safeParseAsync',
      );
    }

    Object? preprocessed = value;

    for (final fn in _preprocessors) {
      preprocessed = fn(preprocessed);
    }

    final result = _inner.safeParse(preprocessed);

    switch (result) {
      case VSuccess(:final value):
        if (value == null) return VSuccess<O?>(null);
        return VSuccess<O?>(_transformFn(value as I));
      case VFailure(:final errors):
        return VFailure<O?>(errors);
    }
  }

  @override
  Future<VResult<O?>> safeParseAsync(Object? value) async {
    Object? preprocessed = value;

    for (final fn in _preprocessors) {
      preprocessed = fn(preprocessed);
    }

    for (final fn in _asyncPreprocessors) {
      preprocessed = await fn(preprocessed);
    }

    final result = _inner.hasAsync
        ? await _inner.safeParseAsync(preprocessed)
        : _inner.safeParse(preprocessed);

    switch (result) {
      case VSuccess(:final value):
        if (value == null) return VSuccess<O?>(null);
        return VSuccess<O?>(_transformFn(value as I));
      case VFailure(:final errors):
        return VFailure<O?>(errors);
    }
  }
}

/// Wraps a schema and asynchronously transforms its output to a different
/// type.
///
/// Created via [VType.transformAsync]. The transform function returns a
/// [Future], which makes the schema async-only.
///
/// ```dart
/// final schema = V.string().uuid().transformAsync<User>(
///   (id) async => await db.loadUser(id),
/// );
/// await schema.parseAsync('550e8400-...'); // User
/// ```
class VTransformedAsync<I, O> extends VType<O> {
  final VType<I> _inner;
  final Future<O> Function(I value) _transformFn;

  /// Creates an async-transformed validator wrapping [_inner] with
  /// [_transformFn].
  VTransformedAsync(this._inner, this._transformFn);

  @override
  String get typeName => _inner.typeName;

  @override
  bool get hasAsync => true;

  @override
  VResult<O?> safeParse(Object? value) {
    throw const VAsyncRequiredException(
      methodName: 'safeParse',
      suggestion: 'safeParseAsync',
    );
  }

  @override
  Future<VResult<O?>> safeParseAsync(Object? value) async {
    Object? preprocessed = value;

    for (final fn in _preprocessors) {
      preprocessed = fn(preprocessed);
    }

    for (final fn in _asyncPreprocessors) {
      preprocessed = await fn(preprocessed);
    }

    final result = _inner.hasAsync
        ? await _inner.safeParseAsync(preprocessed)
        : _inner.safeParse(preprocessed);

    switch (result) {
      case VSuccess(:final value):
        if (value == null) return VSuccess<O?>(null);
        return VSuccess<O?>(await _transformFn(value as I));
      case VFailure(:final errors):
        return VFailure<O?>(errors);
    }
  }
}
