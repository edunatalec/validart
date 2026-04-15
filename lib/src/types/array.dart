part of 'type.dart';

/// Validates `List<T>` values, applying the element schema to each item.
///
/// Errors from individual elements include the array index in their path.
///
/// ```dart
/// final schema = V.string().email().array().min(1);
/// schema.parse(['user@mail.com']); // ['user@mail.com']
/// ```
class VArray<T> extends VType<List<T>> {
  final VType<T> _element;

  /// Creates an array validator with the given element [_element] schema.
  VArray(this._element);

  /// Validates that the list has at least [length] elements.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().array().min(2).validate(['a', 'b']); // true
  /// V.string().array().min(2).validate(['a']);       // false
  /// ```
  VArray<T> min(int length, {String Function(int)? message}) {
    add(MinLengthListValidator<T>(min: length), message: message?.call(length));
    return this;
  }

  /// Validates that the list has at most [length] elements.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.string().array().max(3).validate(['a', 'b']); // true
  /// V.string().array().max(1).validate(['a', 'b']); // false
  /// ```
  VArray<T> max(int length, {String Function(int)? message}) {
    add(MaxLengthListValidator<T>(max: length), message: message?.call(length));
    return this;
  }

  /// Validates that all elements in the list are unique.
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().array().unique().validate([1, 2, 3]); // true
  /// V.int().array().unique().validate([1, 1, 2]); // false
  /// ```
  VArray<T> unique({String? message}) {
    add(UniqueValidator<T>(), message: message);
    return this;
  }

  /// Validates that the list contains all elements from [required].
  ///
  /// Runs in the validation phase.
  ///
  /// ```dart
  /// V.int().array().contains([1, 2]).validate([1, 2, 3]); // true
  /// V.int().array().contains([1, 2]).validate([1, 3]);     // false
  /// ```
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
