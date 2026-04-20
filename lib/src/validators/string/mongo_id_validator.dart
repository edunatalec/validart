import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid MongoDB ObjectId (24 hex characters).
class MongoIdValidator extends Validator<String> {
  /// Creates a [MongoIdValidator].
  const MongoIdValidator();

  @override
  String get code => VCode.mongoId;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp(r'^[0-9a-fA-F]{24}$');

    return regex.hasMatch(value) ? null : {};
  }
}
