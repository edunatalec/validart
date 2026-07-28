import '../../v_code.dart';
import '../validator.dart';

/// Validates that a number is positive.
class PositiveValidator<T extends num> extends Validator<T> {
  /// Creates a [PositiveValidator].
  const PositiveValidator();

  @override
  String get code => VNumberCode.positive;

  @override
  Map<String, dynamic>? validate(T value) => value > 0 ? null : {};
}
