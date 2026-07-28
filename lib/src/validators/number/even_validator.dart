import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is even.
class EvenValidator extends Validator<int> {
  /// Creates an [EvenValidator].
  const EvenValidator();

  @override
  String get code => VIntCode.even;

  @override
  Map<String, dynamic>? validate(int value) => value % 2 == 0 ? null : {};
}
