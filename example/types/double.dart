import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.double()` — bounds, sign, finiteness, and the
/// `decimal` / `integer` predicates that test the fractional part.
void runDoubleExamples() {
  section('VDouble — bounds & sign');

  print(V.double().min(1.5).validate(2.0)); // true
  print(V.double().max(9.9).validate(5.0)); // true
  print(V.double().between(1.0, 10.0).validate(5.5)); // true

  print(V.double().positive().validate(0.1)); // true
  print(V.double().negative().validate(-0.1)); // true

  section('VDouble — finiteness & shape');

  // `.finite()` rejects NaN / ±Infinity.
  print(V.double().finite().validate(3.14)); // true
  print(V.double().finite().validate(double.infinity)); // false

  // `.decimal()` requires a non-zero fractional part. `.integer()`
  // requires a whole number (3.0 passes, 3.14 fails).
  print(V.double().decimal().validate(3.14)); // true
  print(V.double().integer().validate(3.0)); // true
  print(V.double().integer().validate(3.14)); // false

  section('VDouble — multipleOf & arrays');

  print(V.double().multipleOf(0.5).validate(1.5)); // true

  // Element schema reused via `.array()`.
  print(V.double().finite().array().validate([1.0, 2.5])); // true
  print(V.double().finite().array().validate([1.0, double.nan])); // false
}

void main() => runDoubleExamples();
