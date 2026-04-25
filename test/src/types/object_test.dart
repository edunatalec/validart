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

      test('should throw ArgumentError when field name is unknown', () {
        final schema = V
            .object<_SignUp>()
            .field('email', (d) => d.email, V.string().email())
            .field('password', (d) => d.password, V.string().min(1));

        expect(
          () => schema.equalFields('password', 'missing'),
          throwsA(isA<ArgumentError>()),
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
    });
  });
}
