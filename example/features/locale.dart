import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.setLocale(...)` — overriding error messages per
/// schema, per type, or globally. The lookup chain is:
///   custom prefixed → custom generic → default prefixed → default
///   generic → raw code.
void runLocaleExamples() {
  section('V.setLocale — global overrides');

  V.setLocale(const VLocale({
    'string.email': 'Email inválido',
    'positive': 'Deve ser positivo',
    'required': 'Campo obrigatório',
  }));

  print(V.string().email().errors('bad')?.first.message);
  // 'Email inválido'

  print(V.int().positive().errors(-1)?.first.message);
  // 'Deve ser positivo'

  section('Type-specific overrides — flat and nested coexist');

  V.setLocale(const VLocale({
    // Generic fallback (used when no type-specific entry matches).
    'required': 'Campo obrigatório',

    // Nested form — affects VString only.
    'string': {'required': 'Texto obrigatório'},

    // Flat form — affects VInt only.
    'int.required': 'Número obrigatório',
  }));

  print(V.string().errors(null)?.first.message); // 'Texto obrigatório'
  print(V.int().errors(null)?.first.message); // 'Número obrigatório'
  print(V.bool().errors(null)?.first.message); // 'Campo obrigatório' (fallback)

  section('Per-schema and per-validator message overrides');

  // Reset the locale so the test below isolates the override behavior.
  V.setLocale(const VLocale());

  // Factory-level `message:` only fires for the `required` error
  // (null input). Validator-level `message:` fires when that
  // validator rejects a non-null value. They can coexist.
  final both = V
      .string(message: 'Name is required')
      .min(3, message: (n) => 'At least $n chars');
  print(both.errors(null)?.first.message); // 'Name is required'
  print(both.errors('ab')?.first.message); // 'At least 3 chars'

  section('Manual translation via V.t');

  // The same lookup machinery is exposed for custom validators or
  // tooling that needs to produce a translated message outside the
  // pipeline.
  print(V.t(VStringCode.email)); // 'Invalid email address' (default)
}

void main() => runLocaleExamples();
