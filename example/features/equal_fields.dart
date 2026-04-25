import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.equalFields(a, b)` — declarative cross-field equality.
/// Available on both `VMap` and `VObject`. The canonical use case is
/// password confirmation. Emits a root-level error (path is empty), so
/// it surfaces via [VFailure.rootMessages] rather than `toMap()`.
void runEqualFieldsExamples() {
  section('VMap.equalFields — password confirmation');

  final register = V.map({
    'password': V.string().min(8),
    'confirm': V.string(),
  }).equalFields('confirm', 'password');

  print(register.validate({
    'password': '12345678',
    'confirm': '12345678',
  })); // true

  print(register.validate({
    'password': '12345678',
    'confirm': 'different',
  })); // false

  section('VMap.equalFields — error lands in rootMessages');

  final result = register.safeParse({
    'password': '12345678',
    'confirm': 'different',
  });
  if (result case VFailure() && final f) {
    print(f.toMap()); // {} — equalFields error is root-level
    print(f.rootMessages()); // [confirm must be equal to password]
  }

  section('VObject.equalFields — type-safe sign-up');

  // SignUpDto.schema (in shared/fixtures.dart) chains
  // .equalFields('password', 'confirm') on the object schema.
  print(SignUpDto.schema.validate(const SignUpDto(
    email: 'a@b.com',
    password: 'Str0ng!Pass',
    confirm: 'Str0ng!Pass',
  ))); // true

  print(SignUpDto.schema.validate(const SignUpDto(
    email: 'a@b.com',
    password: 'Str0ng!Pass',
    confirm: 'mismatch',
  ))); // false

  section('VMap.equalFields — custom message');

  final custom = V.map({
    'a': V.string(),
    'b': V.string(),
  }).equalFields('a', 'b', message: 'Fields must match');

  final out = custom.errors({'a': 'x', 'b': 'y'});
  print(out?.first.message); // 'Fields must match'
}

void main() => runEqualFieldsExamples();
