abstract class Validator<T> {
  const Validator();

  String get code;

  Map<String, dynamic>? validate(T value);
}
