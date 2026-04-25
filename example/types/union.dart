import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.union([...])` — match-any across several schemas.
/// The first schema that accepts the value wins; if none do, the
/// failure aggregates every option's error so the caller can decide
/// which message to surface.
void runUnionExamples() {
  section('VUnion — basics');

  // Accept either a UUID string or a positive int.
  final idSchema = V.union([V.string().uuid(), V.int().min(1)]);
  print(idSchema.validate('550e8400-e29b-41d4-a716-446655440000')); // true
  print(idSchema.validate(42)); // true
  print(idSchema.validate('bad')); // false
  print(idSchema.validate(-5)); // false

  section('VUnion — discriminated by literal');

  // Combined with VLiteral to express tagged variants.
  final paymentMethod = V.union([
    V.literal('card'),
    V.literal('pix'),
    V.literal('bank_transfer'),
  ]);
  print(paymentMethod.validate('card')); // true
  print(paymentMethod.validate('cash')); // false

  section('VUnion — failure aggregates every option');

  // When no option matches, the failure carries the aggregated errors
  // from every branch so the caller can build a custom message.
  final result = idSchema.safeParse('not-a-uuid-and-not-an-int');
  if (result case VFailure(:final errors)) {
    print(errors.first.code); // 'union.invalid'
  }
}

void main() => runUnionExamples();
