import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.literal(...)` — accept exactly one constant value.
/// Use it inside a [VUnion] when you need to model a discriminator
/// (`type: 'admin'` vs `type: 'user'`).
void runLiteralExamples() {
  section('VLiteral — basics');

  final adminSchema = V.literal('admin');
  print(adminSchema.validate('admin')); // true
  print(adminSchema.validate('user')); // false
  print(adminSchema.validate('Admin')); // false (case-sensitive)

  section('VLiteral — discriminator inside a union');

  // `V.union([V.literal('a'), V.literal('b')])` is the idiomatic way
  // to model "this string must be one of these specific values" when
  // they aren't a Dart enum.
  final role = V.union([
    V.literal('admin'),
    V.literal('editor'),
    V.literal('viewer'),
  ]);
  print(role.validate('admin')); // true
  print(role.validate('editor')); // true
  print(role.validate('owner')); // false

  section('VLiteral — non-string literals');

  // Any equatable value works.
  print(V.literal(42).validate(42)); // true
  print(V.literal(true).validate(true)); // true
}

void main() => runLiteralExamples();
