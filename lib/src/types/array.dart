part of 'type.dart';

class VArray<T> extends VType<List<T>> {
  final VType<T> _element;

  VArray(this._element);

  VArray<T> min(int length, {String Function(int)? message}) {
    add(MinLengthListValidator<T>(min: length), message: message?.call(length));
    return this;
  }

  VArray<T> max(int length, {String Function(int)? message}) {
    add(MaxLengthListValidator<T>(max: length), message: message?.call(length));
    return this;
  }

  VArray<T> unique({String? message}) {
    add(UniqueValidator<T>(), message: message);
    return this;
  }

  VArray<T> contains(List<T> required, {String? message}) {
    add(ContainsAllValidator<T>(required: required), message: message);
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
