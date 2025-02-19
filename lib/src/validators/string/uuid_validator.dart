import 'package:validart/src/enums/uuid_version.dart';
import 'package:validart/src/validators/string/pattern_validator.dart';

/// A validator that checks whether a given string is a valid UUID of a specified version.
///
/// The `UUIDValidator` ensures that the input string follows the correct UUID format
/// based on the specified version (`v1`, `v3`, `v4`, or `v5`).
///
/// ### Example
/// ```dart
/// final uuidV4Validator = UUIDValidator();
///
/// print(uuidV4Validator.validate('550e8400-e29b-41d4-a716-446655440000')); // null (valid)
/// print(uuidV4Validator.validate('invalid-uuid')); // 'Invalid UUID (expected version v4)' (invalid)
///
/// final uuidV1Validator = UUIDValidator(version: UUIDVersion.v1);
///
/// print(uuidV1Validator.validate('550e8400-e29b-11d4-a716-446655440000')); // null (valid)
/// print(uuidV1Validator.validate('550e8400-e29b-41d4-a716-446655440000')); // 'Invalid UUID (expected version v1)' (invalid)
/// ```
///
/// ## Parameters:
/// - [message]: Custom error message. If not provided, a default message is used.
/// - [version]: The UUID version to validate against (defaults to `UUIDVersion.v4`).
///
/// ## UUID Versions:
/// - **v1**: Time-based UUIDs.
/// - **v3**: Namespace-based UUIDs (MD5 hashing).
/// - **v4**: Randomly generated UUIDs (default).
/// - **v5**: Namespace-based UUIDs (SHA-1 hashing).
class UUIDValidator extends PatternValidator {
  /// Creates a `UUIDValidator` that checks if a string is a valid UUID of the specified [version].
  ///
  /// - Defaults to validating `UUIDVersion.v4` if no version is specified.
  /// - If [message] is not provided, a default message including the expected version is used.
  UUIDValidator({required String message, UUIDVersion version = UUIDVersion.v4})
      : super(version.pattern, message: message);
}
