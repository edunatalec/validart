/// Represents a single validation error.
///
/// Contains a machine-readable [code], a human-readable [message], and an
/// optional [path] indicating the location of the error in nested structures.
///
/// ```dart
/// final error = VError(code: 'required', message: 'Required', path: ['name']);
/// print(error.pathString); // 'name'
/// ```
final class VError {
  /// Machine-readable error code (e.g., `'required'`, `'invalid_email'`).
  final String code;

  /// Human-readable error message.
  final String message;

  /// Location path as a list of string keys and int indices.
  ///
  /// For example, `['users', 0, 'email']` represents `users[0].email`.
  final List<Object> path;

  /// Creates a [VError] with the given [code], [message], and optional [path].
  const VError({
    required this.code,
    required this.message,
    this.path = const [],
  });

  /// Creates a copy with a different [path].
  VError copyWith({List<Object>? path}) {
    return VError(
      code: code,
      message: message,
      path: path ?? this.path,
    );
  }

  /// Returns the path as a dot-separated string with bracket notation for
  /// array indices.
  ///
  /// ```dart
  /// VError(code: 'x', message: 'x', path: ['users', 0, 'email']).pathString;
  /// // 'users[0].email'
  /// ```
  String get pathString {
    final buffer = StringBuffer();

    for (int i = 0; i < path.length; i++) {
      final segment = path[i];

      if (segment is int) {
        buffer.write('[$segment]');
      } else {
        if (i > 0) buffer.write('.');
        buffer.write(segment);
      }
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VError &&
        other.code == code &&
        other.message == message &&
        _listEquals(other.path, path);
  }

  @override
  int get hashCode => Object.hash(code, message, Object.hashAll(path));

  @override
  String toString() {
    if (path.isEmpty) return 'VError($code: $message)';

    return 'VError($code at $pathString: $message)';
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;

  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }

  return true;
}

/// Exception thrown by [VType.parse] when validation fails.
///
/// Contains the list of [errors] that caused the failure.
///
/// ```dart
/// try {
///   V.string().email().parse('invalid');
/// } on VException catch (e) {
///   print(e.errors);
/// }
/// ```
class VException implements Exception {
  /// The list of validation errors.
  final List<VError> errors;

  /// Creates a [VException] with the given [errors].
  const VException(this.errors);

  @override
  String toString() {
    final messages = errors.map((e) => e.toString()).join(', ');

    return 'VException([$messages])';
  }
}
