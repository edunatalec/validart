import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.bool()` — the canonical use case is "must be true"
/// for things like Terms-and-Conditions checkboxes.
void runBoolExamples() {
  section('VBool — basics');

  // `.isTrue()` / `.isFalse()` add a hard equality validator.
  print(V.bool().isTrue().validate(true)); // true
  print(V.bool().isTrue().validate(false)); // false
  print(V.bool().isFalse().validate(false)); // true

  section('VBool — message customization');

  // Factory-level `message:` only fires on null input (the required
  // error). Validator-level `message:` fires when the validator rejects.
  final terms = V.bool(message: 'You must accept the terms').isTrue();
  print(terms.errors(null)?.first.message); // 'You must accept the terms'
  print(terms.errors(false)?.first.message); // generic 'Must be true'

  section('VBool — arrays');

  print(V.bool().array().validate([true, false])); // true
  print(V.bool().isTrue().array().validate([true, true])); // true
  print(V.bool().isTrue().array().validate([true, false])); // false
}

void main() => runBoolExamples();
