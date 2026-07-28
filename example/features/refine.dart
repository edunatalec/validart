import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.refine(...)`, `.refineField(...)` (VMap/VObject), and
/// `.refine(check, dependsOn: {...})` for error-aggregation control.
void runRefineExamples() {
  section('refine — primitive predicate');

  final evenLen = V.string().refine(
        (v) => v.length.isEven,
        message: 'Length must be even',
        code: 'even_length',
      );
  print(evenLen.validate('abcd')); // true
  print(evenLen.validate('abc')); // false

  // Without `code:`, the emitted code is `'custom'` (constant
  // VCode.custom). Pass `code:` for analytics or i18n keys.
  final positive = V.int().refine((n) => n > 0);
  print(positive.errors(0)?.first.code); // 'custom'

  section('refineField — scope a predicate to one field');

  // The check sees the whole map, but the error path is `[fieldName]`,
  // so it lands in `toMap()` keyed by the field — perfect for inline
  // input errors.
  final ageCheck = V.map({
    'age': V.int(),
  }).refineField(
    (data) => (data['age'] as int) >= 18,
    path: 'age',
    message: 'Must be at least 18',
  );
  print(ageCheck.validate({'age': 20})); // true

  final out = ageCheck.safeParse({'age': 10});
  if (out case VFailure() && final f) {
    print(f.toMap()); // {age: Must be at least 18}
  }

  section('refine on container — entity-level rule');

  // Cross-field rule: `endDate` must be after `startDate`. Emits with
  // `path: []`, so it surfaces via `rootMessages()`.
  final dateRange = V.map({
    'startDate': V.date(),
    'endDate': V.date(),
  }).refine(
    (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
    code: 'date_range_invalid',
    message: 'endDate must be after startDate',
  );

  final invalid = dateRange.safeParse({
    'startDate': DateTime(2026, 5, 1),
    'endDate': DateTime(2026, 4, 1),
  });
  if (invalid case VFailure() && final f) {
    print(f.toMap()); // {} — root-level
    print(f.rootMessages()); // [endDate must be after startDate]
  }

  section('refineField(stage: pre) — pre-pipeline rule scoped to a field');

  // With stage: RefineStage.pre, refineField runs BEFORE per-field
  // preprocess / validators / transforms. It sees the input as the
  // user typed it. Use when a rule depends on raw casing / whitespace
  // / pre-coercion shape that would otherwise be lost by the field's
  // own pipeline (e.g. `.toLowerCase()`, `.trim()`).
  final emailMatch = V.map({
    'email': V.string().toLowerCase(), // transform applied after raw rule
    'expected': V.string(),
  }).refineField(
    (data) => data['email'] == data['expected'],
    path: 'email',
    message: 'email must match expected (raw, case-sensitive)',
    stage: RefineStage.pre,
  );

  // 'A@B.COM' raw matches 'A@B.COM' expected — passes.
  print(
    emailMatch.validate({
      'email': 'A@B.COM',
      'expected': 'A@B.COM',
    }),
  ); // true

  // 'A@B.COM' raw vs 'a@b.com' expected — raw rule sees the difference
  // BEFORE toLowerCase normalizes them.
  print(
    emailMatch.validate({
      'email': 'A@B.COM',
      'expected': 'a@b.com',
    }),
  ); // false

  section('refine(dependsOn:) — partial pipeline aggregation');

  // Without `dependsOn`, a refine skips on ANY field error (conservative
  // — the refine code might cast `m['x']` and crash). With `dependsOn`,
  // the refine only skips when one of the listed fields itself failed.
  // Other field errors are aggregated alongside the refine error in a
  // single VFailure.
  final priceTotal = V.map({
    'qty': V.int().min(1),
    'unit': V.double().positive(),
    'name': V.string().min(1), // unrelated field
  }).refine(
    (m) => (m['qty'] as int) * (m['unit'] as double) <= 1000,
    dependsOn: const {'qty', 'unit'},
    message: 'Total must be <= 1000',
  );

  // `name` fails (empty), but qty/unit are fine, so the refine still
  // runs — we get BOTH errors back together.
  final result = priceTotal.safeParse({
    'qty': 5,
    'unit': 250.0,
    'name': '',
  });
  if (result case VFailure(:final errors)) {
    print(errors.length); // 2 (name + refine)
  }
}

void main() => runRefineExamples();
