import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string has exactly [length] characters.
class LengthValidator extends Validator<String> {
  /// The exact required length.
  final int length;

  /// Creates a [LengthValidator] with the given [length].
  const LengthValidator({required this.length});

  @override
  String get code => VStringCode.length;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length == length ? null : {'length': length};
}
