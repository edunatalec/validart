import 'package:validart/validart.dart';

void main() {
  final v = Validart();

  // String validation
  final nameSchema = v.string()
    ..min(3)
    ..max(50);
  print(nameSchema.validate('Alice')); // true
  print(nameSchema.validate('Al')); // false

  // Email validation
  final emailSchema = v.string()..email();
  print(emailSchema.validate('alice@example.com')); // true
  print(emailSchema.validate('invalid')); // false

  // Integer validation
  final ageSchema = v.int()
    ..min(0)
    ..max(150);
  print(ageSchema.validate(25)); // true
  print(ageSchema.validate(-1)); // false

  // Map validation (structured data)
  final userSchema = v.map({
    'name': v.string()..min(1),
    'email': v.string()..email(),
    'age': v.int()
      ..min(0)
      ..optional(),
  });
  print(
      userSchema.validate({'name': 'Alice', 'email': 'alice@ex.com'})); // true
  print(userSchema.errors({'name': '', 'email': 'bad'})); // list of VError

  // Object validation (entities/classes)
  final folderSchema = v.object<Folder>(
    configure: (o) => o
        .field('id', (f) => f.id, v.string()..uuid())
        .field('name', (f) => f.name, v.string()..min(1)),
  );
  final folder =
      Folder(id: '550e8400-e29b-41d4-a716-446655440000', name: 'Docs');
  print(folderSchema.validate(folder)); // true

  // Array validation with indexed errors
  final emailsSchema = v.string().email().array()
    ..min(1)
    ..unique();
  print(emailsSchema.validate(['a@b.com', 'c@d.com'])); // true
  final result = emailsSchema.safeParse(['a@b.com', 'bad', 'a@b.com']);
  if (result case VFailure(:final errors)) {
    for (final error in errors) {
      print('${error.pathString}: ${error.message}');
    }
  }

  // Coercion
  final coercedInt = v.coerce.int();
  print(coercedInt.parse('42')); // 42

  // Enum validation
  final statusSchema = v.enm(Status.values);
  print(statusSchema.validate(Status.active)); // true

  // Literal validation
  final adminSchema = v.literal('admin');
  print(adminSchema.validate('admin')); // true
  print(adminSchema.validate('user')); // false

  // Union validation
  final idSchema = v.union([v.string()..uuid(), v.int()..min(1)]);
  print(idSchema.validate('550e8400-e29b-41d4-a716-446655440000')); // true
  print(idSchema.validate(42)); // true

  // Custom messages
  final vPt = Validart(
    messages: const VMessages(
      string: VStringMessages(email: 'Email inválido'),
      number: VNumberMessages(positive: 'Deve ser positivo'),
    ),
  );
  final ptSchema = vPt.string()..email();
  print(ptSchema.errors('bad')?.first.message); // 'Email inválido'

  // Schema composition
  final baseSchema = v.map({
    'name': v.string()..min(1),
    'email': v.string()..email(),
  });
  final createSchema = baseSchema.extend({
    'password': v.string()..min(8),
  });
  print(createSchema.validate({
    'name': 'Alice',
    'email': 'a@b.com',
    'password': '12345678',
  })); // true

  // Parse with transforms
  final trimmedEmail = v.string()
    ..trim()
    ..toLowerCase()
    ..email();
  print(trimmedEmail.parse('  ALICE@EXAMPLE.COM  ')); // 'alice@example.com'
}

class Folder {
  final String id;
  final String name;
  Folder({required this.id, required this.name});
}

enum Status { active, inactive }
