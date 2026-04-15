import 'package:validart/src/error.dart';

/// The result of a validation operation.
///
/// Either a [VSuccess] containing the parsed value, or a [VFailure]
/// containing the list of errors.
///
/// ```dart
/// final result = V.string().email().safeParse('user@mail.com');
///
/// switch (result) {
///   case VSuccess(:final value):
///     print(value);
///   case VFailure(:final errors):
///     print(errors);
/// }
/// ```
sealed class VResult<T> {
  /// Creates a [VResult].
  const VResult();

  /// Returns `true` if the validation passed.
  bool get isValid;

  /// Returns `true` if the validation failed.
  bool get isNotValid => !isValid;
}

/// A successful validation result containing the parsed [value].
final class VSuccess<T> extends VResult<T> {
  /// The parsed and validated value.
  final T value;

  /// Creates a [VSuccess] with the given [value].
  const VSuccess(this.value);

  @override
  bool get isValid => true;
}

/// A failed validation result containing the list of [errors].
final class VFailure<T> extends VResult<T> {
  /// The list of validation errors.
  final List<VError> errors;

  /// Creates a [VFailure] with the given [errors].
  const VFailure(this.errors);

  @override
  bool get isValid => false;

  /// Converts the errors to a `Map<String, String>` keyed by field path.
  ///
  /// Only includes the first error per path.
  ///
  /// ```dart
  /// final result = schema.safeParse(data);
  ///
  /// if (result case VFailure(:final errors)) {
  ///   final map = result.toMap(); // {'email': 'Invalid email address'}
  /// }
  /// ```
  Map<String, String> toMap() {
    final map = <String, String>{};

    for (final error in errors) {
      final key = error.pathString;

      if (key.isNotEmpty && !map.containsKey(key)) {
        map[key] = error.message;
      }
    }

    return map;
  }
}
