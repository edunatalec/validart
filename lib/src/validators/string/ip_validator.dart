import 'package:validart/src/validators/validator.dart';

class IpValidator extends Validator<String> {
  const IpValidator({required super.message});

  @override
  String get code => 'invalid_ip';

  @override
  String? validate(String value) {
    final ipv4 = RegExp(
        r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$');
    final ipv6 = RegExp(r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$');
    return (ipv4.hasMatch(value) || ipv6.hasMatch(value)) ? null : message;
  }
}
