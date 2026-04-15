import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string starts with the given [prefix].
class StartsWithValidator extends Validator<String> {
  /// The prefix the string must start with.
  final String prefix;

  /// Creates a [StartsWithValidator] with the given [prefix].
  const StartsWithValidator({required this.prefix});

  @override
  String get code => VCode.startsWith;

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith(prefix) ? null : {'prefix': prefix};
}
