abstract class KValidator<T> {
  final String message;

  KValidator({required this.message});

  String? validate(T? value);
}
