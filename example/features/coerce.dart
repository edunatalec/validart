import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.coerce.*` — accept any reasonable input and convert
/// to the target Dart type before validation. Use when the source is
/// untyped (form fields, query strings, JSON columns).
///
/// Coerce is permissive on purpose: if you want strict format checks,
/// chain `V.string().X(format: ...)` before coercion.
void runCoerceExamples() {
  section('V.coerce — primitive conversions');

  print(V.coerce.int().parse('42')); // 42
  print(V.coerce.int().parse(3.7)); // 3 (truncation)
  print(V.coerce.int().parse('-100')); // -100

  print(V.coerce.double().parse('3.14')); // 3.14
  print(V.coerce.double().parse(42)); // 42.0
  print(V.coerce.double().parse('1e3')); // 1000.0

  print(V.coerce.string().parse(42)); // '42'
  print(V.coerce.string().parse(true)); // 'true'

  print(V.coerce.bool().parse('true')); // true
  print(V.coerce.bool().parse(0)); // false
  print(V.coerce.bool().parse(1)); // true

  section('V.coerce.date — multi-format');

  // Accepts the same default formats as V.string().date():
  // ISO, BR (DD/MM/YYYY), US (MM/DD/YYYY), EU (DD.MM.YYYY).
  print(V.coerce.date().parse('2024-01-15')); // DateTime(2024, 1, 15) ISO
  print(V.coerce.date().parse('15/01/2024')); // BR
  print(V.coerce.date().parse('15.01.2024')); // EU (DD.MM.YYYY)

  section('V.coerce + downstream validation');

  // Coerce produces the typed value; then chain a validator on top.
  print(V.coerce.int().min(1).validate('42')); // true
  print(V.coerce.int().min(50).validate('42')); // false (42 < 50)

  print(V.coerce.bool().isTrue().validate(1)); // true
}

void main() => runCoerceExamples();
