import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid IBAN (ISO 13616) using the mod-97
/// check-digit algorithm.
///
/// Accepts letters/digits with or without spaces.
class IbanValidator extends Validator<String> {
  /// Creates an [IbanValidator].
  const IbanValidator();

  @override
  String get code => VCode.iban;

  @override
  Map<String, dynamic>? validate(String value) {
    final normalized = value.replaceAll(' ', '').toUpperCase();

    if (normalized.length < 15 || normalized.length > 34) return {};

    final shape = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$');

    if (!shape.hasMatch(normalized)) return {};

    final rearranged = normalized.substring(4) + normalized.substring(0, 4);

    final buffer = StringBuffer();

    for (final char in rearranged.split('')) {
      final codeUnit = char.codeUnitAt(0);

      if (codeUnit >= 0x30 && codeUnit <= 0x39) {
        buffer.write(char);
      } else {
        buffer.write((codeUnit - 55).toString());
      }
    }

    final numeric = buffer.toString();

    var remainder = 0;

    for (var i = 0; i < numeric.length; i += 7) {
      final end = (i + 7 < numeric.length) ? i + 7 : numeric.length;
      final chunk = '$remainder${numeric.substring(i, end)}';

      remainder = int.parse(chunk) % 97;
    }

    return remainder == 1 ? null : {};
  }
}
