import '../../v_code.dart';
import '../validator.dart';

/// Validates that two fields in a map have equal values.
class EqualFieldsValidator extends Validator<Map<String, dynamic>> {
  /// Creates an [EqualFieldsValidator] with the given [field] and [other].
  const EqualFieldsValidator({required this.field, required this.other});

  /// The name of the first field.
  final String field;

  /// The name of the second field that must equal [field].
  final String other;

  @override
  String get code => VMapCode.fieldsNotEqual;

  @override
  Map<String, dynamic>? validate(Map<String, dynamic> value) =>
      value[field] == value[other] ? null : {'field': field, 'other': other};
}
