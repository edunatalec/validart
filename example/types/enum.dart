import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.enm(...)` — validate that a value is one of the
/// declared `Enum.values`.
void runEnumExamples() {
  section('VEnum — basics');

  final colorSchema = V.enm(Color.values);

  print(colorSchema.validate(Color.red)); // true
  print(colorSchema.validate(Color.green)); // true

  // Strings, ints, etc. fail — the type itself must match.
  print(colorSchema.validate('red')); // false
  print(colorSchema.validate(0)); // false

  section('VEnum — array');

  print(colorSchema.array().validate([Color.red, Color.blue])); // true
  print(colorSchema.array().validate([Color.red, 'blue'])); // false

  section('VEnum — error message');

  // The default error names every accepted value, so the user sees
  // exactly what's allowed.
  final result = colorSchema.errors('red');
  print(result?.first.message); // contains 'red, green, blue'
}

void main() => runEnumExamples();
