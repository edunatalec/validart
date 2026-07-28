import '../../v_code.dart';
import '../validator.dart';

/// Validates that a string is a valid NanoID.
///
/// NanoIDs use the URL-safe alphabet `[A-Za-z0-9_-]`. The default length
/// is 21 characters (matching the NanoID library default); pass [length]
/// to require a different size.
class NanoIdValidator extends Validator<String> {
  /// Creates a [NanoIdValidator].
  const NanoIdValidator({this.length = 21});

  /// Required length. Defaults to 21 (NanoID library default).
  final int length;

  @override
  String get code => VStringCode.nanoId;

  @override
  Map<String, dynamic>? validate(String value) {
    final regex = RegExp('^[A-Za-z0-9_-]{$length}\$');

    return regex.hasMatch(value) ? null : {'length': length};
  }
}
