import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for the pluggable-pattern API on the string-domain
/// validators: `phone`, `postalCode`, `taxId`, `licensePlate`, and
/// `card`. Each accepts a non-empty list of patterns; validation passes
/// on the first match. External packages (e.g. `validart_br`) extend
/// these by implementing the corresponding base class — examples of
/// that are in `shared/fixtures.dart` (DummyTaxIdPattern, etc.).
void runPatternsExamples() {
  section('phone — multi-pattern with custom country shape');

  // Default — E.164, `+` optional.
  print(V.string().phone().validate('+14155552671')); // true
  print(V.string().phone().validate('14155552671')); // true

  // Pin the prefix shape.
  final requiredPrefix = V.string().phone(
    patterns: const [E164PhonePattern(countryCode: CountryCodeFormat.required)],
  );
  print(requiredPrefix.validate('+14155552671')); // true
  print(requiredPrefix.validate('14155552671')); // false

  final noPrefix = V.string().phone(
    patterns: const [E164PhonePattern(countryCode: CountryCodeFormat.none)],
  );
  print(noPrefix.validate('14155552671')); // true
  print(noPrefix.validate('+14155552671')); // false

  // Custom phone pattern from shared/fixtures.dart.
  final localPhone = V.string().phone(patterns: const [LocalPhonePattern()]);
  print(localPhone.validate('LOCAL:1234')); // true
  print(localPhone.validate('+5511999999999')); // false

  section('postalCode — multi-country (US / CA / UK)');

  // Single country.
  print(V
      .string()
      .postalCode(patterns: const [UsZipPattern()]).validate('94103')); // true

  // Multi-country: validation passes on the first matching pattern.
  final multiCountry = V.string().postalCode(
    patterns: const [
      UsZipPattern(),
      CaPostalCodePattern(),
      UkPostcodePattern(),
    ],
  );
  print(multiCountry.validate('94103')); // true (US)
  print(multiCountry.validate('K1A 0B1')); // true (CA)
  print(multiCountry.validate('SW1A 1AA')); // true (UK)
  print(multiCountry.validate('nope')); // false

  // ValidationMode pins formatted vs unformatted shape.
  print(V.string().postalCode(
    patterns: const [UkPostcodePattern(mode: ValidationMode.formatted)],
  ).validate('SW1A1AA')); // false (no space)
  print(V.string().postalCode(
    patterns: const [CaPostalCodePattern(mode: ValidationMode.unformatted)],
  ).validate('K1A0B1')); // true

  section('taxId — built-in patterns + custom');

  print(V
      .string()
      .taxId(patterns: const [UsSsnPattern()]).validate('123-45-6789')); // true
  print(V.string().taxId(
      patterns: const [UkNiNumberPattern()]).validate('AB123456C')); // true
  print(V
      .string()
      .taxId(patterns: const [CaSinPattern()]).validate('130-692-544')); // true

  // Custom tax-id pattern from shared/fixtures.dart.
  print(V.string().taxId(
      patterns: const [DummyTaxIdPattern()]).validate('TAX:123')); // true

  section('licensePlate — built-in + custom');

  print(V.string().licensePlate(
      patterns: const [UkPlatePattern()]).validate('AB12 CDE')); // true
  print(V.string().licensePlate(
      patterns: const [DummyPlatePattern()]).validate('ABC-1234')); // true

  section('card — brand restriction + format mode');

  // Default — any Luhn-valid number.
  print(V.string().card().validate('4532015112830366')); // true

  // Restrict to specific brands.
  final visaOrMaster = V.string().card(
    brands: const [VisaBrand(), MastercardBrand()],
  );
  print(visaOrMaster.validate('4111111111111111')); // true (Visa)
  print(visaOrMaster.validate('378282246310005')); // false (Amex)

  // Pin the input shape.
  final formattedCard = V.string().card(mode: ValidationMode.formatted);
  print(formattedCard.validate('4532 0151 1283 0366')); // true
  print(formattedCard.validate('4532015112830366')); // false (no groups)
}

void main() => runPatternsExamples();
