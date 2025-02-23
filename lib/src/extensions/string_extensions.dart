/// Provides utility extensions for `String` values.
///
/// This extension includes helper methods for handling numeric extraction
/// and detecting repeated characters in a string.
extension StringExtensions on String {
  /// Removes all non-digit characters from the string, leaving only numbers.
  ///
  /// This is useful when extracting numeric values from formatted strings,
  /// such as phone numbers, CPF, CNPJ, and other identification numbers.
  ///
  /// ### Example
  /// ```dart
  /// print("Phone: +1 (123) 456-7890".onlyDigits); // "11234567890"
  /// print("CPF: 123.456.789-09".onlyDigits); // "12345678909"
  /// ```
  ///
  /// ### Behavior
  /// - Retains only `0-9` digits.
  /// - Removes spaces, special characters, and letters.
  String get onlyDigits => replaceAll(RegExp(r'[^\d]'), '');

  /// Checks whether the string consists entirely of the same repeated character.
  ///
  /// This is useful for detecting invalid input where users enter repeated characters,
  /// such as `"00000000000"` in CPF validation or `"AAAAAAA"` in password fields.
  ///
  /// ### Example
  /// ```dart
  /// print("111111".isRepeatedCharacters); // true
  /// print("00000000000".isRepeatedCharacters); // true
  /// print("abcdef".isRepeatedCharacters); // false
  /// print("aaaBBB".isRepeatedCharacters); // false
  /// ```
  ///
  /// ### Behavior
  /// - Returns `true` if all characters in the string are identical.
  /// - Returns `false` if the string contains different characters.
  bool get isRepeatedCharacters => RegExp(r'^(.)\1*$').hasMatch(this);
}
