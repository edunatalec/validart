import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for schema composition: `pick` / `omit` / `extend` / `merge`
/// / `partial` on `VMap`, and `pick` / `omit` / `merge` on `VObject`.
/// All of these preserve pipeline state from the source — refines,
/// equalFields, when rules, preprocessors, nullable, defaultValue.
void runCompositionExamples() {
  section('VMap.pick / .omit — narrow the surface');

  final user = V.map({
    'name': V.string().min(1),
    'email': V.string().email(),
    'age': V.int().min(0),
  });

  // pick — keep only the listed fields.
  final nameAndEmail = user.pick(['name', 'email']);
  print(nameAndEmail.validate({'name': 'Alice', 'email': 'a@b.com'})); // true

  // omit — drop the listed fields.
  final noAge = user.omit(['age']);
  print(noAge.validate({'name': 'Alice', 'email': 'a@b.com'})); // true

  section('VMap.extend — add fields to an existing schema');

  final withPassword = user.extend({'password': V.string().min(8)});
  print(
    withPassword.validate({
      'name': 'Alice',
      'email': 'a@b.com',
      'age': 30,
      'password': '12345678',
    }),
  ); // true

  section('VMap.merge — combine two schemas');

  final left = V.map({'a': V.string()});

  final right = V.map({'b': V.int()});

  final merged = left.merge(right);
  print(merged.validate({'a': 'x', 'b': 1})); // true

  section('VMap.partial — every field becomes nullable');

  // Useful for PATCH / partial-update payloads.
  final patch = user.partial();
  print(patch.validate({'name': null})); // true
  print(patch.validate({'email': 'a@b.com'})); // true (other fields absent)

  section('VMap.partial(except:) — keep selected keys required');

  // Update DTO that retains a required identifier: every field is
  // nullable except `id`, which keeps its original validator.
  final identified = V.map({
    'id': V.string().uuid(),
    'name': V.string().min(1),
    'email': V.string().email(),
  });

  final updateDto = identified.partial(except: const ['id']);
  print(
    updateDto.validate({'id': '550e8400-e29b-41d4-a716-446655440000'}),
  ); // true
  print(updateDto.validate({'name': 'Alice'})); // false (id still required)

  section('VObject — pick / omit / merge stay type-safe');

  // Schema is built once on the DTO; pick narrows the validation
  // surface without changing the input type T.
  final emailOnly = SignInDto.schema.pick(['email']);
  // The schema still expects a SignInDto — only the email field is
  // validated. (For partial / patch payloads on entities, prefer
  // VMap.partial on a derived map representation.)
  print(
    emailOnly.validate(
      const SignInDto(email: 'a@b.com', password: 'whatever'),
    ),
  ); // true

  // Compose two object schemas of the same T:
  final pwdOnly = V
      .object<SignInDto>()
      .field('password', (d) => d.password, V.string().password());
  final mergedDto = SignInDto.schema.merge(pwdOnly);
  // Now the merged schema validates BOTH .field rules from both sides.
  print(
    mergedDto.validate(
      const SignInDto(email: 'a@b.com', password: 'Str0ng!Pass'),
    ),
  ); // true
}

void main() => runCompositionExamples();
