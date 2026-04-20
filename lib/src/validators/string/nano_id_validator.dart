import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a valid NanoID.
///
/// NanoIDs use the URL-safe alphabet `[A-Za-z0-9_-]`. The default length
/// is 21 characters (matching the NanoID library default); pass [length]
/// to require a different size.
class NanoIdValidator extends Validator<String> {
  /// Required length. Defaults to 21 (NanoID library default).
  final int length;

  /// Creates a [NanoIdValidator].
  const NanoIdValidator({this.length = 21});

  @override
  String get code => VCode.nanoId;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp('^[A-Za-z0-9_-]{$length}\$');

    return regex.hasMatch(value) ? null : {'length': length};
  }
}
