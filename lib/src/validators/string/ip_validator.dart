import 'package:keeper/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a string is a valid IPv4 or IPv6 address.
///
/// The `IPValidator` ensures that the provided input matches either an IPv4 or IPv6 format.
/// This is useful for validating network-related inputs, such as IP configurations, API requests,
/// or user-provided addresses.
///
/// ## Example usage:
/// ```dart
/// final validator = IPValidator(message: 'Invalid IP address');
///
/// print(validator.validate('192.168.1.1')); // null (valid)
/// print(validator.validate('255.255.255.255')); // null (valid)
/// print(validator.validate('2001:0db8:85a3:0000:0000:8a2e:0370:7334')); // null (valid)
/// print(validator.validate('invalid-ip')); // 'Invalid IP address' (invalid)
/// ```
///
/// ## Behavior:
/// - Supports both **IPv4** and **IPv6** address formats.
/// - If the input does not match either format, validation fails and returns the provided error message.
///
/// ## Supported Formats:
/// ✅ **IPv4:** Matches `XXX.XXX.XXX.XXX` where `XXX` is between 0-255.
/// ✅ **IPv6:** Matches the full 8-group hexadecimal representation (`xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx`).
///
/// ## Parameters:
/// - [message]: The error message returned if the validation fails.
class IPValidator extends PatternValidator {
  /// Creates an `IPValidator` with the given [message].
  ///
  /// - Supports both **IPv4** and **IPv6** address formats.
  /// - Uses regex patterns to ensure correctness.
  IPValidator({required super.message})
    : super(
        // Matches IPv4 addresses (e.g., 192.168.1.1, 255.255.255.255)
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
        r'(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        r'|'
        // Matches IPv6 addresses (full 8-group format)
        r'^([a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}$',
      );
}
