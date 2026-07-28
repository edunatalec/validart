import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid IPv4 or IPv6 address.
class IpValidator extends Validator<String> {
  /// Creates an [IpValidator].
  const IpValidator();

  @override
  String get code => VStringCode.ip;

  @override
  Map<String, dynamic>? validate(String value) {
    final ipv4 = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );

    final ipv6 = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    return (ipv4.hasMatch(value) || ipv6.hasMatch(value)) ? null : {};
  }
}
