import 'dart:async';

import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.transform<O>(...)` and `.transformAsync<O>(...)` —
/// post-processing that changes the OUTPUT type after validation
/// succeeds. Different from `preprocess`, which reshapes the raw input
/// BEFORE validation.
void runTransformExamples() {
  section('transform<O> — change the output type');

  // `parse('hello')` would normally return `'hello'`. With transform
  // it returns `5` (the length).
  final length = V.string().transform<int>((s) => s.length);
  print(length.parse('hello')); // 5
  print(length.parse('hi')); // 2

  section('transform — runs AFTER validation');

  // Email validation runs first; transform sees only the validated
  // value. Pre-validation rejection means the transform never fires.
  final emailDomain =
      V.string().email().transform<String>((s) => s.split('@')[1]);
  print(emailDomain.parse('user@example.com')); // 'example.com'
  print(emailDomain.validate('not-an-email')); // false (rejected by .email())

  section('transform — chained with refine');

  // After validation but before transform, you can refine on the
  // pre-transform type. The transform output is final.
  final yesNoToBool = V
      .string()
      .refine((s) => s == 'yes' || s == 'no')
      .transform<bool>((s) => s == 'yes');
  print(yesNoToBool.parse('yes')); // true
  print(yesNoToBool.parse('no')); // false
  print(yesNoToBool.validate('maybe')); // false

  section('transformAsync — async post-processing');

  // Useful when the transformation itself needs IO (lookup a record by
  // id, hit an API). Makes the schema async-only.
  final loadId = V.string().uuid().transformAsync<int>((id) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    // Pretend this is a DB lookup that returns the row id.
    return id.length;
  });

  unawaited(() async {
    print(await loadId.parseAsync('550e8400-e29b-41d4-a716-446655440000'));
    // 36 (the UUID length)
  }());

  section('transform on a transformed schema (chain)');

  // Two transforms compose: '4' → 4 (int) → 8 (doubled).
  final parseAndDouble = V
      .string()
      .pattern(r'^\d+$')
      .transform<int>(int.parse)
      .transform<int>((n) => n * 2);
  print(parseAndDouble.parse('4')); // 8
}

void main() => runTransformExamples();
