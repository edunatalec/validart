import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.nullable()`, `.defaultValue(...)`, and the factory-
/// level `message:` parameter that customizes the `required` error.
/// These are the core null-handling primitives — every VType supports
/// them.
void runNullableDefaultExamples() {
  section('nullable() — accept null');

  // By default, null fails with the `required` error.
  print(V.string().validate(null)); // false
  print(V.string().nullable().validate(null)); // true

  print(V.string().nullable().parse(null)); // null

  section('defaultValue(...) — substitute on null');

  // The default goes through the rest of the pipeline. If it fails a
  // downstream validator, parse() throws — choose defaults that pass.
  print(V.string().defaultValue('fallback').parse(null)); // 'fallback'
  print(V.string().min(3).defaultValue('hello').parse(null)); // 'hello'

  // Default that fails .min(3): the error fires.
  try {
    V.string().min(3).defaultValue('').parse(null);
  } on VException catch (e) {
    print('caught: ${e.errors.first.code}'); // 'string.too_small'
  }

  section('Custom required message — factory-level message:');

  // Fires only on null input. Falls back to locale → English default.
  final terms = V.bool(message: 'You must accept the terms').isTrue();
  print(terms.errors(null)?.first.message); // 'You must accept the terms'

  // Validator-level `message:` is independent — fires on validator
  // rejection, not on null.
  print(terms.errors(false)?.first.message); // generic 'Must be true'

  section('Both message overrides on the same schema');

  final both = V
      .string(message: 'Name is required')
      .min(3, message: (n) => 'At least $n chars');
  print(both.errors(null)?.first.message); // 'Name is required'
  print(both.errors('ab')?.first.message); // 'At least 3 chars'

  section('hasDefault / defaultValueOrNull / isNullable getters');

  // Useful when introspecting a schema (e.g. building UI metadata).
  final schema = V.string().nullable().defaultValue('x');
  print(schema.isNullable); // true
  print(schema.hasDefault); // true
  print(schema.defaultValueOrNull); // 'x'
}

void main() => runNullableDefaultExamples();
