import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.when(field, equals:, then: {...})` — conditional
/// validation. Available on both `VMap` and `VObject`. The `then`
/// block applies extra validators to the listed fields **only when**
/// `field == equals`.
void runWhenExamples() {
  section('VMap.when — single conditional branch');

  // Tax-id is required only for company accounts.
  final account = V.map({
    'type': V.string(),
    'taxId': V.string().nullable(),
  }).when('type', equals: 'company', then: {
    'taxId': V.string().min(11),
  });

  print(account.validate({'type': 'person', 'taxId': null})); // true
  print(
      account.validate({'type': 'company', 'taxId': '12345678901234'})); // true
  print(account.validate({'type': 'company', 'taxId': null})); // false

  section('VMap.when — multiple branches');

  // Person → require CPF; company → require CNPJ.
  final form = V.map({
    'type': V.string(),
    'cnpj': V.string().nullable(),
    'cpf': V.string().nullable(),
  }).when('type', equals: 'company', then: {
    'cnpj': V.string().min(14),
  }).when('type', equals: 'person', then: {
    'cpf': V.string().min(11),
  });

  print(form.validate({'type': 'company', 'cnpj': '12345678901234'})); // true
  print(form.validate({'type': 'person', 'cpf': '12345678901'})); // true
  print(form.validate({'type': 'company', 'cpf': '12345678901'})); // false

  section('VObject.when — same idea, type-safe');

  // The cleanest pattern is to declare the schema as a static final
  // on the DTO. Sign-up requires `confirm` only when `type == 'new'`.
  // Below we wire it inline for brevity.
  final signUp = V
      .object<SignUpDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .field('confirm', (d) => d.confirm, V.string())
      .when(
    'password',
    equals: 'Str0ng!Pass',
    then: {
      // Apply the equality only when password is exactly that.
      'confirm': V.string().equals('Str0ng!Pass'),
    },
  );

  print(signUp.validate(const SignUpDto(
    email: 'a@b.com',
    password: 'Str0ng!Pass',
    confirm: 'Str0ng!Pass',
  ))); // true
}

/// Examples for `.whenMatches((data) => bool, dependsOn: {...}, then: {...})`
/// — predicate-based conditional validation. Use this when [.when] is not
/// expressive enough — when the trigger depends on a comparison other than
/// `==` (`>`, `oneOf`, etc.) or on the combined value of multiple fields.
void runWhenMatchesExamples() {
  section('VMap.whenMatches — multi-field predicate');

  // Free shipping policy: heavy orders shipping inside the country need a
  // shipping note (extra text). Triggered by subtotal > 100 AND country
  // == 'BR' — neither a single equals comparison can express this.
  final order = V.map({
    'subtotal': V.double(),
    'country': V.string(),
    'note': V.string().nullable(),
  }).whenMatches(
    (m) => (m['subtotal'] as double) > 100.0 && m['country'] == 'BR',
    dependsOn: const {'subtotal', 'country'},
    then: {'note': V.string().min(3)},
  );

  print(order.validate({
    'subtotal': 50.0,
    'country': 'BR',
    'note': null,
  })); // true — predicate false (subtotal <= 100), note stays nullable

  print(order.validate({
    'subtotal': 200.0,
    'country': 'US',
    'note': null,
  })); // true — predicate false (country != BR)

  print(order.validate({
    'subtotal': 200.0,
    'country': 'BR',
    'note': 'leave at door',
  })); // true — predicate matches and note is valid

  print(order.validate({
    'subtotal': 200.0,
    'country': 'BR',
    'note': null,
  })); // false — predicate matches → note required and >= 3 chars

  section('VMap.whenMatches — non-equality operator (oneOf)');

  // Documento required only for a specific set of countries.
  final visa = V.map({
    'country': V.string(),
    'doc': V.string().nullable(),
  }).whenMatches(
    (m) => const {'BR', 'AR', 'CL'}.contains(m['country']),
    dependsOn: const {'country'},
    then: {'doc': V.string().min(8)},
  );

  print(visa.validate({'country': 'BR', 'doc': '12345678'})); // true
  print(visa.validate({'country': 'AR', 'doc': 'short'})); // false
  print(visa.validate({'country': 'US', 'doc': null})); // true

  section('VObject.whenMatches — typed predicate over the entity');

  // Strong-confirmation rule: when the password is long enough and the
  // email is on a privileged domain, require `confirm` to match exactly.
  final signUp = V
      .object<SignUpDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .field('confirm', (d) => d.confirm, V.string())
      .whenMatches(
    (d) => d.email.endsWith('@admin.com') && d.password.length >= 12,
    dependsOn: const {'email', 'password'},
    then: {'confirm': V.string().min(12)},
  );

  print(signUp.validate(const SignUpDto(
    email: 'a@admin.com',
    password: 'Str0ng!Pass99',
    confirm: 'Str0ng!Pass99',
  ))); // true

  print(signUp.validate(const SignUpDto(
    email: 'a@admin.com',
    password: 'Str0ng!Pass99',
    confirm: 'short',
  ))); // false — predicate matches → confirm must be >= 12

  print(signUp.validate(const SignUpDto(
    email: 'a@user.com',
    password: 'Str0ng!Pass',
    confirm: 'short',
  ))); // true — predicate false → confirm bypasses the extra rule
}

void main() {
  runWhenExamples();
  runWhenMatchesExamples();
}
