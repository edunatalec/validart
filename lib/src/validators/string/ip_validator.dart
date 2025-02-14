import 'package:keeper/src/validators/string/pattern_validator.dart';

class IPValidator extends PatternValidator {
  IPValidator({required super.message})
    : super(
        r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$|'
        r'^([a-fA-F0-9]{1,4}:){7}[a-fA-F0-9]{1,4}$',
      );
}
