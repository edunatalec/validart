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
    _add(MinLengthListValidator(
      min: length,
      message: message?.call(length) ?? _messages.min(length),
    ));
    return this;
  }

  VArray<T> max(int length, {String Function(int)? message}) {
    _add(MaxLengthListValidator(
      max: length,
      message: message?.call(length) ?? _messages.max(length),
    ));
    return this;
  }

  VArray<T> unique({String? message}) {
    _add(UniqueValidator(message: message ?? _messages.unique));
    return this;
  }

  VArray<T> contains(List<T> required, {String? message}) {
    _add(ContainsAllValidator(
      required: required,
      message: message ?? _messages.contains,
    ));
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
