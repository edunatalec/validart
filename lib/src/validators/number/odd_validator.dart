import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is odd.
class OddValidator extends Validator<int> {
  /// Creates an [OddValidator].
  const OddValidator();

  @override
  String get code => VIntCode.odd;

  @override
  Map<String, dynamic>? validate(int value) => value % 2 != 0 ? null : {};
}
