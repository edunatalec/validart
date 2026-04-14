abstract class Validator<T> {
  final String message;

  const Validator({required this.message});

  String get code;

  String? validate(T value);
}
