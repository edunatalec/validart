import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that all elements in a list are unique.
class UniqueValidator<T> extends Validator<List<T>> {
  /// Creates a [UniqueValidator].
  const UniqueValidator();

  @override
  String get code => VArrayCode.unique;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      value.toSet().length == value.length ? null : {};
}
