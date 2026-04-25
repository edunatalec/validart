import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.array(...)` and the `.array()` shorthand on every
/// element schema. Covers size bounds, uniqueness, containment,
/// nesting, and array-level `refine`.
void runArrayExamples() {
  section('VArray — bounds & uniqueness');

  print(V.string().array().min(1).validate(['a'])); // true
  print(V.string().array().max(3).validate(['a', 'b'])); // true
  print(
      V.string().array().min(2).max(2).validate(['a', 'b'])); // true (exact 2)

  print(V.int().array().unique().validate([1, 2, 3])); // true
  print(V.int().array().unique().validate([1, 1, 2])); // false

  section('VArray — contains');

  // `.contains([...])` requires every element of the argument to be
  // present, in any order.
  print(V.int().array().contains([1, 2]).validate([1, 2, 3])); // true
  print(V.int().array().contains([1, 4]).validate([1, 2, 3])); // false

  section('VArray — nested arrays');

  // VArray<List<int>> — a list of lists.
  final VArray<List<int>> matrix = VArray<List<int>>(V.int().array());
  print(matrix.validate([
    [1, 2],
    [3, 4],
  ])); // true

  section('VArray — array-level refine');

  // `.refine` on an array sees the whole list — useful for cross-element
  // rules like "sum must stay under N" or "max one of kind".
  final sumLeq10 = V.int().array().refine(
        (v) => v.fold<int>(0, (a, b) => a + b) <= 10,
        message: 'Sum must be <= 10',
        code: 'sum_too_large',
      );
  print(sumLeq10.validate([1, 2, 3])); // true
  print(sumLeq10.validate([5, 6])); // false

  section('VArray — element-level errors carry index in path');

  final users = V.map({'name': V.string().min(3)}).array();
  final result = users.safeParse([
    {'name': 'Alice'},
    {'name': 'Al'},
  ]);
  if (result case VFailure(:final errors)) {
    print(errors.first.path); // [1, name]
  }
}

void main() => runArrayExamples();
