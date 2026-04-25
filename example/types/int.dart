import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.int()` — size bounds, sign, parity, divisibility,
/// primality, and the `array()` shorthand.
void runIntExamples() {
  section('VInt — bounds & sign');

  print(V.int().min(5).validate(10)); // true
  print(V.int().max(10).validate(5)); // true
  print(V.int().between(1, 10).validate(5)); // true

  print(V.int().positive().validate(1)); // true
  print(V.int().negative().validate(-1)); // true

  section('VInt — divisibility & properties');

  print(V.int().multipleOf(3).validate(9)); // true
  print(V.int().even().validate(4)); // true
  print(V.int().odd().validate(3)); // true
  print(V.int().prime().validate(7)); // true

  section('VInt — chained / arrays');

  // Chains compose left-to-right; every step must pass.
  print(V.int().positive().min(10).max(100).validate(42)); // true
  print(V.int().positive().min(10).max(100).validate(5)); // false (< 10)

  // `.array()` returns a `VArray<int>` reusing the element schema.
  print(V.int().positive().array().validate([1, 2, 3])); // true
  print(V.int().positive().array().validate([1, -2, 3])); // false
}

void main() => runIntExamples();
