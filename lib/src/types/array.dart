part of 'type.dart';

class VArray<T> extends VType<List<T>> {
  final VType<T> _element;
  final VArrayMessages _messages;

  VArray(
    this._element, {
    VArrayMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VArrayMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

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
    final nullResult = _nullCheck<List<T>>(_defaultValue, _hasDefault, value);
    if (nullResult != null) return nullResult;

    if (value is! List) {
      return _typeError<List<T>>('List<${T.toString()}>', value!);
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
