import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for inspecting validation failures: `errors()`,
/// `safeParse` + `VFailure.toMap()`, and `VFailure.rootMessages()`.
/// Also covers the partition between the two: every error appears in
/// exactly one of `toMap()` or `rootMessages()`.
void runErrorsExamples() {
  section('errors() — inspect validation result');

  final invalid = V.string().email().errors('bad');
  print(invalid?.first.code); // 'string.email'
  print(invalid?.first.message); // 'Invalid email address'
  print(invalid?.first.path); // []

  final valid = V.string().email().errors('a@b.com');
  print(valid); // null (no errors)

  section('safeParse + pattern matching');

  final r = V.string().email().safeParse('bad');
  switch (r) {
    case VSuccess(:final value):
      print('ok: $value');
    case VFailure(:final errors):
      print('errors: ${errors.map((e) => e.code).toList()}');
    // [string.email]
  }

  section('VFailure.toMap — field-keyed');

  // toMap is the canonical channel for per-input UI errors. The key
  // is the field path (`'address.zip'`, `'items.0.name'`, etc.).
  final form = V.map({
    'email': V.string().email(),
    'name': V.string().min(3),
  }).safeParse({'email': 'bad', 'name': 'Al'});

  if (form case VFailure() && final f) {
    print(f.toMap());
    // {email: Invalid email address, name: Must be at least 3 characters}
  }

  section('VFailure.rootMessages — form-wide rules');

  // Errors with `path: []` are excluded from `toMap()` and surface
  // here. Producers (full list in README under "Reading raw errors"):
  // refine / refineAsync / equalFields on a container, add / addAsync
  // without `path:`, and any validator on a primitive used as the root.
  final dateRange = V.map({
    'startDate': V.date(),
    'endDate': V.date(),
  }).refine(
    (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
    message: 'endDate must be after startDate',
  );

  final out = dateRange.safeParse({
    'startDate': DateTime(2026, 5, 1),
    'endDate': DateTime(2026, 4, 1),
  });
  if (out case VFailure() && final f) {
    print(f.toMap()); // {} — no field-level error
    print(f.rootMessages()); // [endDate must be after startDate]
  }

  section('Partition — every error in exactly ONE of toMap / rootMessages');

  // To get BOTH a field error AND a root-level refine in the same
  // failure, declare which fields the refine depends on. With
  // `dependsOn`, the refine runs as long as those specific deps
  // passed — even if unrelated fields failed.
  final mixed = V.map({
    'a': V.string().min(1), // lax — 'x' passes
    'b': V.string().min(1), // lax — 'x' passes
    'name': V.string().min(3), // strict — 'Al' fails
  }).refine(
    (m) => (m['a'] as String) != (m['b'] as String),
    dependsOn: const {'a', 'b'},
    message: 'a and b must differ',
  );

  final res = mixed.safeParse({'a': 'x', 'b': 'x', 'name': 'Al'});
  if (res case VFailure() && final f) {
    print(f.toMap()); // {name: Must be at least 3 characters}
    print(f.rootMessages()); // [a and b must differ]
    print(f.errors.length); // 2 (one field + one root)
  }
}

void main() => runErrorsExamples();
