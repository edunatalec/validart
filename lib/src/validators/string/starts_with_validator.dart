import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string starts with the given [prefix].
class StartsWithValidator extends Validator<String> {
  /// Creates a [StartsWithValidator] with the given [prefix].
  const StartsWithValidator({required this.prefix});

  /// The prefix the string must start with.
  final String prefix;

  @override
  String get code => VStringCode.startsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith(prefix) ? null : {'prefix': prefix};
}
