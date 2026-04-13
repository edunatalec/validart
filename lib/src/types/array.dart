part of 'type.dart';

class VArray<T> extends VType<List<T>> {
  final VType<T> _element;
  final VArrayMessages _messages;

  VArray(this._element, [VArrayMessages? messages])
      : _messages = messages ?? const VArrayMessages();

  VArray<T> min(int length, {String Function(int)? message}) {
    final msg = message?.call(length) ?? _messages.min(length);
    _addValidator(
      'too_small',
      (value) => value.length >= length ? null : msg,
    );
    return this;
  }

  VArray<T> max(int length, {String Function(int)? message}) {
    final msg = message?.call(length) ?? _messages.max(length);
    _addValidator(
      'too_big',
      (value) => value.length <= length ? null : msg,
    );
    return this;
  }

  VArray<T> unique({String? message}) {
    final msg = message ?? _messages.unique;
    _addValidator('unique', (value) {
      return value.toSet().length == value.length ? null : msg;
    });
    return this;
  }

  VArray<T> contains(List<T> required, {String? message}) {
    final msg = message ?? _messages.contains;
    _addValidator('contains', (value) {
      return required.every((r) => value.contains(r)) ? null : msg;
    });
    return this;
  }

  @override
  VResult<List<T>?> safeParse(Object? value) {
    if (value == null) {
      if (_isNullable) return VSuccess<List<T>?>(null);
      if (_hasDefault) return VSuccess<List<T>?>(_defaultValue);
      if (_isOptional) return VSuccess<List<T>?>(null);

      return VFailure<List<T>?>([
        const VError(code: 'required', message: 'Required'),
      ]);
    }

    if (value is! List) {
      return VFailure<List<T>?>([
        VError(
          code: 'invalid_type',
          message:
              'Expected List<${T.toString()}>, received ${value.runtimeType}',
        ),
      ]);
    }

    final errors = <VError>[];
    final List<T> parsed = [];

    for (int i = 0; i < value.length; i++) {
      final result = _element.safeParse(value[i]);

      switch (result) {
        case VSuccess():
          parsed.add(result.value as T);
        case VFailure():
          for (final error in result.errors) {
            errors.add(error.copyWith(path: [i, ...error.path]));
          }
      }
    }

    if (errors.isNotEmpty) return VFailure<List<T>?>(errors);

    return _runPipeline(parsed);
  }
}
