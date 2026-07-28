import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string has exactly [length] characters.
class LengthValidator extends Validator<String> {
  /// Creates a [LengthValidator] with the given [length].
  const LengthValidator({required this.length});

  /// The exact required length.
  final int length;

  @override
  String get code => VStringCode.length;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.length == length ? null : {'length': length};
}
