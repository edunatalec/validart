import 'package:validart/validart.dart';

Future<void> main() async {
  stringExamples();
  intExamples();
  doubleExamples();
  boolExamples();
  dateExamples();
  arrayExamples();
  mapExamples();
  objectExamples();
  enumExamples();
  literalExamples();
  unionExamples();
  coercionExamples();
  coreExamples();
  await asyncExamples();
  localeExamples();
}

void stringExamples() {
  print('--- string ---');

  // notEmpty
  print(V.string().notEmpty().validate('hello')); // true
  print(V.string().notEmpty().validate('')); // false

  // min / max / length
  print(V.string().min(3).validate('abc')); // true
  print(V.string().max(5).validate('hello')); // true
  print(V.string().length(4).validate('test')); // true

  // email / url / uuid / ip
  print(V.string().email().validate('user@example.com')); // true
  print(V.string().url().validate('https://example.com')); // true
  print(V.string().url().validate('ftp://example.com')); // false (default)
  print(
    V
        .string()
        .url(schemes: {'http', 'https', 'ftp'}).validate('ftp://example.com'),
  ); // true
  print(V.string().uuid().validate('550e8400-e29b-41d4-a716-446655440000'));
  print(V.string().ip().validate('192.168.1.1')); // true

  // pattern
  print(V.string().pattern(r'^\d{3}$').validate('123')); // true

  // date (multi-format default) / date strict format
  print(V.string().date().validate('2024-01-15')); // true (ISO)
  print(V.string().date().validate('15/01/2024')); // true (BR)
  print(V.string().date(format: 'DD/MM/YYYY').validate('15/01/2024')); // true
  print(V.string().date(format: 'DD/MM/YYYY').validate('2024-01-15')); // false

  // time
  print(V.string().time().validate('14:30')); // true
  print(V.string().time().validate('14:30:59')); // true

  // contains / startsWith / endsWith / equals
  print(V.string().contains('world').validate('hello world')); // true
  print(V.string().startsWith('hello').validate('hello world')); // true
  print(V.string().endsWith('.dart').validate('main.dart')); // true
  print(V.string().equals('exact').validate('exact')); // true

  // alpha / alphanumeric / slug
  print(V.string().alpha().validate('abcXYZ')); // true
  print(V.string().alphanumeric().validate('abc123')); // true
  print(V.string().slug().validate('hello-world')); // true

  // password / jwt
  print(V.string().password().validate('Str0ng!Pass')); // true
  print(V
      .string()
      .password()
      .validate('Str0ng_Pass')); // false ('_' not in default)
  print(
    V
        .string()
        .password(specialChars: r'!@#$%^&*()-_+=<>?')
        .validate('Str0ng_Pass'),
  ); // true
  print(V.string().jwt().validate('eyJh.eyJz.SflKx')); // true

  // card (default — any Luhn-valid)
  print(V.string().card().validate('4532015112830366')); // true
  print(V.string().card().validate('4111 1111 1111 1111')); // true (masked)

  // card (restricted to specific brands)
  final visaOrMaster = V.string().card(
    brands: [const VisaBrand(), const MastercardBrand()],
  );
  print(visaOrMaster.validate('4111111111111111')); // true (Visa)
  print(visaOrMaster.validate('5555555555554444')); // true (Mastercard)
  print(visaOrMaster.validate('378282246310005')); // false (Amex)

  // card (pin input shape via ValidationMode)
  final formattedCard = V.string().card(mode: ValidationMode.formatted);
  print(formattedCard.validate('4532 0151 1283 0366')); // true
  print(formattedCard.validate('4532015112830366')); // false (missing groups)

  final unformattedCard = V.string().card(mode: ValidationMode.unformatted);
  print(unformattedCard.validate('4532015112830366')); // true
  print(unformattedCard.validate('4532 0151 1283 0366')); // false

  // phone (default E.164 — `+` optional)
  print(V.string().phone().validate('+14155552671')); // true
  print(V.string().phone().validate('14155552671')); // true

  // phone (require or forbid the country-code prefix)
  final requiredPrefix = V.string().phone(
        pattern: const E164PhonePattern(
          countryCode: CountryCodeFormat.required,
        ),
      );
  print(requiredPrefix.validate('+14155552671')); // true
  print(requiredPrefix.validate('14155552671')); // false

  final noPrefix = V.string().phone(
        pattern: const E164PhonePattern(countryCode: CountryCodeFormat.none),
      );
  print(noPrefix.validate('14155552671')); // true
  print(noPrefix.validate('+14155552671')); // false

  // phone (custom pattern)
  final localPhone = V.string().phone(pattern: const LocalPhonePattern());
  print(localPhone.validate('LOCAL:1234')); // true
  print(localPhone.validate('+5511999999999')); // false

  // cvv / base64 / hex color / mac / semver / mongoId / iban / json
  print(V.string().cvv().validate('123')); // true
  print(V.string().base64().validate('SGVsbG8=')); // true
  print(V.string().hexColor().validate('#FF0000')); // true
  print(V.string().mac().validate('AA:BB:CC:DD:EE:FF')); // true
  print(V.string().semver().validate('1.2.3-alpha+build')); // true
  print(V.string().mongoId().validate('507f1f77bcf86cd799439011')); // true
  print(V.string().iban().validate('GB82 WEST 1234 5698 7654 32')); // true
  print(V.string().json().validate('{"a":1}')); // true

  // integer / numeric — validate string is parseable as int/double
  // (keeps output as String; use V.coerce.int()/double() to convert)
  print(V.string().integer().validate('42')); // true
  print(V.string().integer().validate('-42')); // true
  print(V.string().integer().validate('3.14')); // false
  print(V.string().numeric().validate('3.14')); // true
  print(V.string().numeric().validate('42e3')); // true
  print(V.string().numeric().validate('NaN')); // false
  print(V.string().numeric().validate('Infinity')); // false

  // ULID / NanoID
  print(V.string().ulid().validate('01ARZ3NDEKTSV4RRFFQ69G5FAV')); // true
  print(V.string().nanoId().validate('V1StGXR8_Z5jdHi6B-myT')); // true
  print(V.string().nanoId(length: 10).validate('V1StGXR8_Z')); // true

  // UUID version filter — v7 is timestamp-ordered (popular in modern APIs)
  print(
    V
        .string()
        .uuid(version: UuidVersion.v7)
        .validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9'),
  ); // true

  // postal code (pluggable — built-ins US, CA, UK)
  print(
    V.string().postalCode(pattern: const UsZipPattern()).validate('94103'),
  ); // true
  print(
    V
        .string()
        .postalCode(pattern: const CaPostalCodePattern())
        .validate('K1A 0B1'),
  ); // true
  print(
    V
        .string()
        .postalCode(pattern: const UkPostcodePattern())
        .validate('SW1A 1AA'),
  ); // true

  // postal code with ValidationMode — require or forbid the separator
  print(
    V
        .string()
        .postalCode(
          pattern: const UkPostcodePattern(mode: ValidationMode.formatted),
        )
        .validate('SW1A1AA'),
  ); // false (no space)
  print(
    V
        .string()
        .postalCode(
          pattern: const CaPostalCodePattern(mode: ValidationMode.unformatted),
        )
        .validate('K1A0B1'),
  ); // true

  // tax ID built-ins
  print(
    V.string().taxId(pattern: const UsSsnPattern()).validate('123-45-6789'),
  ); // true
  print(
    V.string().taxId(pattern: const UkNiNumberPattern()).validate('AB123456C'),
  ); // true
  print(
    V.string().taxId(pattern: const CaSinPattern()).validate('046-454-286'),
  ); // true

  // tax ID with ValidationMode — pin formatted vs unformatted
  print(
    V
        .string()
        .taxId(pattern: const UsSsnPattern(mode: ValidationMode.formatted))
        .validate('123456789'),
  ); // false (dashes required)
  print(
    V
        .string()
        .taxId(pattern: const CaSinPattern(mode: ValidationMode.unformatted))
        .validate('130692544'),
  ); // true

  // license plate built-in (UK post-2001)
  print(
    V
        .string()
        .licensePlate(pattern: const UkPlatePattern())
        .validate('AB12 CDE'),
  ); // true

  // license plate with ValidationMode
  print(
    V
        .string()
        .licensePlate(
          pattern: const UkPlatePattern(mode: ValidationMode.unformatted),
        )
        .validate('AB12CDE'),
  ); // true

  // Extend with your own patterns for country-specific needs:
  print(
    V.string().taxId(pattern: const DummyTaxIdPattern()).validate('TAX:123'),
  ); // true
  print(
    V
        .string()
        .licensePlate(pattern: const DummyPlatePattern())
        .validate('ABC-1234'),
  ); // true

  // transforms (pre-processing — always run before validators)
  print(V.string().trim().parse('  hello  ')); // 'hello'
  print(V.string().toLowerCase().parse('HELLO')); // 'hello'
  print(V.string().toUpperCase().parse('hello')); // 'HELLO'
  print(V.string().toPascalCase().parse('hello world')); // 'HelloWorld'
  print(V.string().toCamelCase().parse('hello_world')); // 'helloWorld'
  print(V.string().toSnakeCase().parse('HelloWorld')); // 'hello_world'
  print(V.string().toScreamingSnakeCase().parse('helloWorld')); // 'HELLO_WORLD'
  print(V.string().toSlug().parse('My Blog Post!')); // 'my-blog-post'

  // accents — stripped by default, preserved with keepAccents: true
  print(V.string().toSlug().parse('São João')); // 'sao-joao'
  print(V.string().toSlug(keepAccents: true).parse('São João')); // 'são-joão'
  print(V.string().toPascalCase().parse('maçã fresca')); // 'MacaFresca'
}

void intExamples() {
  print('--- int ---');

  print(V.int().min(5).validate(10)); // true
  print(V.int().max(10).validate(5)); // true
  print(V.int().positive().validate(1)); // true
  print(V.int().negative().validate(-1)); // true
  print(V.int().between(1, 10).validate(5)); // true
  print(V.int().multipleOf(3).validate(9)); // true
  print(V.int().even().validate(4)); // true
  print(V.int().odd().validate(3)); // true
  print(V.int().prime().validate(7)); // true

  // array of ints
  print(V.int().positive().array().validate([1, 2, 3])); // true
}

void doubleExamples() {
  print('--- double ---');

  print(V.double().min(1.5).validate(2.0)); // true
  print(V.double().max(9.9).validate(5.0)); // true
  print(V.double().positive().validate(0.1)); // true
  print(V.double().negative().validate(-0.1)); // true
  print(V.double().between(1.0, 10.0).validate(5.5)); // true
  print(V.double().multipleOf(0.5).validate(1.5)); // true
  print(V.double().finite().validate(3.14)); // true
  print(V.double().finite().validate(double.infinity)); // false
  print(V.double().decimal().validate(3.14)); // true (has fractional part)
  print(V.double().integer().validate(3.0)); // true (whole number)

  // array of doubles
  print(V.double().finite().array().validate([1.0, 2.5])); // true
}

void boolExamples() {
  print('--- bool ---');

  print(V.bool().isTrue().validate(true)); // true
  print(V.bool().isTrue().validate(false)); // false
  print(V.bool().isFalse().validate(false)); // true

  // array of bools
  print(V.bool().array().validate([true, false])); // true
}

void dateExamples() {
  print('--- date ---');

  final ref = DateTime(2024, 1, 1);

  print(V.date().after(ref).validate(DateTime(2024, 6, 15))); // true
  print(V.date().before(ref).validate(DateTime(2023, 6, 15))); // true
  print(
    V
        .date()
        .between(ref, DateTime(2024, 12, 31))
        .validate(DateTime(2024, 6, 15)),
  ); // true

  // 2024-01-15 is Monday
  print(V.date().weekday().validate(DateTime(2024, 1, 15))); // true
  // 2024-01-06 is Saturday
  print(V.date().weekend().validate(DateTime(2024, 1, 6))); // true

  // age — computed against DateTime.now()
  final now = DateTime.now();
  final thirty = DateTime(now.year - 30, now.month, now.day);
  print(V.date().age(min: 18).validate(thirty)); // true
  print(V.date().age(min: 18, max: 65).validate(thirty)); // true
}

void arrayExamples() {
  print('--- array ---');

  // min / max
  print(V.string().array().min(1).validate(['a'])); // true
  print(V.string().array().max(3).validate(['a', 'b'])); // true

  // unique
  print(V.int().array().unique().validate([1, 2, 3])); // true
  print(V.int().array().unique().validate([1, 1, 2])); // false

  // contains
  print(V.int().array().contains([1, 2]).validate([1, 2, 3])); // true

  // nested arrays
  final matrix = VArray<List<int>>(V.int().array());
  print(
    matrix.validate([
      [1, 2],
      [3, 4],
    ]),
  ); // true

  // refine
  final sumLeq10 = V.int().array().refine(
        (v) => v.fold<int>(0, (a, b) => a + b) <= 10,
        message: 'Sum must be <= 10',
      );
  print(sumLeq10.validate([1, 2, 3])); // true
  print(sumLeq10.validate([5, 6])); // false
}

void mapExamples() {
  print('--- map ---');

  // basic
  final userSchema = V.map({
    'name': V.string().min(1),
    'email': V.string().email(),
    'age': V.int().min(0).nullable(),
  });
  print(
    userSchema.validate({'name': 'Alice', 'email': 'alice@ex.com', 'age': 30}),
  ); // true

  // pick / omit
  final picked = userSchema.pick(['name', 'email']);
  print(picked.validate({'name': 'Alice', 'email': 'alice@ex.com'})); // true

  final omitted = userSchema.omit(['age']);
  print(omitted.validate({'name': 'Alice', 'email': 'alice@ex.com'})); // true

  // extend / merge
  final extended = userSchema.extend({'password': V.string().min(8)});
  print(extended.validate({
    'name': 'Alice',
    'email': 'a@b.com',
    'password': '12345678',
  })); // true

  final schemaA = V.map({'a': V.string()});
  final schemaB = V.map({'b': V.int()});
  final merged = schemaA.merge(schemaB);
  print(merged.validate({'a': 'x', 'b': 1})); // true

  // partial (all fields become nullable)
  final partialSchema = V.map({'name': V.string()}).partial();
  print(partialSchema.validate({'name': null})); // true

  // strict (rejects extra keys)
  final strictSchema = V.map({'name': V.string()}).strict();
  print(strictSchema.validate({'name': 'Jo', 'extra': true})); // false

  // passthrough (keeps extra keys in parsed output)
  final passthrough = V.map({'name': V.string()}).passthrough();
  print(passthrough.parse({'name': 'Jo', 'extra': true}));
  // {name: Jo, extra: true}

  // equalFields
  final register = V.map({
    'password': V.string().min(8),
    'confirm': V.string(),
  }).equalFields('confirm', 'password');
  print(register.validate({
    'password': '12345678',
    'confirm': '12345678',
  })); // true

  // refineField (custom per-field validation)
  final ageCheck = V.map({
    'age': V.int(),
  }).refineField(
    (data) => (data['age'] as int) >= 18,
    path: 'age',
    message: 'Must be at least 18',
  );
  print(ageCheck.validate({'age': 20})); // true
  print(ageCheck.validate({'age': 10})); // false

  // when (conditional)
  final form = V.map({
    'type': V.string(),
    'cnpj': V.string().nullable(),
    'cpf': V.string().nullable(),
  }).when('type', equals: 'company', then: {'cnpj': V.string().min(14)}).when(
      'type',
      equals: 'person',
      then: {'cpf': V.string().min(11)});
  print(form.validate({'type': 'company', 'cnpj': '12345678901234'})); // true
  print(form.validate({'type': 'person', 'cpf': '12345678901'})); // true

  // array of maps
  final users = V.map({'name': V.string().min(1)}).array();
  print(users.validate([
    {'name': 'Alice'},
    {'name': 'Bob'},
  ])); // true
}

void objectExamples() {
  print('--- object ---');

  // field (type-safe extraction)
  final folderSchema = V.object<Folder>(
    configure: (o) => o
        .field('id', (f) => f.id, V.string().uuid())
        .field('name', (f) => f.name, V.string().min(1)),
  );
  final folder = Folder(
    id: '550e8400-e29b-41d4-a716-446655440000',
    name: 'Docs',
  );
  print(folderSchema.validate(folder)); // true

  // refine on entity
  final namedFolder = V.object<Folder>().refine(
        (f) => f.name.isNotEmpty,
        message: 'Name cannot be empty',
        code: 'empty_name',
      );
  print(namedFolder.validate(folder)); // true
}

void enumExamples() {
  print('--- enum ---');

  final colorSchema = V.enm(Color.values);
  print(colorSchema.validate(Color.red)); // true
  print(colorSchema.validate('red')); // false

  // array of enums
  print(colorSchema.array().validate([Color.red, Color.blue])); // true
}

void literalExamples() {
  print('--- literal ---');

  final adminSchema = V.literal('admin');
  print(adminSchema.validate('admin')); // true
  print(adminSchema.validate('user')); // false
}

void unionExamples() {
  print('--- union ---');

  // Accepts either a UUID string or a positive int
  final idSchema = V.union([V.string().uuid(), V.int().min(1)]);
  print(idSchema.validate('550e8400-e29b-41d4-a716-446655440000')); // true
  print(idSchema.validate(42)); // true
  print(idSchema.validate('bad')); // false
}

void coercionExamples() {
  print('--- coerce ---');

  print(V.coerce.int().parse('42')); // 42
  print(V.coerce.int().parse(3.7)); // 3
  print(V.coerce.double().parse('3.14')); // 3.14
  print(V.coerce.string().parse(42)); // '42'
  print(V.coerce.bool().parse('true')); // true
  print(V.coerce.bool().parse(0)); // false
  print(V.coerce.date().parse('2024-01-15')); // DateTime(2024, 1, 15)
}

void coreExamples() {
  print('--- core ---');

  // nullable
  print(V.string().nullable().parse(null)); // null

  // defaultValue
  print(V.string().defaultValue('fallback').parse(null)); // 'fallback'

  // message — custom per-schema message for null input (required error).
  final terms = V.bool(message: 'You must accept the terms').isTrue();
  print(terms.errors(null)?.first.message); // 'You must accept the terms'

  // Custom messages: factory-level `message` vs validator-level `message`.
  //
  // Same parameter name, different scopes:
  //   - Factory `V.string(message: ...)` → only fires on null input
  //     (pre-validation `required` error).
  //   - Validator `.email(message: ...)` / `.min(n, message: ...)` →
  //     only fires when that specific validator rejects a non-null value.
  // The two never overlap and can coexist on the same schema.

  final onlyRequired = V.string(message: 'Name is required').min(3);
  print(onlyRequired.errors(null)?.first.message); // 'Name is required'

  final onlyValidator = V.string().email(message: 'Invalid email format');
  print(onlyValidator.errors('bad')?.first.message); // 'Invalid email format'

  final both = V
      .string(message: 'Name is required')
      .min(3, message: (n) => 'At least $n chars');
  print(both.errors(null)?.first.message); // 'Name is required'
  print(both.errors('ab')?.first.message); // 'At least 3 chars'

  // refine (custom validation)
  final evenLen = V.string().refine(
        (v) => v.length.isEven,
        message: 'Length must be even',
        code: 'even_length',
      );
  print(evenLen.validate('abcd')); // true
  print(evenLen.validate('abc')); // false

  // transform<O> — change the output type
  final length = V.string().transform<int>((s) => s.length);
  print(length.parse('hello')); // 5

  // preprocess — transform before type check
  final trimmed = V.string().preprocess((v) => v?.toString().trim() ?? '');
  print(trimmed.parse(42)); // '42'

  // safeParse with pattern matching
  final result = V.string().email().safeParse('bad');
  switch (result) {
    case VSuccess(:final value):
      print('ok: $value');
    case VFailure(:final errors):
      print('errors: ${errors.map((e) => e.code).toList()}');
    // errors: [invalid_email]
  }

  // errors() + VFailure.toMap()
  final form = V.map({
    'email': V.string().email(),
    'name': V.string().min(3),
  }).safeParse({'email': 'bad', 'name': 'Al'});

  if (form case VFailure()) {
    print(form.toMap());
    // {email: Invalid email address, name: String must be at least 3 ...}
  }
}

Future<void> asyncExamples() async {
  print('--- async ---');

  // Simulate an async uniqueness check.
  Future<bool> isEmailAvailable(String email) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return email != 'taken@example.com';
  }

  final schema = V.string().email().refineAsync(
        isEmailAvailable,
        message: 'Email already registered',
        code: 'email_taken',
      );

  print(await schema.validateAsync('new@example.com')); // true
  print(await schema.validateAsync('taken@example.com')); // false

  // Sync consumers on an async schema throw VAsyncRequiredException.
  try {
    schema.validate('x');
  } on VAsyncRequiredException catch (e) {
    print('caught: ${e.suggestion}'); // caught: validateAsync
  }

  // Sync-only schemas still work sync without any overhead.
  print(V.string().email().validate('a@b.com')); // true

  // addAsync — custom AsyncValidator (reusable across schemas)
  final usernameSchema = V.string().addAsync(const _UsernameAvailable());
  print(await usernameSchema.validateAsync('new_user')); // true
  print(await usernameSchema.validateAsync('taken')); // false

  // refineAsync with timeout
  final slowSchema = V.string().refineAsync(
    (v) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return true;
    },
    timeout: const Duration(milliseconds: 50),
    message: 'Timed out',
  );
  print(await slowSchema.validateAsync('x')); // false (timed out)

  // preprocessAsync — transform input before type check
  final resolvedSchema = V.string().preprocessAsync((raw) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return raw.toString().trim();
  }).min(3);
  print(await resolvedSchema.validateAsync('  hello  ')); // true

  // transformAsync — change output type asynchronously
  final lengthSchema = V.string().min(3).transformAsync<int>((v) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return v.length;
  });
  print(await lengthSchema.parseAsync('hello')); // 5
}

void localeExamples() {
  print('--- locale ---');

  V.setLocale(const VLocale({
    'string.email': 'Email inválido',
    'positive': 'Deve ser positivo',
    'required': 'Campo obrigatório',
  }));

  print(V.string().email().errors('bad')?.first.message);
  // 'Email inválido'

  print(V.int().positive().errors(-1)?.first.message);
  // 'Deve ser positivo'

  // Type-specific overrides — flat and nested forms coexist.
  // Emitted codes are prefixed (e.g. 'string.required', 'int.required').
  V.setLocale(const VLocale({
    // Generic fallback.
    'required': 'Campo obrigatório',

    // Nested — affects VString only.
    'string': {'required': 'Texto obrigatório'},

    // Flat — affects VInt only.
    'int.required': 'Número obrigatório',
  }));

  print(V.string().errors(null)?.first.message); // 'Texto obrigatório'
  print(V.int().errors(null)?.first.message); // 'Número obrigatório'
  print(V.bool().errors(null)?.first.message); // 'Campo obrigatório' (fallback)

  // Reset to default
  V.setLocale(const VLocale());
}

class Folder {
  final String id;
  final String name;
  Folder({required this.id, required this.name});
}

enum Color { red, green, blue }

class LocalPhonePattern extends PhonePattern {
  const LocalPhonePattern();

  @override
  String get code => 'invalid_phone_local';

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith('LOCAL:') ? null : {};
}

class DummyTaxIdPattern extends TaxIdPattern {
  const DummyTaxIdPattern();

  @override
  String get name => 'Dummy Tax ID';

  @override
  bool matches(String value) => value.startsWith('TAX:');
}

class _UsernameAvailable extends AsyncValidator<String> {
  const _UsernameAvailable();

  @override
  String get code => 'username_taken';

  @override
  Future<Map<String, dynamic>?> validate(String value) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return value == 'taken' ? {} : null;
  }
}

class DummyPlatePattern extends LicensePlatePattern {
  const DummyPlatePattern();

  @override
  String get name => 'Dummy Plate';

  @override
  bool matches(String value) => RegExp(r'^[A-Z]{3}-\d{4}$').hasMatch(value);
}
