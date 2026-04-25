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

void main() => runWhenExamples();
