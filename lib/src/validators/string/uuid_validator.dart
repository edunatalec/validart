import 'package:keeper/src/enums/uuid_version.dart';
import 'package:keeper/src/validators/string/pattern_validator.dart';

class UUIDValidator extends PatternValidator {
  UUIDValidator({String? message, UUIDVersion version = UUIDVersion.v4})
    : super(
        version.pattern,
        message: message ?? 'Invalid UUID (expected version ${version.name})',
      );
}
