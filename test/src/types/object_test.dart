import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

class Folder {
  final String? id;
  final String name;
  Folder({this.id, required this.name});
}

class _TaggedFolder {
  final String name;
  final List<String> tags;
  _TaggedFolder(this.name, this.tags);
}

class _SignUp {
  final String email;
  final String password;
  final String confirm;
  _SignUp(this.email, this.password, this.confirm);
}

class _TaxPayer {
  final String country;
  final String taxId;
  _TaxPayer(this.country, this.taxId);
}

class _Profile {
  final String name;
  final int age;
  final String email;
  final String? bio;
  _Profile({
    required this.name,
    required this.age,
    required this.email,
    this.bio,
  });
}

enum _AccountStatus { active, suspended, deleted }

class _KitchenSinkEntity {
  final String name;
  final int age;
  final double balance;
  final bool active;
  final DateTime joined;
  final List<String> tags;
  final Map<String, dynamic> prefs;
  final _AccountStatus status;
  final Object id; // String UUID or int

  _KitchenSinkEntity({
    required this.name,
    required this.age,
    required this.balance,
    required this.active,
    required this.joined,
    required this.tags,
    required this.prefs,
    required this.status,
    required this.id,
  });
}

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VObject', () {
    group('simple not-null check', () {
      test('should pass for non-null Folder instance', () {
        final schema = VObject<Folder>();
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail for null', () {
        final schema = VObject<Folder>();
        expect(schema.validate(null), isFalse);
      });

      test('should return required error for null', () {
        final schema = VObject<Folder>();
        final errors = schema.errors(null);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'object.required');
      });

      test('should pass for Folder with all fields', () {
        final schema = VObject<Folder>();
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Documents',
          )),
          isTrue,
        );
      });
    });

    group('field validation', () {
      test('should validate fields and pass for valid data', () {
        final schema = VObject<Folder>()
            .field('id', (f) => f.id, VString().uuid().nullable())
            .field('name', (f) => f.name, VString().min(1));
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail for invalid field', () {
        final schema =
            VObject<Folder>().field('name', (f) => f.name, VString().min(5));
        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('should include field name in error path', () {
        final schema =
            VObject<Folder>().field('name', (f) => f.name, VString().min(5));
        final errors = schema.errors(Folder(name: 'Doc'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'string.too_small');
        expect(errors.first.path, ['name']);
      });

      test('should validate uuid field', () {
        final schema =
            VObject<Folder>().field('id', (f) => f.id, VString().uuid());
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Test',
          )),
          isTrue,
        );
      });

      test('should fail for invalid uuid field', () {
        final schema =
            VObject<Folder>().field('id', (f) => f.id, VString().uuid());
        final errors = schema.errors(Folder(id: 'not-a-uuid', name: 'Test'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'string.uuid');
        expect(errors.first.path, ['id']);
      });

      test('should collect multiple field errors', () {
        final schema = VObject<Folder>()
            .field('id', (f) => f.id, VString().uuid())
            .field('name', (f) => f.name, VString().min(10));
        final errors = schema.errors(Folder(id: 'bad', name: 'short'));
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].path, ['id']);
        expect(errors[1].path, ['name']);
      });
    });

    group('fieldIf', () {
      test('condition true adds the field', () {
        final schema = VObject<Folder>()
            .fieldIf(true, 'name', (f) => f.name, V.string().min(5));

        expect(schema.validate(Folder(name: 'Documents')), isTrue);
        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('condition false skips the field entirely', () {
        final schema = VObject<Folder>()
            .fieldIf(false, 'name', (f) => f.name, V.string().min(5));

        // No field declared → schema only checks that the input is a Folder.
        expect(schema.validate(Folder(name: 'Doc')), isTrue);
        expect(schema.schema.containsKey('name'), isFalse);
      });

      test('preserves fluent chain in both branches', () {
        VObject<Folder> build({required bool withName}) => V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid().nullable())
            .fieldIf(withName, 'name', (f) => f.name, V.string().min(5));

        expect(
          build(withName: true).validate(Folder(name: 'Documents')),
          isTrue,
        );
        expect(
          build(withName: true).validate(Folder(name: 'Doc')),
          isFalse,
          reason: 'name field active → min(5) gates the value',
        );
        expect(
          build(withName: false).validate(Folder(name: 'Doc')),
          isTrue,
          reason: 'name field skipped → no length check',
        );
      });

      test('multiple fieldIf calls compose independently', () {
        VObject<_Profile> build({
          required bool withAge,
          required bool withBio,
        }) =>
            V
                .object<_Profile>()
                .field('name', (p) => p.name, V.string())
                .field('email', (p) => p.email, V.string().email())
                .fieldIf(withAge, 'age', (p) => p.age, V.int().min(18))
                .fieldIf(
                  withBio,
                  'bio',
                  (p) => p.bio,
                  V.string().min(5).nullable(),
                );

        // Both off → only name + email are validated.
        expect(
          build(withAge: false, withBio: false).validate(
            _Profile(
              name: 'A',
              age: 5,
              email: 'a@b.com',
              bio: 'no',
            ),
          ),
          isTrue,
        );

        // Age on → min(18) fires.
        expect(
          build(withAge: true, withBio: false).validate(
            _Profile(name: 'A', age: 5, email: 'a@b.com'),
          ),
          isFalse,
        );

        // Bio on → min(5) fires.
        expect(
          build(withAge: false, withBio: true).validate(
            _Profile(name: 'A', age: 5, email: 'a@b.com', bio: 'no'),
          ),
          isFalse,
        );
      });
    });

    group('refine', () {
      test('should add custom validation', () {
        final schema = VObject<Folder>().refine(
          (f) => f.name.isNotEmpty,
          message: 'Name cannot be empty',
          code: 'empty_name',
        );
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail custom validation', () {
        final schema = VObject<Folder>().refine(
          (f) => f.name.length >= 5,
          message: 'Name too short',
          code: 'name_too_short',
        );
        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('should return custom error code', () {
        final schema = VObject<Folder>().refine(
          (f) => f.id != null,
          message: 'ID is required',
          code: 'missing_id',
        );
        final errors = schema.errors(Folder(name: 'Test'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'missing_id');
        expect(errors.first.message, 'ID is required');
      });
    });

    group('nullable and optional', () {
      test('nullable should allow null', () {
        final schema = VObject<Folder>().nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should parse null to null', () {
        final schema = VObject<Folder>().nullable();
        expect(schema.parse(null), isNull);
      });

      test('nullable should allow null', () {
        final schema = VObject<Folder>().nullable();
        expect(schema.validate(null), isTrue);
      });

      test('defaultValue should return default when null', () {
        final fallback = Folder(name: 'Default');
        final schema = VObject<Folder>().defaultValue(fallback);
        final result = schema.parse(null);
        expect(result, fallback);
      });
    });

    group('wrong type input', () {
      test('should fail for string input', () {
        final schema = VObject<Folder>();
        expect(schema.validate('not a folder'), isFalse);
      });

      test('should return invalid_type error for wrong type', () {
        final schema = VObject<Folder>();
        final errors = schema.errors('not a folder');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'object.invalid_type');
      });

      test('should fail for int input', () {
        final schema = VObject<Folder>();
        expect(schema.validate(42), isFalse);
      });

      test('should fail for list input', () {
        final schema = VObject<Folder>();
        expect(schema.validate([1, 2, 3]), isFalse);
      });

      test('should fail for map input', () {
        final schema = VObject<Folder>();
        expect(schema.validate({'name': 'test'}), isFalse);
      });
    });

    group('combined with VMap', () {
      test('should use VObject inside VMap schema', () {
        final schema = VMap({
          'folder':
              VObject<Folder>().field('name', (f) => f.name, VString().min(1)),
        });
        expect(
          schema.validate({'folder': Folder(name: 'Documents')}),
          isTrue,
        );
      });

      test('should fail when VObject field inside VMap is invalid', () {
        final schema = VMap({
          'folder':
              VObject<Folder>().field('name', (f) => f.name, VString().min(10)),
        });
        expect(
          schema.validate({'folder': Folder(name: 'Doc')}),
          isFalse,
        );
      });

      test('should produce nested path for VObject inside VMap', () {
        final schema = VMap({
          'folder':
              VObject<Folder>().field('name', (f) => f.name, VString().min(10)),
        });
        final errors = schema.errors({'folder': Folder(name: 'Doc')});
        expect(errors, isNotNull);
        expect(errors!.first.path, ['folder', 'name']);
      });

      test('should fail when VObject field in VMap is null', () {
        final schema = VMap({
          'folder': VObject<Folder>(),
        });
        final errors = schema.errors({'folder': null});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'object.required');
        expect(errors.first.path, ['folder']);
      });
    });

    group('VObject with VArray', () {
      test('should validate object containing a list field', () {
        final schema = VObject<_TaggedFolder>()
            .field('name', (f) => f.name, VString().min(1))
            .field('tags', (f) => f.tags, VArray<String>(VString().min(1)));

        expect(schema.validate(_TaggedFolder('Docs', ['a', 'b'])), isTrue);
        expect(schema.validate(_TaggedFolder('Docs', ['a', ''])), isFalse);
      });

      test('should include nested path for array field errors', () {
        final schema = VObject<_TaggedFolder>()
            .field('tags', (f) => f.tags, VArray<String>(VString().min(3)));

        final errs = schema.errors(_TaggedFolder('Docs', ['hello', 'ab']));
        expect(errs, isNotNull);
        expect(errs!.first.path, ['tags', 1]);
      });
    });

    group('array', () {
      test('should validate List<T> through VObject.array()', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .array();

        expect(
          schema.validate([Folder(name: 'Docs'), Folder(name: 'Photos')]),
          isTrue,
        );
      });

      test('should fail with item index + field name in error path', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(3))
            .array();

        final errors =
            schema.errors([Folder(name: 'Documents'), Folder(name: 'x')]);

        expect(errors, isNotNull);
        expect(errors!.first.path, [1, 'name']);
        expect(errors.first.code, 'string.too_small');
      });

      test('should chain array-level validators', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .array()
            .min(1)
            .unique();

        expect(schema.validate([Folder(name: 'A')]), isTrue);
        expect(schema.validate(<Folder>[]), isFalse);
      });

      test('should propagate field validation inside arrays', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(5))
            .array();

        expect(schema.validate([Folder(name: 'Docs')]), isFalse);
        expect(schema.validate([Folder(name: 'Photos')]), isTrue);
      });
    });

    group('equalFields', () {
      test('should pass when two fields are equal', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm');

        expect(
          schema.validate(_SignUp('a@b.com', 'secret', 'secret')),
          isTrue,
        );
      });

      test('should fail when two fields differ', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm');

        expect(
          schema.validate(_SignUp('a@b.com', 'secret', 'other')),
          isFalse,
        );
      });

      test('should emit object.fields_not_equal with interpolated message', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm');

        final errors = schema.errors(_SignUp('a@b.com', 'secret', 'other'));

        expect(errors, isNotNull);
        expect(errors!.first.code, 'object.fields_not_equal');
        expect(errors.first.message, 'password must be equal to confirm');
      });

      test('should throw AssertionError when field name is unknown', () {
        // Aligned with VMap.equalFields and refine(dependsOn:) — all
        // entity-level rules now use `assert` for unknown-key checks,
        // so the error class is uniform across the API.
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1));

        expect(
          () => schema.equalFields('password', 'missing'),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should respect custom message override', () {
        final schema = V
            .object<_SignUp>()
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields(
              'password',
              'confirm',
              message: 'Senhas devem coincidir',
            );

        final errors = schema.errors(_SignUp('a@b.com', 'secret', 'other'));

        expect(errors, isNotNull);
        expect(errors!.first.message, 'Senhas devem coincidir');
      });

      test('should respect locale override', () {
        V.setLocale(
          const VLocale({
            'object.fields_not_equal': '{field} difere de {other}',
          }),
        );

        final schema = V
            .object<_SignUp>()
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm');

        final errors = schema.errors(_SignUp('a@b.com', 'secret', 'other'));

        expect(errors, isNotNull);
        expect(errors!.first.message, 'password difere de confirm');
      });
    });

    group('pick', () {
      test('should keep only the requested fields', () {
        final full = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid().nullable())
            .field('name', (f) => f.name, V.string().min(1));

        final picked = full.pick(['name']);

        expect(picked.schema.keys.toList(), ['name']);
      });

      test('should still fail if the picked field is invalid', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid().nullable())
            .field('name', (f) => f.name, V.string().min(5))
            .pick(['name']);

        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('should skip validation for omitted fields', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1))
            .pick(['name']);

        expect(schema.validate(Folder(id: 'not-a-uuid', name: 'Doc')), isTrue);
      });

      test('should preserve base state (nullable) after pick', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .nullable()
            .pick(['name']);

        expect(schema.validate(null), isTrue);
      });

      test('should ignore keys that do not exist', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .pick(['name', 'missing']);

        expect(schema.schema.keys.toList(), ['name']);
      });
    });

    group('omit', () {
      test('should drop the specified fields', () {
        final full = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid().nullable())
            .field('name', (f) => f.name, V.string().min(1));

        final reduced = full.omit(['id']);

        expect(reduced.schema.keys.toList(), ['name']);
      });

      test('should keep validating the remaining fields', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(5))
            .omit(['id']);

        expect(schema.validate(Folder(name: 'Doc')), isFalse);
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should preserve base state (nullable) after omit', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1))
            .nullable()
            .omit(['id']);

        expect(schema.validate(null), isTrue);
      });
    });

    group('merge', () {
      test('should combine fields from both schemas', () {
        final a =
            V.object<Folder>().field('id', (f) => f.id, V.string().uuid());
        final b =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(1));

        final merged = a.merge(b);

        expect(merged.schema.keys.toList(), ['id', 'name']);
      });

      test('should fail if either side has an invalid field', () {
        final a =
            V.object<Folder>().field('id', (f) => f.id, V.string().uuid());
        final b =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(5));

        final merged = a.merge(b);

        expect(
          merged.validate(
            Folder(
              id: '550e8400-e29b-41d4-a716-446655440000',
              name: 'Doc',
            ),
          ),
          isFalse,
        );
      });

      test('should preserve state from both sides (nullable OR)', () {
        final a = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .nullable();
        final b =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(1));

        expect(a.merge(b).validate(null), isTrue);
      });
    });

    group('partial', () {
      test('every field accepts null', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1))
            .partial();

        expect(schema.validate(Folder(name: 'x')), isTrue);
        expect(schema.validate(Folder(id: null, name: 'x')), isTrue);
      });

      test('non-null inputs still run their original validator', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(5))
            .partial();

        expect(schema.validate(Folder(name: 'no')), isFalse);
        expect(
          schema.validate(Folder(id: 'not-a-uuid', name: 'longer')),
          isFalse,
        );
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'longer',
          )),
          isTrue,
        );
      });

      test('does not mutate the source schema', () {
        final base =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(5));

        base.partial();

        expect(base.validate(Folder(name: 'no')), isFalse);
      });

      test('preserves entity-level rules from the base', () {
        final base = V
            .object<_SignUp>()
            .field('email', (s) => s.email, V.string().email())
            .field('password', (s) => s.password, V.string())
            .field('confirm', (s) => s.confirm, V.string())
            .equalFields('password', 'confirm');

        final partial = base.partial();

        expect(
          partial.validate(_SignUp('a@b.com', 'pwd', 'pwd')),
          isTrue,
        );
        expect(
          partial.validate(_SignUp('a@b.com', 'pwd', 'mismatch')),
          isFalse,
          reason: 'equalFields rule must survive partial()',
        );
      });

      test('idempotent on already-nullable fields', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid().nullable())
            .partial();

        expect(schema.validate(Folder(name: 'x')), isTrue);
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'x',
          )),
          isTrue,
        );
      });

      test('partial(except:) keeps listed fields with original validator', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1))
            .partial(except: const ['id']);

        expect(
          schema.validate(Folder(name: 'Alice')),
          isFalse,
          reason: 'id is null but stays required',
        );
        expect(
          schema.validate(Folder(id: 'not-a-uuid', name: 'Alice')),
          isFalse,
          reason: 'id keeps the original uuid validator',
        );
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Alice',
          )),
          isTrue,
        );
      });

      test('partial(except: const []) is equivalent to partial()', () {
        final base = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1));

        final partialAll = base.partial();
        final partialEmpty = base.partial(except: const []);

        final probe = Folder(name: 'x');

        expect(partialAll.validate(probe), isTrue);
        expect(partialEmpty.validate(probe), isTrue);
      });

      test('partial(except:) does not mutate the source schema', () {
        final base = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().uuid())
            .field('name', (f) => f.name, V.string().min(1));

        base.partial(except: const ['id']);

        expect(
          base.validate(Folder(name: 'Alice')),
          isFalse,
          reason: 'base still rejects null id',
        );
      });

      test('partial(except:) preserves entity-level rules from the base', () {
        final base = V
            .object<_SignUp>()
            .field('email', (s) => s.email, V.string().email())
            .field('password', (s) => s.password, V.string())
            .field('confirm', (s) => s.confirm, V.string())
            .equalFields('password', 'confirm');

        final partial = base.partial(except: const ['email']);

        expect(
          partial.validate(_SignUp('a@b.com', 'pwd', 'pwd')),
          isTrue,
        );
        expect(
          partial.validate(_SignUp('a@b.com', 'pwd', 'mismatch')),
          isFalse,
          reason: 'equalFields rule must survive partial(except:)',
        );
      });

      test('partial(except:) asserts on undeclared fields (debug)', () {
        final schema =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(1));

        expect(
          () => schema.partial(except: const ['unknown']),
          throwsA(isA<AssertionError>()),
        );
      });

      test('partial keeps inner pipeline running through defaultValue', () {
        // Inner has a default that, after substitution, must still pass the
        // chained validator. Before the fix, the wrapper short-circuited on
        // null, so the default was never substituted and the bad value
        // slipped through. After the fix, default substitutes null and the
        // uuid() validator runs and fails.
        final schema = V
            .object<Folder>()
            .field(
              'id',
              (f) => f.id,
              V.string().defaultValue('not-a-uuid').uuid(),
            )
            .partial();

        expect(schema.validate(Folder(name: 'x')), isFalse);
      });

      test('partial preserves defaultValue when inner is also nullable', () {
        // Same as the previous test but with `.nullable()` chained on the
        // inner — confirms that the wrapper still delegates to inner so the
        // default beats the inner-nullable short-circuit (mirrors
        // `.defaultValue().nullable()` behaviour outside of partial).
        final schema = V
            .object<Folder>()
            .field(
              'id',
              (f) => f.id,
              V.string().defaultValue('not-a-uuid').uuid().nullable(),
            )
            .partial();

        expect(schema.validate(Folder(name: 'x')), isFalse);
      });
    });

    group('when', () {
      test('should apply conditional validators when condition matches', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .when('country', equals: 'US', then: {
          'taxId': V.string().min(9),
        });

        expect(schema.validate(_TaxPayer('US', '123-45-6789')), isTrue);
        expect(schema.validate(_TaxPayer('US', 'short')), isFalse);
      });

      test('should skip conditional validators when condition fails', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .when('country', equals: 'US', then: {
          'taxId': V.string().min(9),
        });

        expect(schema.validate(_TaxPayer('BR', 'short')), isTrue);
      });

      test('should include conditional field name in error path', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .when('country', equals: 'US', then: {
          'taxId': V.string().min(9),
        });

        final errors = schema.errors(_TaxPayer('US', 'short'));

        expect(errors, isNotNull);
        expect(errors!.first.path, ['taxId']);
      });

      test('should assert on unknown condition field', () {
        expect(
          () => V
              .object<_TaxPayer>()
              .field('country', (t) => t.country, V.string())
              .when('missing', equals: 'US', then: const {}),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should assert on unknown then field', () {
        expect(
          () => V
              .object<_TaxPayer>()
              .field('country', (t) => t.country, V.string())
              .when('country', equals: 'US', then: {
            'missing': V.string(),
          }),
          throwsA(isA<AssertionError>()),
        );
      });

      test('should combine with baseline validators', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string().min(2))
            .field('taxId', (t) => t.taxId, V.string().min(1))
            .when('country', equals: 'US', then: {
          'taxId': V.string().min(9),
        });

        final errors = schema.errors(_TaxPayer('US', ''));

        expect(errors, isNotNull);
        expect(errors!.length, 2);
      });
    });

    group('whenMatches', () {
      test('predicate reads multiple fields and gates extra validators', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) => p.age >= 18 && p.email.endsWith('@admin.com'),
          dependsOn: const {'age', 'email'},
          then: {'bio': V.string().min(5)},
        );

        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@admin.com',
            bio: 'long enough',
          )),
          isTrue,
        );
        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@admin.com',
            bio: null,
          )),
          isFalse,
          reason: 'predicate matches → bio must satisfy min(5)',
        );
        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 17,
            email: 'a@admin.com',
            bio: null,
          )),
          isTrue,
          reason: 'age < 18 → predicate false',
        );
        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@user.com',
            bio: null,
          )),
          isTrue,
          reason: 'email domain not admin → predicate false',
        );
      });

      test('error path includes the then field name', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) => p.age >= 18,
          dependsOn: const {'age'},
          then: {'bio': V.string().min(5)},
        );

        final errors = schema.errors(_Profile(
          name: 'A',
          age: 30,
          email: 'a@b.com',
          bio: 'no',
        ));

        expect(errors, isNotNull);
        expect(errors!.first.path, ['bio']);
      });

      test('asserts unknown dependsOn key', () {
        expect(
          () => V
              .object<_TaxPayer>()
              .field('country', (t) => t.country, V.string())
              .field('taxId', (t) => t.taxId, V.string())
              .whenMatches(
            (t) => true,
            dependsOn: const {'missing'},
            then: const {},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('asserts unknown then key (strict — VObject does not inject keys)',
          () {
        expect(
          () => V
              .object<_TaxPayer>()
              .field('country', (t) => t.country, V.string())
              .whenMatches(
            (t) => true,
            dependsOn: const {'country'},
            then: {'missing': V.string()},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('multiple whenMatches rules fire independently', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) => p.age >= 18,
          dependsOn: const {'age'},
          then: {'bio': V.string().min(2)},
        ).whenMatches(
          (p) => p.email.endsWith('@vip.com'),
          dependsOn: const {'email'},
          then: {'name': V.string().min(3)},
        );

        expect(
          schema.validate(_Profile(
            name: 'AAA',
            age: 30,
            email: 'a@vip.com',
            bio: 'ok',
          )),
          isTrue,
        );
        expect(
          schema.validate(_Profile(
            name: 'AAA',
            age: 17,
            email: 'a@vip.com',
            bio: null,
          )),
          isTrue,
          reason: 'first rule false (age) → bio stays nullable',
        );
        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@vip.com',
            bio: 'ok',
          )),
          isFalse,
          reason: 'second rule fires → name must be >= 3',
        );
      });

      test('refine.dependsOn accepts a key declared via whenMatches.then', () {
        // taxId is declared on the schema; whenMatches.then references it,
        // refine.dependsOn references it. Should pass the assertion and
        // gate the refine on taxId failures.
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(9)},
        ).refine(
          (t) => t.taxId.isNotEmpty,
          code: 'empty_taxid',
          dependsOn: const {'taxId'},
        );

        expect(schema.validate(_TaxPayer('US', '123456789')), isTrue);
        expect(schema.validate(_TaxPayer('BR', 'whatever')), isTrue);
      });

      test('hasAsync becomes true when then contains async validator', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {
            'taxId': V.string().refineAsync((s) async => s.startsWith('US-')),
          },
        );

        expect(schema.hasAsync, isTrue);
      });

      test('safeParseAsync runs sync whenMatches when container is async',
          () async {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .refineAsync((t) async => true)
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(9)},
        );

        expect(
          await schema.validateAsync(_TaxPayer('US', '123456789')),
          isTrue,
        );
        expect(
          await schema.validateAsync(_TaxPayer('US', 'short')),
          isFalse,
        );
      });

      test('async validator inside then runs through safeParseAsync', () async {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {
            'taxId':
                V.string().refineAsync((s) async => s == '123', code: 'bad'),
          },
        );

        expect(schema.hasAsync, isTrue);
        expect(
          await schema.validateAsync(_TaxPayer('US', '123')),
          isTrue,
        );
        expect(
          await schema.validateAsync(_TaxPayer('US', '999')),
          isFalse,
        );
      });

      test('predicate reading a nullable field treats null as first-class', () {
        // Pattern: "if bio is not provided, require a longer name as the
        // public-facing identifier". Mirrors VMap.whenMatches's null
        // case but on the typed entity side.
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) => p.bio == null,
          dependsOn: const {'bio'},
          then: {'name': V.string().min(5)},
        );

        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@b.com',
            bio: 'something',
          )),
          isTrue,
          reason: 'bio non-null → predicate false → name unrestricted',
        );
        expect(
          schema.validate(_Profile(
            name: 'Alice',
            age: 30,
            email: 'a@b.com',
            bio: null,
          )),
          isTrue,
          reason: 'bio null → predicate true → name has 5 chars',
        );
        expect(
          schema.validate(_Profile(
            name: 'A',
            age: 30,
            email: 'a@b.com',
            bio: null,
          )),
          isFalse,
          reason: 'bio null → predicate true → name fails min(5)',
        );
      });

      test('whenMatchesRules getter returns a snapshot', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(9)},
        );

        expect(schema.whenMatchesRules, hasLength(1));
        expect(schema.whenMatchesRules.first.dependsOn, {'country'});
        expect(
          schema.whenMatchesRules.first.then.containsKey('taxId'),
          isTrue,
        );
        expect(
          schema.whenMatchesRules.first.condition(_TaxPayer('US', 'x')),
          isTrue,
        );
        expect(
          schema.whenMatchesRules.first.condition(_TaxPayer('BR', 'x')),
          isFalse,
        );
      });

      test('merge propagates whenMatchesRules from both sides', () {
        final a = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'US',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(9)},
        );

        final b = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => t.country == 'BR',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(11)},
        );

        final merged = a.merge(b);
        expect(merged.whenMatchesRules, hasLength(2));
      });

      test('rule is skipped when a declared dependsOn field failed per-field',
          () {
        int conditionRan = 0;
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int().positive())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) {
            conditionRan++;
            return true;
          },
          dependsOn: const {'age'},
          then: {'bio': V.string().min(5)},
        );

        // age is invalid → whenMatches must be skipped entirely.
        schema.errors(
          _Profile(name: 'A', age: -1, email: 'a@b.com', bio: null),
        );

        expect(
          conditionRan,
          0,
          reason:
              'condition must not run when a declared dependsOn field failed',
        );
      });

      test('rule still runs when failing field is NOT in dependsOn', () {
        int conditionRan = 0;
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string().min(5))
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .whenMatches(
          (p) {
            conditionRan++;
            return true;
          },
          dependsOn: const {'age'},
          then: {'bio': V.string().min(5)},
        );

        // name fails min(5) but is not in dependsOn → whenMatches still runs.
        schema.errors(
          _Profile(name: 'A', age: 30, email: 'a@b.com', bio: 'x'),
        );

        expect(conditionRan, 1);
      });

      test('empty dependsOn throws AssertionError at construction', () {
        expect(
          () => V
              .object<_Profile>()
              .field('name', (p) => p.name, V.string())
              .field('age', (p) => p.age, V.int())
              .field('email', (p) => p.email, V.string().email())
              .field('bio', (p) => p.bio, V.string().nullable())
              .whenMatches(
            (p) => true,
            dependsOn: const <String>{},
            then: const <String, VType>{},
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('whenMatchesRaw — entity mode', () {
      test('condition receives map rebuilt via extractors', () {
        Map<String, dynamic>? seen;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatchesRaw(
          (m) {
            seen = m;
            return false;
          },
          dependsOn: const {'country'},
          then: const {},
        );

        schema.validate(_TaxPayer('US', '123456789'));

        expect(seen, {'country': 'US', 'taxId': '123456789'});
      });

      test('skips when whenMatches.then fails a declared dep field', () {
        // Pins B1 — when a whenMatches.then rule causes a field to fail
        // AFTER per-field iteration, a subsequent whenMatchesRaw that
        // depends on that same field MUST skip.
        var whenMatchesRawRan = 0;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatches(
          (t) => true,
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(100)},
        ).whenMatchesRaw(
          (m) {
            whenMatchesRawRan++;
            return true;
          },
          dependsOn: const {'taxId'},
          then: const {},
        );

        schema.validate(_TaxPayer('US', 'short'));

        expect(
          whenMatchesRawRan,
          0,
          reason: 'taxId failed via whenMatches.then → whenMatchesRaw with '
              'dependsOn: {taxId} must skip',
        );
      });

      test('runs when no declared dep failed (per-field + then both ok)', () {
        var whenMatchesRawRan = 0;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatchesRaw(
          (m) {
            whenMatchesRawRan++;
            return false;
          },
          dependsOn: const {'country'},
          then: const {},
        );

        schema.validate(_TaxPayer('US', '123456789'));

        expect(whenMatchesRawRan, 1);
      });

      test('survives merge() — _whenMatchesRawRules copied', () {
        final a = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .whenMatchesRaw(
          (m) => m['country'] == 'US',
          dependsOn: const {'country'},
          then: {'taxId': V.string().min(9)},
        );
        final b = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string());

        final merged = a.merge(b);
        expect(merged.whenMatchesRawRules, hasLength(1));
      });
    });

    group('refineFieldRaw (Map-typed) — entity mode', () {
      test('callback receives map rebuilt via extractors (stage: post)', () {
        Map<String, dynamic>? seen;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .refineFieldRaw(
          (m) {
            seen = m;
            return true;
          },
          path: 'taxId',
        );

        schema.validate(_TaxPayer('US', '123'));

        expect(seen, {'country': 'US', 'taxId': '123'});
      });

      test('stage: post skips when declared dep failed', () {
        var ran = 0;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string().min(2))
            .field('taxId', (t) => t.taxId, V.string())
            .refineFieldRaw(
          (m) {
            ran++;
            return true;
          },
          path: 'taxId',
          dependsOn: const {'country'},
        );

        schema.validate(_TaxPayer('U', '123'));

        expect(ran, 0, reason: 'country failed min(2) → refineFieldRaw skips');
      });

      test('emits VError with code custom and the declared path', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .refineFieldRaw(
              (m) => false,
              path: 'taxId',
              message: 'forbidden',
            );

        final errors = schema.errors(_TaxPayer('US', '123'));
        expect(errors, isNotNull);
        expect(errors!.last.path, ['taxId']);
        expect(errors.last.message, 'forbidden');
      });

      test('async — runs through safeParseAsync', () async {
        var ran = 0;
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field(
              'taxId',
              (t) => t.taxId,
              V.string().refineAsync((s) async => true),
            )
            .refineFieldRaw(
          (m) {
            ran++;
            return true;
          },
          path: 'taxId',
        );

        expect(schema.hasAsync, isTrue);
        await schema.validateAsync(_TaxPayer('US', '123456789'));
        expect(ran, 1);
      });

      test('survives pick() — _rawFieldRules copied via _copyObjectStateTo',
          () {
        var ran = 0;
        final base = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .refineFieldRaw(
          (m) {
            ran++;
            return true;
          },
          path: 'country',
        );

        final picked = base.pick(<String>['country']);
        picked.validate(_TaxPayer('US', '123'));

        expect(ran, 1, reason: 'refineFieldRaw must survive .pick()');
      });

      test('survives merge() — _rawFieldRules copied from both sides', () {
        var ranA = 0;
        var ranB = 0;
        final a = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .refineFieldRaw(
          (m) {
            ranA++;
            return true;
          },
          path: 'country',
        );
        final b = V
            .object<_TaxPayer>()
            .field('taxId', (t) => t.taxId, V.string())
            .refineFieldRaw(
          (m) {
            ranB++;
            return true;
          },
          path: 'taxId',
        );

        a.merge(b).validate(_TaxPayer('US', '123'));

        expect(ranA, 1);
        expect(ranB, 1);
      });
    });

    group('refineField', () {
      test('should emit error scoped to the declared path', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .refineField(
              (f) => f.name.length >= 5,
              path: 'name',
              message: 'Name too short',
            );

        final errors = schema.errors(Folder(name: 'Doc'));

        expect(errors, isNotNull);
        expect(errors!.first.path, ['name']);
        expect(errors.first.message, 'Name too short');
      });

      test('should pass when predicate returns true', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .refineField(
              (f) => f.name.length >= 5,
              path: 'name',
              message: 'Name too short',
            );

        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should assert on unknown path', () {
        expect(
          () => V
              .object<Folder>()
              .field('name', (f) => f.name, V.string())
              .refineField((f) => true, path: 'missing'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('immutability (pick/omit/merge return fresh instances)', () {
      test('pick returns a new VObject distinct from the source', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int());

        final picked = base.pick(['name']);

        expect(identical(base, picked), isFalse);
        expect(base.schema.keys.toList(), ['name', 'age']);
        expect(picked.schema.keys.toList(), ['name']);
      });

      test('mutating the picked schema does not affect the source', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int());
        final picked = base.pick(['name']);

        picked.field('email', (p) => p.email, V.string().email());

        expect(base.schema.keys.toList(), ['name', 'age']);
        expect(picked.schema.keys.toList(), ['name', 'email']);
      });

      test('omit returns a new VObject distinct from the source', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int());
        final omitted = base.omit(['age']);

        expect(identical(base, omitted), isFalse);
      });

      test('merge returns a new VObject distinct from both sources', () {
        final a = V.object<_Profile>().field('name', (p) => p.name, V.string());
        final b = V.object<_Profile>().field('age', (p) => p.age, V.int());

        final merged = a.merge(b);

        expect(identical(merged, a), isFalse);
        expect(identical(merged, b), isFalse);
      });
    });

    group('composition algebra', () {
      test('pick + empty list yields a schema with no fields', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .pick(<String>[]);

        expect(schema.schema, isEmpty);
        expect(
          schema.validate(_Profile(name: 'Jo', age: 30, email: 'a@b.com')),
          isTrue,
        );
      });

      test('omit + every key yields a schema with no fields', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .omit(['name', 'age']);

        expect(schema.schema, isEmpty);
      });

      test('pick(K).pick(K) is idempotent', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .field('email', (p) => p.email, V.string().email());

        final once = base.pick(['name', 'age']);
        final twice = once.pick(['name', 'age']);

        expect(twice.schema.keys.toList(), once.schema.keys.toList());
      });

      test('pick + omit cancel each other when keys disjoint', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int());

        final picked = base.pick(['name']);
        final pickedAndOmitted = picked.omit(['age']);

        expect(pickedAndOmitted.schema.keys.toList(), ['name']);
      });

      test('pick after omit drops the omitted key', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int());

        final result = base.omit(['age']).pick(['age', 'name']);

        expect(result.schema.keys.toList(), ['name']);
      });

      test('merge with itself duplicates field entries', () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string().min(1));

        final merged = base.merge(base);

        expect(merged.schema.keys.length, 1);
        expect(
          merged.errors(_Profile(name: '', age: 0, email: 'a@b.com'))?.length,
          2,
          reason: 'both copies of the same validator should fire',
        );
      });

      test('merge order: base fields appear before other fields', () {
        final a = V.object<_Profile>().field('name', (p) => p.name, V.string());
        final b = V.object<_Profile>().field('age', (p) => p.age, V.int());

        final merged = a.merge(b);

        expect(merged.schema.keys.toList(), ['name', 'age']);
      });
    });

    group('state preservation through pick/omit/merge', () {
      test('pick preserves nullable from base', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .nullable()
            .pick(['name']);

        expect(schema.validate(null), isTrue);
      });

      test('omit preserves defaultValue from base', () {
        final fallback =
            _Profile(name: 'fallback', age: 0, email: 'fallback@x.com');
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .defaultValue(fallback)
            .omit(['age']);

        expect(schema.parse(null), fallback);
      });

      test('pick preserves entity-level refine from base', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .refine((p) => p.age >= 0, code: 'neg_age')
            .pick(['name']);

        final errs = _Profile(name: 'Jo', age: -1, email: 'a@b.com');

        expect(
          schema.errors(errs)?.first.code,
          'neg_age',
          reason:
              'refine must survive pick even when it depends on dropped field',
        );
      });

      test('pick preserves equalFields validator (extractor still works)', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm')
            .pick(['email']);

        expect(
          schema.validate(_SignUp('a@b.com', 'x', 'y')),
          isFalse,
          reason: 'equalFields extractor was captured before pick',
        );
      });

      test('merge ORs nullable from both sides (true || false → true)', () {
        final nullable = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .nullable();
        final notNullable =
            V.object<_Profile>().field('age', (p) => p.age, V.int());

        expect(nullable.merge(notNullable).validate(null), isTrue);
        expect(notNullable.merge(nullable).validate(null), isTrue);
      });

      test('merge concatenates pipeline steps (both refines fire)', () {
        final a = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .refine((p) => p.name != 'forbidden_a', code: 'a_violation');
        final b = V
            .object<_Profile>()
            .field('age', (p) => p.age, V.int())
            .refine((p) => p.age > 0, code: 'b_violation');

        final merged = a.merge(b);

        final errors = merged
            .errors(_Profile(name: 'forbidden_a', age: 0, email: 'a@b.com'));
        expect(
          errors?.map((e) => e.code).toSet(),
          containsAll(<String>['a_violation', 'b_violation']),
        );
      });

      test('merge propagates whenRules from both sides', () {
        final a = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .when('name', equals: 'trigger_a', then: {
          'name': V.string().min(100),
        });
        final b = V
            .object<_Profile>()
            .field('age', (p) => p.age, V.int())
            .when('age', equals: 7, then: {
          'age': V.int().min(100),
        });

        final merged = a.merge(b);

        expect(merged.whenRules.length, 2);
      });

      test('pick preserves preprocess on the base schema', () {
        var preprocessorRan = 0;
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .preprocess((input) {
          preprocessorRan++;
          return input;
        }).pick(['name']);

        schema.validate(_Profile(name: 'Jo', age: 1, email: 'a@b.com'));
        expect(preprocessorRan, 1);
      });

      test('omit preserves preprocess on the base schema', () {
        var preprocessorRan = 0;
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('age', (p) => p.age, V.int())
            .preprocess((input) {
          preprocessorRan++;
          return input;
        }).omit(['age']);

        schema.validate(_Profile(name: 'Jo', age: 1, email: 'a@b.com'));
        expect(preprocessorRan, 1);
      });

      test('merge concatenates preprocessors from both sides in order', () {
        final order = <String>[];
        final a = V.object<_Profile>().preprocess((input) {
          order.add('a');

          return input;
        });
        final b = V.object<_Profile>().preprocess((input) {
          order.add('b');

          return input;
        });

        a.merge(b).validate(_Profile(name: 'Jo', age: 1, email: 'a@b.com'));
        expect(order, ['a', 'b']);
      });

      test('pick preserves defaultValue from base', () {
        final fallback =
            _Profile(name: 'fallback', age: 0, email: 'fallback@x.com');
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .defaultValue(fallback)
            .pick(['name']);

        expect(schema.parse(null), fallback);
      });

      test('merge propagates defaultValue — other wins when both set', () {
        final left = _Profile(name: 'left', age: 0, email: 'left@x.com');
        final right = _Profile(name: 'right', age: 0, email: 'right@x.com');

        final a = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .defaultValue(left);
        final b = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .defaultValue(right);

        expect(a.merge(b).parse(null), right);
      });

      test('equalFields survives omit of the referenced field', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1))
            .field('confirm', (d) => d.confirm, V.string().min(1))
            .equalFields('password', 'confirm')
            .omit(['confirm']);

        expect(
          schema.validate(_SignUp('a@b.com', 'x', 'y')),
          isFalse,
          reason:
              'extractor for confirm was captured before omit, so equalFields still fires',
        );
      });

      test('merge propagates refineField step from base', () {
        final a = V
            .object<_Profile>()
            .field('email', (p) => p.email, V.string())
            .refineField(
              (p) => p.email.endsWith('@example.com'),
              path: 'email',
              message: 'must be example.com',
            );
        final b = V.object<_Profile>().field('name', (p) => p.name, V.string());

        final merged = a.merge(b);
        final errors = merged.errors(
          _Profile(name: 'ok', age: 0, email: 'x@other.com'),
        );

        expect(errors, isNotNull);
        expect(errors!.first.path, ['email']);
        expect(errors.first.message, 'must be example.com');
      });
    });

    group('when edge cases', () {
      test('equals: null fires when extractor returns null', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().nullable())
            .field('name', (f) => f.name, V.string())
            .when('id', equals: null, then: {
          'name': V.string().min(20),
        });

        expect(schema.validate(Folder(name: 'Documents')), isFalse);
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'x',
          )),
          isTrue,
          reason: 'when does not fire when id is non-null',
        );
      });

      test('then: {} (empty) is a no-op even if condition matches', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string())
            .when('country', equals: 'US', then: const {});

        expect(schema.validate(_TaxPayer('US', 'x')), isTrue);
      });

      test('multiple when rules can fire on the same input independently', () {
        final schema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string().min(1))
            .when('country', equals: 'US', then: {
          'taxId': V.string().min(9),
        }).when('country', equals: 'US', then: {
          'taxId': V.string().contains('-'),
        });

        expect(schema.validate(_TaxPayer('US', '123-45-6789')), isTrue);
        expect(schema.validate(_TaxPayer('US', '123456789')), isFalse);
      });

      test('when on the same field as then runs additional validation', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .when('name', equals: 'x', then: {
          'name': V.string().min(5),
        });

        expect(schema.validate(Folder(name: 'x')), isFalse);
        expect(schema.validate(Folder(name: 'normal')), isTrue);
      });

      test('whenRules getter returns a snapshot of registered rules', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .when('name', equals: 'x', then: const {});

        expect(schema.whenRules, hasLength(1));
        expect(schema.whenRules.first.field, 'name');
        expect(schema.whenRules.first.equals, 'x');
      });

      test('equals: int compares by value for numeric fields', () {
        final schema = V
            .object<_Profile>()
            .field('age', (p) => p.age, V.int())
            .field('name', (p) => p.name, V.string())
            .when('age', equals: 18, then: {
          'name': V.string().min(50),
        });

        expect(
          schema.validate(_Profile(name: 'short', age: 18, email: 'a@b.com')),
          isFalse,
        );
        expect(
          schema.validate(_Profile(name: 'short', age: 20, email: 'a@b.com')),
          isTrue,
        );
      });

      test('equals: enum value triggers correctly', () {
        final schema = V
            .object<_KitchenSinkEntity>()
            .field('status', (e) => e.status, V.enm(_AccountStatus.values))
            .field('name', (e) => e.name, V.string())
            .when('status', equals: _AccountStatus.deleted, then: {
          'name': V.string().min(100),
        });

        final deleted = _KitchenSinkEntity(
          name: 'x',
          age: 1,
          balance: 0,
          active: false,
          joined: DateTime(2024),
          tags: const [],
          prefs: const {},
          status: _AccountStatus.deleted,
          id: 1,
        );
        final active = _KitchenSinkEntity(
          name: 'x',
          age: 1,
          balance: 0,
          active: true,
          joined: DateTime(2024),
          tags: const [],
          prefs: const {},
          status: _AccountStatus.active,
          id: 1,
        );

        expect(schema.validate(deleted), isFalse);
        expect(schema.validate(active), isTrue);
      });

      test('equals: DateTime compares by == (same instant)', () {
        final anchor = DateTime.utc(2024, 1, 1);
        final schema = V
            .object<_KitchenSinkEntity>()
            .field('joined', (e) => e.joined, V.date())
            .field('name', (e) => e.name, V.string())
            .when('joined', equals: anchor, then: {
          'name': V.string().min(50),
        });

        final match = _KitchenSinkEntity(
          name: 'x',
          age: 1,
          balance: 0,
          active: true,
          joined: anchor,
          tags: const [],
          prefs: const {},
          status: _AccountStatus.active,
          id: 1,
        );

        expect(schema.validate(match), isFalse);
      });
    });

    group('equalFields edge cases', () {
      test('comparing a field to itself is always equal', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .equalFields('name', 'name');

        expect(schema.validate(Folder(name: 'anything')), isTrue);
      });

      test('two null extractor values compare equal (null == null)', () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().nullable())
            .field('aliasId', (f) => f.id, V.string().nullable())
            .equalFields('id', 'aliasId');

        expect(schema.validate(Folder(name: 'x')), isTrue);
      });

      test('two list-typed fields use Dart identity equality (not deep)', () {
        // Reminder: List `==` is identity in Dart. equalFields exposes that.
        final shared = ['a', 'b'];
        final schema = V
            .object<_TaggedFolder>()
            .field('tags', (f) => f.tags, V.array(V.string()))
            .field('mirror', (f) => f.tags, V.array(V.string()))
            .equalFields('tags', 'mirror');

        expect(
          schema.validate(_TaggedFolder('docs', shared)),
          isTrue,
          reason: 'both extractors return the same list reference',
        );
      });

      test('multiple equalFields rules accumulate', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string())
            .field('password', (d) => d.password, V.string())
            .field('confirm', (d) => d.confirm, V.string())
            .equalFields('email', 'password')
            .equalFields('password', 'confirm');

        final errors = schema.errors(_SignUp('a@b.com', 'pwd', 'pwd'));

        expect(errors?.length, 1);
        expect(errors!.first.code, 'object.fields_not_equal');
      });
    });

    group('refineField edge cases', () {
      test('multiple refineField on same path collects multiple errors', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .refineField((f) => f.name.length >= 3, path: 'name', message: 'A')
            .refineField((f) => f.name.length >= 5, path: 'name', message: 'B');

        final errors = schema.errors(Folder(name: 'ab'));
        expect(errors?.length, 2);
      });

      test('refineField predicate can read across multiple fields', () {
        final schema = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string())
            .field('email', (p) => p.email, V.string().email())
            .refineField(
              (p) => p.email.contains(p.name),
              path: 'email',
              message: 'email must contain the name',
            );

        expect(
          schema.validate(_Profile(name: 'jo', age: 30, email: 'jo@x.com')),
          isTrue,
        );
        expect(
          schema.validate(_Profile(name: 'ana', age: 30, email: 'jo@x.com')),
          isFalse,
        );
      });
    });

    group('extreme mixing (kitchen sink for new methods)', () {
      test(
          'all composition operators in a single chain produce expected errors',
          () {
        final base = V
            .object<_Profile>()
            .field('name', (p) => p.name, V.string().min(1))
            .field('age', (p) => p.age, V.int().between(0, 150))
            .field('email', (p) => p.email, V.string().email())
            .field('bio', (p) => p.bio, V.string().nullable())
            .when('age', equals: 0, then: {
          'name': V.string().min(20),
        }).refineField(
          (p) => p.email.endsWith('@example.com'),
          path: 'email',
          message: 'must be example.com',
        );

        final audit =
            V.object<_Profile>().field('email', (p) => p.email, V.string());

        final extended = base.omit(['bio']).merge(audit);

        final ok = _Profile(
          name: 'Alice',
          age: 30,
          email: 'a@example.com',
          bio: 'optional bio still set on the instance',
        );
        expect(extended.validate(ok), isTrue);

        final whenViolation =
            _Profile(name: 'Bob', age: 0, email: 'b@example.com');
        final errors = extended.errors(whenViolation);
        expect(errors, isNotNull);
        expect(
          errors!.any((e) => e.path.first == 'name'),
          isTrue,
          reason: 'when fired because age == 0',
        );

        final emailViolation =
            _Profile(name: 'Carol', age: 30, email: 'c@other.com');
        final emailErrors = extended.errors(emailViolation);
        expect(emailErrors!.first.message, 'must be example.com');
      });

      test('nested array of objects with conditional rules', () {
        final personSchema = V
            .object<_TaxPayer>()
            .field('country', (t) => t.country, V.string())
            .field('taxId', (t) => t.taxId, V.string().min(1))
            .when('country', equals: 'US', then: {
          'taxId': V.string().contains('-'),
        });

        final listSchema = personSchema.array().min(1);

        expect(
          listSchema.validate([
            _TaxPayer('US', '123-45-6789'),
            _TaxPayer('BR', '123456789'),
          ]),
          isTrue,
        );

        final errors = listSchema.errors([
          _TaxPayer('US', '123456789'),
          _TaxPayer('BR', '987654321'),
        ]);
        expect(errors, isNotNull);
        expect(errors!.first.path.first, 0);
      });

      test('VObject inside VMap inside VObject, all with composition', () {
        final inner = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .field('id', (f) => f.id, V.string().nullable())
            .pick(['name']);

        final mapSchema = V.map({
          'folder': inner,
        });

        expect(
          mapSchema.validate({'folder': Folder(name: 'Docs')}),
          isTrue,
        );

        final errors = mapSchema.errors({'folder': Folder(name: '')});
        expect(errors!.first.path, ['folder', 'name']);
      });
    });

    group('runtime contracts', () {
      test(
          'field declared twice keeps both validators (last extractor wins '
          'in extract())', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string().min(1))
            .field('name', (f) => f.name, V.string().min(20));

        expect(schema.validate(Folder(name: 'Documents')), isFalse);
        expect(schema.errors(Folder(name: 'Documents'))?.length, 1);
      });

      test('whenRules are mutated in place when calling .when() on a copy', () {
        final base =
            V.object<Folder>().field('name', (f) => f.name, V.string());

        final copy = base.pick(['name']);

        copy.when('name', equals: 'x', then: const {});

        expect(base.whenRules, isEmpty);
        expect(copy.whenRules, hasLength(1));
      });

      test('pick of zero matching keys returns empty schema (not the original)',
          () {
        final base =
            V.object<Folder>().field('name', (f) => f.name, V.string());

        final picked = base.pick(['nonexistent']);

        expect(picked.schema, isEmpty);
        expect(identical(picked, base), isFalse);
      });

      test('omit with non-existent keys is a no-op (returns equivalent schema)',
          () {
        final base =
            V.object<Folder>().field('name', (f) => f.name, V.string().min(5));

        final omitted = base.omit(['nonexistent', 'also_missing']);

        expect(omitted.schema.keys.toList(), ['name']);
        expect(omitted.validate(Folder(name: 'Doc')), isFalse);
        expect(omitted.validate(Folder(name: 'Documents')), isTrue);
      });

      test('VObject with zero fields still runs entity-level refines', () {
        final schema = V.object<Folder>().refine(
              (f) => f.name.isNotEmpty,
              code: 'empty_name',
            );

        expect(schema.validate(Folder(name: 'ok')), isTrue);
        expect(schema.validate(Folder(name: '')), isFalse);
      });

      test('pick onto already-empty schema returns empty', () {
        final empty = V.object<Folder>();

        expect(empty.pick(['name']).schema, isEmpty);
      });

      test('pick with duplicate keys in the argument list is deduped', () {
        final base =
            V.object<Folder>().field('name', (f) => f.name, V.string());

        final picked = base.pick(['name', 'name', 'name']);

        expect(picked.schema.keys.toList(), ['name']);
      });

      test(
          'refineField added BEFORE pick retains path even when that field is no '
          'longer in the pick result', () {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .field('id', (f) => f.id, V.string().nullable())
            .refineField(
              (f) => f.name.length >= 5,
              path: 'name',
              message: 'name too short',
            )
            .pick(['id']);

        final errors = schema.errors(Folder(name: 'ab'));
        expect(errors, isNotNull);
        expect(
          errors!.first.path,
          ['name'],
          reason:
              'refine step captured before pick keeps its declared path — documents that refineField is entity-level',
        );
      });
    });

    group('kitchen sink (all types combined)', () {
      final schema = V
          .object<_KitchenSinkEntity>()
          .field('name', (e) => e.name, V.string().min(1))
          .field('date.age', (e) => e.age, V.int().between(0, 150))
          .field('balance', (e) => e.balance, V.double().finite())
          .field('active', (e) => e.active, V.bool().isTrue())
          .field(
            'joined',
            (e) => e.joined,
            V.date().before(DateTime(2030)),
          )
          .field(
            'tags',
            (e) => e.tags,
            V.string().min(2).array().min(1).unique(),
          )
          .field(
            'prefs',
            (e) => e.prefs,
            V.map({
              'theme': V.literal('dark'),
              'notifications': V.bool(),
            }),
          )
          .field(
            'status',
            (e) => e.status,
            V.enm(_AccountStatus.values),
          )
          .field(
            'id',
            (e) => e.id,
            V.union([V.string().uuid(), V.int().min(1)]),
          )
          .refineField(
            // Raw rule — runs at step 4 of the container pipeline, before
            // any field's own preprocess / validators / transforms apply.
            (entity) => entity.name != 'forbidden',
            path: 'name',
            message: 'Name "forbidden" is reserved',
            stage: RefineStage.pre,
          );

      _KitchenSinkEntity goodEntity() => _KitchenSinkEntity(
            name: 'Alice',
            age: 30,
            balance: 1234.56,
            active: true,
            joined: DateTime(2024, 1, 15),
            tags: ['dev', 'ops'],
            prefs: {'theme': 'dark', 'notifications': true},
            status: _AccountStatus.active,
            id: 42,
          );

      test('accepts an entity with every field valid', () {
        expect(schema.validate(goodEntity()), isTrue);
      });

      test('accepts UUID string in the union id field', () {
        final entity = _KitchenSinkEntity(
          name: goodEntity().name,
          age: goodEntity().age,
          balance: goodEntity().balance,
          active: goodEntity().active,
          joined: goodEntity().joined,
          tags: goodEntity().tags,
          prefs: goodEntity().prefs,
          status: goodEntity().status,
          id: '550e8400-e29b-41d4-a716-446655440000',
        );
        expect(schema.validate(entity), isTrue);
      });

      test('reports path-precise errors for every failing field', () {
        final bad = _KitchenSinkEntity(
          name: '',
          age: 200,
          balance: double.infinity,
          active: false,
          joined: DateTime(2040),
          tags: <String>[],
          prefs: {'theme': 'light', 'notifications': true},
          status: _AccountStatus.active,
          id: 'not-a-uuid',
        );

        final errors = schema.errors(bad);
        expect(errors, isNotNull);

        final paths = errors!.map((e) => e.path.first).toSet();
        expect(
          paths,
          containsAll(<Object>[
            'name',
            'date.age',
            'balance',
            'active',
            'joined',
            'tags',
            'prefs',
            'id',
          ]),
        );
      });

      test('nested map field error keeps nested path', () {
        final bad = _KitchenSinkEntity(
          name: goodEntity().name,
          age: goodEntity().age,
          balance: goodEntity().balance,
          active: goodEntity().active,
          joined: goodEntity().joined,
          tags: goodEntity().tags,
          prefs: {'theme': 'light', 'notifications': true},
          status: goodEntity().status,
          id: goodEntity().id,
        );

        final errors = schema.errors(bad);
        expect(
          errors!.any(
            (e) =>
                e.path.length == 2 &&
                e.path[0] == 'prefs' &&
                e.path[1] == 'theme',
          ),
          isTrue,
        );
      });

      test('array field error carries index in path', () {
        final bad = _KitchenSinkEntity(
          name: goodEntity().name,
          age: goodEntity().age,
          balance: goodEntity().balance,
          active: goodEntity().active,
          joined: goodEntity().joined,
          tags: ['ok', 'x'],
          prefs: goodEntity().prefs,
          status: goodEntity().status,
          id: goodEntity().id,
        );

        final errors = schema.errors(bad);
        expect(
          errors!.any(
            (e) => e.path.length == 2 && e.path[0] == 'tags' && e.path[1] == 1,
          ),
          isTrue,
        );
      });

      test('refineFieldRaw fires alongside per-field validation', () {
        // Raw rule on `name` runs once the cast to T succeeded, before
        // per-field iteration. Pin the integration with everything else
        // in the kitchen-sink schema.
        final blocked = _KitchenSinkEntity(
          name: 'forbidden',
          age: goodEntity().age,
          balance: goodEntity().balance,
          active: goodEntity().active,
          joined: goodEntity().joined,
          tags: goodEntity().tags,
          prefs: goodEntity().prefs,
          status: goodEntity().status,
          id: goodEntity().id,
        );
        final errors = schema.errors(blocked);
        expect(errors, isNotNull);
        expect(
          errors!.any(
            (e) =>
                e.path.length == 1 &&
                e.path.first == 'name' &&
                e.message.contains('forbidden'),
          ),
          isTrue,
          reason: 'kitchen sink schema must surface refineFieldRaw error under '
              'the [name] path',
        );
      });
    });

    group('extract()', () {
      test('returns a Map keyed by field name with values from the instance',
          () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string())
            .field('password', (d) => d.password, V.string())
            .field('confirm', (d) => d.confirm, V.string());

        final data = schema.extract(_SignUp('a@b.com', 'pw', 'pw'));

        expect(data, {
          'email': 'a@b.com',
          'password': 'pw',
          'confirm': 'pw',
        });
      });
    });

    group('assertion errors on schema construction', () {
      test('equalFields throws when fieldA does not exist in the schema', () {
        final schema = V
            .object<_SignUp>()
            .field('password', (d) => d.password, V.string())
            .field('confirm', (d) => d.confirm, V.string());

        expect(
          () => schema.equalFields('missing', 'confirm'),
          throwsA(isA<AssertionError>()),
        );
      });

      test(
          'refineField with dependsOn key in whenRules.then passes the assertion',
          () {
        final schema = V
            .object<Folder>()
            .field('id', (f) => f.id, V.string().nullable())
            .field('name', (f) => f.name, V.string())
            .when('name', equals: 'admin', then: {'id': V.string().min(1)});

        expect(
          () => schema.refineField(
            (f) => true,
            path: 'name',
            dependsOn: const {'id'},
          ),
          returnsNormally,
        );
      });

      test('refineField with dependsOn key not declared anywhere throws', () {
        final schema =
            V.object<Folder>().field('name', (f) => f.name, V.string());

        expect(
          () => schema.refineField(
            (f) => true,
            path: 'name',
            dependsOn: const {'unknownKey'},
          ),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('async safeParse behavior', () {
      test('safeParseAsync rejects wrong-typed input with invalid_type',
          () async {
        final schema = V
            .object<Folder>()
            .field('name', (f) => f.name, V.string())
            .refineAsync((f) async => f.name.isNotEmpty);

        final errors = await schema.errorsAsync('not a Folder');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'object.invalid_type');
      });
    });
  });
}
