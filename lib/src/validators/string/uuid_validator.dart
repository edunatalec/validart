import 'package:keeper/src/validators/string/pattern_validator.dart';

class UUIDValidator extends PatternValidator {
  UUIDValidator({required super.message})
    : super(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
}
