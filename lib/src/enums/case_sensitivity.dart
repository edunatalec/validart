/// Defines case sensitivity behavior for string validations.
enum CaseSensitivity {
  /// The validation is case-sensitive (e.g., "Hello" != "hello").
  sensitive,

  /// The validation is case-insensitive (e.g., "Hello" == "hello").
  insensitive,
}
