import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.map({...})` — the `Map<String, dynamic>` schema.
/// Composition (`pick`/`omit`/`extend`/`merge`/`partial`) lives in
/// `features/composition.dart`. Conditional rules live in
/// `features/when.dart`. Cross-field equality lives in
/// `features/equal_fields.dart`.
void runMapExamples() {
  section('VMap — basic field schema');

  final user = V.map({
    'name': V.string().min(1),
    'email': V.string().email(),
    'age': V.int().min(0).nullable(),
  });

  print(
    user.validate({
      'name': 'Alice',
      'email': 'alice@ex.com',
      'age': 30,
    }),
  ); // true

  print(
    user.validate({
      'name': 'Alice',
      'email': 'alice@ex.com',
      'age': null,
    }),
  ); // true (age is nullable)

  print(
    user.validate({
      'name': 'Alice',
      'email': 'bad',
      'age': 30,
    }),
  ); // false (invalid email)

  section('VMap — strict / passthrough');

  // strict() rejects unknown keys.
  final strictUser = V.map({'name': V.string()}).strict();
  print(strictUser.validate({'name': 'Jo'})); // true
  print(strictUser.validate({'name': 'Jo', 'extra': true})); // false

  // passthrough() keeps unknown keys in the parsed output.
  final passthrough = V.map({'name': V.string()}).passthrough();
  print(passthrough.parse({'name': 'Jo', 'extra': true}));
  // {name: Jo, extra: true}

  section('VMap — array of maps');

  final users = V.map({'name': V.string().min(1)}).array();
  print(
    users.validate([
      {'name': 'Alice'},
      {'name': 'Bob'},
    ]),
  ); // true

  section('VMap — nested maps');

  final address = V.map({
    'street': V.string().min(1),
    'zip': V.string().length(5),
  });

  final person = V.map({
    'name': V.string().min(1),
    'address': address,
  });
  print(
    person.validate({
      'name': 'Alice',
      'address': {'street': '5th Ave', 'zip': '94103'},
    }),
  ); // true

  // Field error paths use dot notation in `toMap()`.
  final result = person.safeParse({
    'name': 'Alice',
    'address': {'street': '5th Ave', 'zip': '12'},
  });
  if (result case VFailure() && final f) {
    print(f.toMap()); // {address.zip: ...}
  }
}

void main() => runMapExamples();
