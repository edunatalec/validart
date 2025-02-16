/// Defines the format requirement for country codes in phone number validation.
enum CountryCodeFormat {
  /// The country code is mandatory (e.g., "+1 123-456-7890").
  required,

  /// The country code is optional (e.g., "123-456-7890" or "+1 123-456-7890" are both valid).
  optional,

  /// The country code is not allowed (e.g., "123-456-7890" is valid, but "+1 123-456-7890" is not).
  none,
}
