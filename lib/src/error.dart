final class VError {
  final String code;
  final String message;
  final List<Object> path;

  const VError({
    required this.code,
    required this.message,
    this.path = const [],
  });

  VError copyWith({List<Object>? path}) {
    return VError(
      code: code,
      message: message,
      path: path ?? this.path,
    );
  }

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

class VException implements Exception {
  final List<VError> errors;

  const VException(this.errors);

  @override
  String toString() {
    final messages = errors.map((e) => e.toString()).join(', ');

    return 'VException([$messages])';
  }
}
