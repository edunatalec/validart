/// Defines how the area code should be handled in phone number validation.
enum AreaCodeFormat {
  /// The area code is required and must be present in the phone number.
  required,

  /// The area code is optional, meaning the phone number may or may not include it.
  optional,

  /// The area code should not be included in the phone number.
  none,
}
