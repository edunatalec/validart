import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that two fields of a [T] instance, read through the provided
/// extractors, compare equal via `==`.
class ObjectEqualFieldsValidator<T> extends Validator<T> {
  /// Name of the first field being compared.
  final String fieldA;

  /// Name of the second field being compared.
  final String fieldB;

  /// Extractor for the first field value.
  final Object? Function(T instance) extractorA;

  /// Extractor for the second field value.
  final Object? Function(T instance) extractorB;

  /// Creates an [ObjectEqualFieldsValidator] with the two field names and
  /// their extractors.
  const ObjectEqualFieldsValidator({
    required this.fieldA,
    required this.fieldB,
    required this.extractorA,
    required this.extractorB,
  });

  @override
  String get code => VObjectCode.fieldsNotEqual;

  @override
  Map<String, dynamic>? validate(T value) =>
      extractorA(value) == extractorB(value)
          ? null
          : {'field': fieldA, 'other': fieldB};
}
