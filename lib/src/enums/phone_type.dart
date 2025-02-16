/// Represents different phone number formats for various countries,
/// including their required pattern, area code, and country code format.
enum PhoneType {
  /// Brazil phone number format (e.g., "(11) 98765-4321" or "11 98765-4321").
  brazil(
    pattern: r'\d{5}-\d{4}',
    areaCode: r'\(?\d{2}\)?\s',
    countryCode: r'\+55\s',
  ),

  /// USA phone number format (e.g., "+1 123-456-7890" or "(123) 456-7890").
  usa(
    pattern: r'\d{3}-\d{4}',
    areaCode: r'\(?\d{3}\)?\s|\d{3}-',
    countryCode: r'\+1\s',
  ),

  /// Argentina phone number format (e.g., "+54 11 1234-5678" or "11 1234-5678").
  argentina(
    pattern: r'\d{4}-?\d{4}',
    areaCode: r'\(?\d{2,4}\)?\s',
    countryCode: r'\+54\s',
  ),

  /// Germany phone number format (e.g., "+49 30 123456" or "030 123456").
  germany(
    pattern: r'\d{3,8}',
    areaCode: r'\(?\d{2,5}\)?\s',
    countryCode: r'\+49\s',
  ),

  /// China phone number format (e.g., "+86 21 1234 5678" or "021 1234 5678").
  china(
    pattern: r'\d{4}\s?\d{4}',
    areaCode: r'\d{2,3}\s',
    countryCode: r'\+86\s',
  ),

  /// Japan phone number format (e.g., "+81 3-1234-5678" or "03-1234-5678").
  japan(
    pattern: r'\d{4}-?\d{4}',
    areaCode: r'\d{1,2}-',
    countryCode: r'\+81\s',
  ),

  /// General international phone number format supporting various country codes.
  international(
    pattern: r'\d{3,5}(\s|-)\d{3,5}',
    areaCode: r'\d{1,5}(\s|-)',
    countryCode: r'\+\d{1,3}\s',
  );

  /// The regular expression pattern for validating the local phone number.
  final String pattern;

  /// The regular expression pattern for validating the area code.
  final String areaCode;

  /// The regular expression pattern for validating the country code.
  final String countryCode;

  /// Constructor for defining country-specific phone number formats.
  const PhoneType({
    required this.pattern,
    required this.areaCode,
    required this.countryCode,
  });
}
