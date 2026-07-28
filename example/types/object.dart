import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `V.object<T>()` — type-safe entity validation. The
/// canonical pattern is a `static final schema` on the DTO itself
/// (see [SignInDto] / [SignUpDto] in `shared/fixtures.dart`). Composition
/// (`pick`/`omit`/`merge`) and entity-level rules (`when`, `equalFields`,
/// `refineField`) live in `features/composition.dart`,
/// `features/when.dart`, `features/equal_fields.dart`,
/// `features/refine.dart`.
void runObjectExamples() {
  section('VObject — fluent .field()');

  // Each .field(name, extractor, validator) wires up one field. The
  // extractor reads the value off the entity, the validator validates
  // it. Type-safe end-to-end (no Map keys to typo).
  final folderSchema = V
      .object<Folder>()
      .field('id', (f) => f.id, V.string().uuid())
      .field('name', (f) => f.name, V.string().min(1));

  final folder = Folder(
    id: '550e8400-e29b-41d4-a716-446655440000',
    name: 'Docs',
  );

  print(folderSchema.validate(folder)); // true
  print(folderSchema.validate(Folder(id: 'bad', name: 'Docs'))); // false

  section('VObject — entity-level refine');

  final namedFolder = V.object<Folder>().refine(
        (f) => f.name.isNotEmpty,
        message: 'Name cannot be empty',
        code: 'empty_name',
      );
  print(namedFolder.validate(folder)); // true

  section('VObject — DTO pattern');

  // Schema lives on the DTO as a static, built once per isolate and
  // reused across every call site.
  print(
    SignInDto.schema.validate(
      const SignInDto(email: 'a@b.com', password: 'Str0ng!Pass'),
    ),
  ); // true

  print(
    SignInDto.schema.validate(
      const SignInDto(email: 'bad', password: 'Str0ng!Pass'),
    ),
  ); // false

  section('VObject — array of entities');

  print(
    SignInDto.schema.array().validate(const [
      SignInDto(email: 'a@b.com', password: 'Str0ng!Pass'),
      SignInDto(email: 'c@d.com', password: 'An0ther!Pass'),
    ]),
  ); // true

  section('VObject — fieldIf for conditional field declaration');

  // Build different schemas from the same fluent chain by toggling
  // which fields are declared. Useful for partial-update DTOs where
  // only some fields are accepted in a given context.
  VObject<SignInDto> credentialsSchema({required bool requirePassword}) => V
      .object<SignInDto>()
      .field('email', (d) => d.email, V.string().email())
      .fieldIf(
        requirePassword,
        'password',
        (d) => d.password,
        V.string().password(),
      );

  print(
    credentialsSchema(requirePassword: true)
        .validate(const SignInDto(email: 'a@b.com', password: 'Str0ng!Pass')),
  );
  // true — both fields validated

  print(
    credentialsSchema(requirePassword: true)
        .validate(const SignInDto(email: 'a@b.com', password: 'weak')),
  );
  // false — password fails the password() rule

  print(
    credentialsSchema(requirePassword: false)
        .validate(const SignInDto(email: 'a@b.com', password: 'weak')),
  );
  // true — password field not declared, so its value is ignored

  section('VObject — partial: every field accepts null');

  // Each field's validator gets wrapped so null is accepted in addition
  // to the original shape. Non-null values still run the original
  // validator. Useful for PATCH / UPDATE DTOs.
  final patchSchema = V
      .object<SignInDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .partial();

  print(
    patchSchema.validate(
      const SignInDto(email: 'a@b.com', password: 'Str0ng!Pass'),
    ),
  ); // true

  print(
    patchSchema
        .validate(const SignInDto(email: 'bad', password: 'Str0ng!Pass')),
  );
  // false — non-null email still validated by .email()

  section('VObject — safeParseRaw: validate Map without constructing T');

  // Use `safeParseRaw` when the caller cannot build `T` ahead of time —
  // typically because the source data is partial and the `T` constructor
  // rejects null on required fields. The schema reads each field by name
  // (`map[fieldName]`); per-field validators, `when`, `whenMatches`,
  // `strict`, and `passthrough` apply the same way as in entity mode.
  final rawSchema = V
      .object<SignInDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .strict();

  print(
    rawSchema.validateRaw({
      'email': 'a@b.com',
      'password': 'Str0ng!Pass',
    }),
  ); // true

  print(
    rawSchema.errorsRaw({
      'email': 'bad',
      'password': 'weak',
      'unexpected': 1,
    }),
  );
  // Three errors: invalid email, weak password, and the unknown key
  // rejected by strict().

  // A partial payload missing a required field — the entity constructor
  // would throw here, but `safeParseRaw` surfaces a clean field error.
  print(rawSchema.errorsRaw({'email': 'a@b.com'}));
}

void main() => runObjectExamples();
