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

  /// Alias for [toMapFirst]. Kept for backwards compatibility — new
  /// code should prefer [toMapFirst] (explicitly lossy) or [toMapAll]
  /// (preserves every error per field).
  Map<String, String> toMap() => toMapFirst();

  /// Converts the errors to a `Map<String, String>` keyed by field
  /// path, **keeping only the first error per path**. Errors with an
  /// empty path are intentionally excluded — use [rootMessages] to
  /// retrieve those, or iterate [errors] directly to handle both at
  /// once. Errors land here when the validator that emitted them was
  /// scoped to a specific field path: declared field validators
  /// (`V.map({'x': ...})`), `refineField(check, path: 'x')`, and
  /// `add(validator, path: ['x'])` / `addAsync(..., path: ['x'])`.
  ///
  /// Use [toMapFirst] when one error per input is enough (typical UI
  /// where the input renders a single inline message). Use [toMapAll]
  /// when you want every violation surfaced (e.g., a help panel that
  /// lists all rules a field broke).
  ///
  /// ```dart
  /// final result = schema.safeParse(data);
  ///
  /// if (result case VFailure(:final errors)) {
  ///   final map = result.toMapFirst(); // {'email': 'Invalid email address'}
  /// }
  /// ```
  Map<String, String> toMapFirst() {
    final map = <String, String>{};

    for (final error in errors) {
      final key = error.pathString;

      if (key.isNotEmpty && !map.containsKey(key)) {
        map[key] = error.message;
      }
    }

    return map;
  }

  /// Converts the errors to a `Map<String, List<String>>` keyed by
  /// field path, preserving **every** error per field in registration
  /// order. Errors with an empty path are excluded — use
  /// [rootMessages] for those.
  ///
  /// Use this when a single field can break multiple rules and you
  /// want all of them in the UI (e.g., password requirements panel).
  /// For one-message-per-field flows, use [toMapFirst] instead.
  ///
  /// ```dart
  /// final schema = V.map({
  ///   'pwd': V.string().min(8).pattern(r'\d').pattern(r'[A-Z]'),
  /// });
  /// final result = schema.safeParse({'pwd': 'a'});
  ///
  /// if (result case VFailure() && final f) {
  ///   final all = f.toMapAll();
  ///   // {'pwd': ['Must be at least 8 characters', 'Invalid pattern', ...]}
  /// }
  /// ```
  Map<String, List<String>> toMapAll() {
    final map = <String, List<String>>{};

    for (final error in errors) {
      final key = error.pathString;

      if (key.isNotEmpty) {
        (map[key] ??= <String>[]).add(error.message);
      }
    }

    return map;
  }

  /// Returns the messages of every root-level error — i.e. errors with
  /// an empty `path`. Producers include `refine` / `refineAsync` and
  /// `equalFields` on a container, `add(validator)` / `addAsync(...)`
  /// without a `path:` argument on any schema, and any validator on a
  /// primitive schema used as the root (`V.string().min(3).safeParse(x)`).
  /// Anything scoped to a specific field via `refineField(path: 'x')` or
  /// `add(..., path: ['x'])` lands in [toMap] instead.
  ///
  /// Use this alongside [toMap] when your form has both per-field
  /// inputs (rendered with the field error inline) AND form-wide rules
  /// (rendered as a banner / summary line). The list preserves the
  /// order in which the underlying validators emitted their errors and
  /// is empty when no root-level error exists.
  ///
  /// ```dart
  /// final schema = V.map({
  ///   'startDate': V.date(),
  ///   'endDate': V.date(),
  /// }).refine(
  ///   (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
  ///   message: 'endDate must be after startDate',
  /// );
  ///
  /// final result = schema.safeParse({
  ///   'startDate': DateTime(2026, 5, 1),
  ///   'endDate': DateTime(2026, 4, 1),
  /// });
  ///
  /// if (result case VFailure() && final f) {
  ///   final fieldErrors = f.toMap();          // {} — no field-level errors
  ///   final formErrors = f.rootMessages();    // ['endDate must be after ...']
  /// }
  /// ```
  List<String> rootMessages() {
    return [
      for (final error in errors)
        if (error.path.isEmpty) error.message,
    ];
  }
}
