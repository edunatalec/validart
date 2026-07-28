import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid hex color (`#FFF` or `#FFFFFF`).
class HexColorValidator extends Validator<String> {
  /// Creates a [HexColorValidator].
  const HexColorValidator();

  @override
  String get code => VStringCode.hexColor;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^#([A-Fa-f0-9]{3}|[A-Fa-f0-9]{6})$');

    return regex.hasMatch(value) ? null : {};
  }
}
