import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a list contains all [required] elements.
class ContainsAllValidator<T> extends Validator<List<T>> {
  /// The elements that must be present in the list.
  final List<T> required;

  /// Creates a [ContainsAllValidator] with the given [required] elements.
  const ContainsAllValidator({required this.required});

  @override
  String get code => VArrayCode.containsAll;

  @override
  Map<String, dynamic>? validate(List<T> value) =>
      required.every((r) => value.contains(r)) ? null : {};
}
