import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.date()` — calendar comparisons, weekday/weekend
/// classification, and age-against-now (`age` validator).
void runDateExamples() {
  section('VDate — comparisons');

  final ref = DateTime(2024, 1, 1);

  print(V.date().after(ref).validate(DateTime(2024, 6, 15))); // true
  print(V.date().before(ref).validate(DateTime(2023, 6, 15))); // true
  print(
    V
        .date()
        .between(ref, DateTime(2024, 12, 31))
        .validate(DateTime(2024, 6, 15)),
  ); // true

  section('VDate — weekday / weekend');

  // 2024-01-15 is a Monday.
  print(V.date().weekday().validate(DateTime(2024, 1, 15))); // true
  print(V.date().weekend().validate(DateTime(2024, 1, 15))); // false

  // 2024-01-06 is a Saturday.
  print(V.date().weekend().validate(DateTime(2024, 1, 6))); // true

  section('VDate — age');

  // `.age()` is computed against `DateTime.now()`. The fixture below
  // is exactly 30 years before today.
  final DateTime now = DateTime.now();
  final DateTime thirtyYearsAgo = DateTime(now.year - 30, now.month, now.day);

  print(V.date().age(min: 18).validate(thirtyYearsAgo)); // true
  print(V.date().age(min: 18, max: 65).validate(thirtyYearsAgo)); // true
  print(V.date().age(min: 40).validate(thirtyYearsAgo)); // false (only 30)
}

void main() => runDateExamples();
