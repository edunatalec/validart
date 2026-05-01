import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.string()` — covers basic checks, format checks,
/// numeric strings, the pre-processing transforms, and the pluggable
/// pattern entry points (`phone`, `postalCode`, `taxId`, `licensePlate`,
/// `card`).
void runStringExamples() {
  section('VString — basics');

  // Membership / size.
  print(V.string().notEmpty().validate('hello')); // true
  print(V.string().notEmpty().validate('')); // false
  print(V.string().min(3).validate('abc')); // true
  print(V.string().max(5).validate('hello')); // true
  print(V.string().length(4).validate('test')); // true

  // Substring / prefix / suffix / equality.
  print(V.string().contains('world').validate('hello world')); // true
  print(V.string().startsWith('hello').validate('hello world')); // true
  print(V.string().endsWith('.dart').validate('main.dart')); // true
  print(V.string().equals('exact').validate('exact')); // true

  // Character classes.
  print(V.string().alpha().validate('abcXYZ')); // true
  print(V.string().alphanumeric().validate('abc123')); // true
  print(V.string().slug().validate('hello-world')); // true

  section('VString — formats');

  print(V.string().email().validate('user@example.com')); // true
  print(V.string().url().validate('https://example.com')); // true
  print(V.string().url().validate('ftp://example.com')); // false
  print(V.string().url(schemes: const {'http', 'https', 'ftp'}).validate(
      'ftp://example.com')); // true
  print(V.string().url(schemes: const {}).validate('google.com')); // true
  print(V
      .string()
      .url(schemes: const {}).validate('https://www.google.com/foo')); // true
  print(V.string().url(hostOnly: true).validate('https://example.com')); // true
  print(V
      .string()
      .url(hostOnly: true)
      .validate('https://example.com/path')); // false

  // .domain() — shortcut for "host only, no scheme, no path".
  print(V.string().domain().validate('www.google.com')); // true
  print(V.string().domain().validate('localhost:8080')); // true
  print(V.string().domain().validate('https://google.com')); // false (scheme)
  print(V.string().domain().validate('google.com/foo')); // false (path)

  print(V.string().uuid().validate('550e8400-e29b-41d4-a716-446655440000'));
  print(V
      .string()
      .uuid(version: UuidVersion.v7)
      .validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9')); // true

  print(V.string().ip().validate('192.168.1.1')); // true
  print(V.string().pattern(r'^\d{3}$').validate('123')); // true

  // Date — multi-format default + strict format.
  print(V.string().date().validate('2024-01-15')); // true (ISO)
  print(V.string().date().validate('15/01/2024')); // true (BR)
  print(V.string().date(format: 'DD/MM/YYYY').validate('15/01/2024')); // true
  print(V.string().date(format: 'DD/MM/YYYY').validate('2024-01-15')); // false

  // Time.
  print(V.string().time().validate('14:30')); // true
  print(V.string().time().validate('14:30:59')); // true

  section('VString — numeric / encoding');

  // integer / numeric: keep the value as String, only validate shape.
  print(V.string().integer().validate('42')); // true
  print(V.string().integer().validate('-42')); // true
  print(V.string().integer().validate('3.14')); // false
  print(V.string().numeric().validate('3.14')); // true
  print(V.string().numeric().validate('42e3')); // true (scientific)
  print(V.string().numeric().validate('NaN')); // false
  print(V.string().numeric().validate('Infinity')); // false

  print(V.string().base64().validate('SGVsbG8=')); // true
  print(V.string().hexColor().validate('#FF0000')); // true
  print(V.string().mac().validate('AA:BB:CC:DD:EE:FF')); // true
  print(V.string().semver().validate('1.2.3-alpha+build')); // true
  print(V.string().mongoId().validate('507f1f77bcf86cd799439011')); // true
  print(V.string().iban().validate('GB82 WEST 1234 5698 7654 32')); // true
  print(V.string().json().validate('{"a":1}')); // true

  // Compact identifiers.
  print(V.string().ulid().validate('01ARZ3NDEKTSV4RRFFQ69G5FAV')); // true
  print(V.string().nanoId().validate('V1StGXR8_Z5jdHi6B-myT')); // true
  print(V.string().nanoId(length: 10).validate('V1StGXR8_Z')); // true

  section('VString — domain validators');

  // Password — default: 8+ chars, upper/lower/digit/special.
  print(V.string().password().validate('Str0ng!Pass')); // true
  print(V.string().password().validate('Str0ng_Pass')); // false
  print(V
      .string()
      .password(specialChars: r'!@#$%^&*()-_+=<>?')
      .validate('Str0ng_Pass')); // true

  // JWT / CVV.
  print(V.string().jwt().validate('eyJh.eyJz.SflKx')); // true
  print(V.string().cvv().validate('123')); // true

  // Card — Luhn-valid by default; restrict to brands; or pin shape.
  print(V.string().card().validate('4532015112830366')); // true
  print(V.string().card().validate('4111 1111 1111 1111')); // true (masked)

  final visaOrMaster = V.string().card(
    brands: const [VisaBrand(), MastercardBrand()],
  );
  print(visaOrMaster.validate('4111111111111111')); // true (Visa)
  print(visaOrMaster.validate('5555555555554444')); // true (Mastercard)
  print(visaOrMaster.validate('378282246310005')); // false (Amex)

  final formattedCard = V.string().card(mode: ValidationMode.formatted);
  print(formattedCard.validate('4532 0151 1283 0366')); // true
  print(formattedCard.validate('4532015112830366')); // false

  // Phone — default E.164, `+` optional.
  print(V.string().phone().validate('+14155552671')); // true
  print(V.string().phone().validate('14155552671')); // true

  // Postal code / tax ID / license plate — built-in patterns.
  print(V
      .string()
      .postalCode(patterns: const [UsZipPattern()]).validate('94103')); // true
  print(V
      .string()
      .taxId(patterns: const [UsSsnPattern()]).validate('123-45-6789')); // true
  print(V.string().licensePlate(
      patterns: const [UkPlatePattern()]).validate('AB12 CDE')); // true

  // Multi-country — match-any: pass several patterns to the same call.
  final multiCountryPostal = V.string().postalCode(
    patterns: const [
      UsZipPattern(),
      CaPostalCodePattern(),
      UkPostcodePattern(),
    ],
  );
  print(multiCountryPostal.validate('94103')); // true (US)
  print(multiCountryPostal.validate('K1A 0B1')); // true (CA)
  print(multiCountryPostal.validate('SW1A 1AA')); // true (UK)
  print(multiCountryPostal.validate('nope')); // false

  // Custom pluggable pattern — defined in shared/fixtures.dart.
  print(V.string().taxId(
      patterns: const [DummyTaxIdPattern()]).validate('TAX:123')); // true

  section('VString — pre-processing');

  // Pre-processors run before validation regardless of chain order.
  print(V.string().trim().parse('  hello  ')); // 'hello'
  print(V.string().toLowerCase().parse('HELLO')); // 'hello'
  print(V.string().toUpperCase().parse('hello')); // 'HELLO'
  print(V.string().toPascalCase().parse('hello world')); // 'HelloWorld'
  print(V.string().toCamelCase().parse('hello_world')); // 'helloWorld'
  print(V.string().toSnakeCase().parse('HelloWorld')); // 'hello_world'
  print(V.string().toScreamingSnakeCase().parse('helloWorld')); // 'HELLO_WORLD'
  print(V.string().toSlug().parse('My Blog Post!')); // 'my-blog-post'

  // Accents — stripped by default, preserved with keepAccents.
  print(V.string().toSlug().parse('São João')); // 'sao-joao'
  print(V.string().toSlug(keepAccents: true).parse('São João')); // 'são-joão'
}

void main() => runStringExamples();
