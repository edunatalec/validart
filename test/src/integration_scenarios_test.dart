// Integration scenarios — realistic DTOs + deliberately chaotic mixes of
// every pipeline method. Each test exercises at least TWO features together
// to catch interactions that isolated unit tests miss.

import 'package:test/test.dart';
import 'package:validart/validart.dart';

enum _Role { admin, user, guest }

class _SignUpDto {
  final String email;
  final String password;
  final String confirm;
  final int age;
  const _SignUpDto({
    required this.email,
    required this.password,
    required this.confirm,
    required this.age,
  });
}

class _BlogPost {
  final String title;
  final String body;
  final List<String> tags;
  final _Role authorRole;
  const _BlogPost({
    required this.title,
    required this.body,
    required this.tags,
    required this.authorRole,
  });
}

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('real-world: user signup DTO', () {
    VObject<_SignUpDto> buildSchema() => V
        .object<_SignUpDto>()
        .field('email', (d) => d.email, V.string().email().trim())
        .field('password', (d) => d.password, V.string().password())
        .field('confirm', (d) => d.confirm, V.string())
        .field('age', (d) => d.age, V.int().min(13).max(120))
        .equalFields('password', 'confirm')
        .refineField(
          (d) => !d.email.endsWith('@tempmail.com'),
          path: 'email',
          message: 'Disposable emails are not allowed',
        );

    test('accepts a valid signup', () {
      expect(
        buildSchema().validate(
          const _SignUpDto(
            email: 'alice@example.com',
            password: 'Str0ng!Pass',
            confirm: 'Str0ng!Pass',
            age: 30,
          ),
        ),
        isTrue,
      );
    });

    test('collects every per-field error in a single pass', () {
      // Important: entity-level validators (equalFields / refineField) are
      // suppressed while any per-field validator still has errors.
      // `_runPipeline` (where those live) only fires when field validation
      // fully passes. See the "design: pipeline short-circuit" group below
      // for a dedicated probe.
      final errors = buildSchema().errors(
        const _SignUpDto(
          email: 'bad',
          password: 'weak',
          confirm: 'mismatch',
          age: 5,
        ),
      );

      expect(errors, isNotNull);
      expect(errors!.map((e) => e.path.first).toSet(), {
        'email',
        'password',
        'age',
      });
    });

    test('fires equalFields + refineField when all per-field checks pass', () {
      final errors = buildSchema().errors(
        const _SignUpDto(
          email: 'leak@tempmail.com',
          password: 'Str0ng!Pass',
          confirm: 'different',
          age: 30,
        ),
      );

      final codes = errors!.map((e) => e.code).toSet();
      expect(codes, contains('object.fields_not_equal'));
      expect(codes, contains('custom'));
    });
  });

  group('real-world: partial UPDATE payload via VMap.partial()', () {
    final baseShape = V.map({
      'displayName': V.string().min(1).max(50),
      'avatarUrl': V.string().url(),
      'age': V.int().min(13).max(120),
    });
    final patchShape = baseShape.partial();

    test('accepts empty patch (all nullable)', () {
      expect(patchShape.validate(<String, dynamic>{}), isTrue);
    });

    test('validates provided fields, ignores missing ones', () {
      expect(patchShape.validate({'displayName': 'Alice'}), isTrue);
      expect(patchShape.validate({'displayName': ''}), isFalse);
    });

    test('mixes valid and invalid fields', () {
      final errors = patchShape.errors({
        'displayName': 'Alice',
        'avatarUrl': 'not-a-url',
      });
      expect(errors!.first.path, ['avatarUrl']);
    });
  });

  group('real-world: conditional validation on role', () {
    final schema = V.map({
      'role': V.string(),
      'name': V.string().min(1),
      'permissions': V.array(V.string()).nullable(),
    }).when('role', equals: 'admin', then: {
      'permissions': V.array(V.string()).min(1),
    }).when('role', equals: 'guest', then: {
      'name': V.string().min(3),
    });

    test('admin without permissions fails', () {
      expect(
        schema.validate({'role': 'admin', 'name': 'Al', 'permissions': null}),
        isFalse,
      );
    });

    test('admin with at least one permission passes', () {
      expect(
        schema.validate({
          'role': 'admin',
          'name': 'Al',
          'permissions': ['read'],
        }),
        isTrue,
      );
    });

    test('guest with short name fails (extra rule on name)', () {
      expect(
        schema.validate({'role': 'guest', 'name': 'Al', 'permissions': null}),
        isFalse,
      );
    });

    test('user role bypasses both conditionals', () {
      expect(
        schema.validate({'role': 'user', 'name': 'A', 'permissions': null}),
        isTrue,
      );
    });
  });

  group('real-world: coerce + preprocess + transform pipeline', () {
    test('string "42" → int 42 → doubled via transform', () {
      final schema = V.coerce.int().transform<int>((i) => i * 2);
      expect(schema.parse('42'), 84);
    });

    test('preprocess trims before coerce, transform renders as string', () {
      final schema = V.coerce
          .int()
          .preprocess((v) => v is String ? v.trim() : v)
          .transform<String>((i) => 'N=$i');
      expect(schema.parse('  7  '), 'N=7');
    });
  });

  group('real-world: async username-availability check', () {
    const takenUsernames = {'alice', 'bob'};

    VObject<Map<String, String>> buildSchema() => V
        .map({
          'username': V.string().min(3).refineAsync(
                (u) async => !takenUsernames.contains(u),
                code: 'username_taken',
              ),
          'email': V.string().email(),
        })
        .refine((m) => m['username'] != m['email'])
        .cast();

    test('accepts a free username', () async {
      final schema = V.map({
        'username': V.string().min(3).refineAsync(
              (u) async => !takenUsernames.contains(u),
              code: 'username_taken',
            ),
        'email': V.string().email(),
      });
      expect(
        await schema.validateAsync({
          'username': 'charlie',
          'email': 'c@example.com',
        }),
        isTrue,
      );
    });

    test('rejects a taken username with dedicated code', () async {
      final schema = V.map({
        'username': V.string().min(3).refineAsync(
              (u) async => !takenUsernames.contains(u),
              code: 'username_taken',
            ),
      });
      final errors = await schema.errorsAsync({'username': 'alice'});
      expect(errors, isNotNull);
      expect(errors!.first.code, 'username_taken');
      expect(errors.first.path, ['username']);
    });

    test('async field errors are collected alongside sync ones', () async {
      final schema = V.map({
        'username': V.string().min(3).refineAsync(
              (u) async => !takenUsernames.contains(u),
              code: 'username_taken',
            ),
        'email': V.string().email(),
      });

      final errors = await schema.errorsAsync({
        'username': 'alice',
        'email': 'not-an-email',
      });

      final codes = errors!.map((e) => e.code).toSet();
      expect(codes, contains('username_taken'));
      expect(codes, contains('string.email'));
    });

    // Silence unused_element warning on the buildSchema helper above.
    test('buildSchema helper compiles', () {
      expect(buildSchema, isA<Function>());
    });
  });

  group('chaos: deeply nested containers', () {
    test('VObject inside VArray inside VMap validates through every layer', () {
      final schema = V.map({
        'posts': V
            .object<_BlogPost>()
            .field('title', (p) => p.title, V.string().min(3))
            .field('body', (p) => p.body, V.string().min(10))
            .field(
              'tags',
              (p) => p.tags,
              V.string().min(2).array().min(1).unique(),
            )
            .field('authorRole', (p) => p.authorRole, V.enm(_Role.values))
            .array()
            .min(1),
      });

      final ok = {
        'posts': [
          const _BlogPost(
            title: 'Hello',
            body: 'This is a longer body',
            tags: ['intro', 'meta'],
            authorRole: _Role.admin,
          ),
        ],
      };
      expect(schema.validate(ok), isTrue);

      final badInner = {
        'posts': [
          const _BlogPost(
            title: 'Hi',
            body: 'short',
            tags: ['x'],
            authorRole: _Role.user,
          ),
        ],
      };
      final errors = schema.errors(badInner)!;
      expect(errors.first.path.first, 'posts');
    });
  });

  group('chaos: null/default/nullable interplay', () {
    test('preprocess returning null + defaultValue substitutes', () {
      final schema =
          V.string().preprocess((v) => null).defaultValue('fallback');
      expect(schema.parse('whatever'), 'fallback');
    });

    test('preprocess returning null + nullable yields null', () {
      final schema = V.string().preprocess((v) => null).nullable();
      expect(schema.parse('whatever'), isNull);
    });

    test('preprocess returning null without default nor nullable fails', () {
      final schema = V.string().preprocess((v) => null);
      expect(schema.validate('whatever'), isFalse);
    });
  });

  group('chaos: transform order and semantics', () {
    test('preprocess -> validation -> transform -> refine (via _runPipeline)',
        () {
      final log = <String>[];
      final schema = V
          .string()
          .preprocess((v) {
            log.add('pre');

            return v;
          })
          .min(3)
          .transform<int>((s) {
            log.add('transform');

            return s.length;
          })
          .refine((n) {
            log.add('refine');

            return n > 0;
          });

      schema.parse('hello');
      expect(log, ['pre', 'transform', 'refine']);
    });

    test('two chained transforms compose', () {
      final schema = V
          .string()
          .transform<int>((s) => s.length)
          .transform<String>((n) => 'len=$n');

      expect(schema.parse('hello'), 'len=5');
    });
  });

  group('design: pipeline short-circuit', () {
    // Entity-level steps added via `.add()` / `.refine()` / `.refineField()` /
    // `.equalFields()` live in `_runPipeline`, which only executes if every
    // field-level validation already passed. The tests below pin that
    // behavior so it does not change silently.

    test('when-rule error suppresses equalFields on the same parse', () {
      final schema = V.map({
        'type': V.string(),
        'a': V.string(),
        'b': V.string(),
      }).when('type', equals: 'strict', then: {
        'a': V.string().min(5),
      }).equalFields('a', 'b');

      final errors = schema.errors({
        'type': 'strict',
        'a': 'ab',
        'b': 'different',
      });

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.too_small'},
        reason: 'equalFields currently short-circuits behind field errors',
      );
    });

    test('equalFields fires once every field-level validation passes', () {
      final schema = V.map({
        'a': V.string(),
        'b': V.string(),
      }).equalFields('a', 'b');

      final errors = schema.errors({'a': 'x', 'b': 'y'});
      expect(errors!.first.code, 'map.fields_not_equal');
    });

    test('VObject refine also short-circuits on field error', () {
      final schema = V
          .object<_SignUpDto>()
          .field('email', (d) => d.email, V.string().email())
          .field('age', (d) => d.age, V.int())
          .refine((d) => d.age >= 0, code: 'non_negative_age');

      final errors = schema.errors(const _SignUpDto(
        email: 'bad',
        password: 'x',
        confirm: 'x',
        age: -1,
      ));

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.email'},
        reason: 'refine is held back until field validation passes',
      );
    });
  });

  group('chaos: VObject pick/omit/merge + when + refine in one chain', () {
    test('fields dropped by omit still feed the existing equalFields rule', () {
      final schema = V
          .object<_SignUpDto>()
          .field('email', (d) => d.email, V.string().email())
          .field('password', (d) => d.password, V.string())
          .field('confirm', (d) => d.confirm, V.string())
          .field('age', (d) => d.age, V.int())
          .equalFields('password', 'confirm')
          .omit(['confirm']).refine((d) => d.age >= 13);

      expect(
        schema.validate(const _SignUpDto(
          email: 'a@b.com',
          password: 'x',
          confirm: 'x',
          age: 18,
        )),
        isTrue,
      );
      expect(
        schema.validate(const _SignUpDto(
          email: 'a@b.com',
          password: 'x',
          confirm: 'mismatch',
          age: 18,
        )),
        isFalse,
      );
    });

    test('merged schema combines pick result with external audit fields', () {
      final base = V
          .object<_SignUpDto>()
          .field('email', (d) => d.email, V.string().email())
          .field('password', (d) => d.password, V.string().min(1));
      final audit =
          V.object<_SignUpDto>().field('age', (d) => d.age, V.int().min(0));

      final merged = base.merge(audit);

      expect(
        merged.schema.keys.toList(),
        ['email', 'password', 'age'],
      );
      expect(
        merged.validate(const _SignUpDto(
          email: 'a@b.com',
          password: 'x',
          confirm: 'x',
          age: 20,
        )),
        isTrue,
      );
    });
  });

  group('chaos: async + preprocess + refine + transform', () {
    test('full async pipeline with every feature produces expected output',
        () async {
      final log = <String>[];
      final schema = V
          .string()
          .preprocess((v) {
            log.add('sync-pre');

            return v;
          })
          .preprocessAsync((v) async {
            log.add('async-pre');

            return v;
          })
          .min(3)
          .refineAsync((v) async {
            log.add('async-refine');

            return v.length >= 3;
          })
          .transform<int>((s) {
            log.add('transform');

            return s.length;
          });

      final result = await schema.parseAsync('hello');
      expect(result, 5);
      expect(
        log,
        ['sync-pre', 'async-pre', 'async-refine', 'transform'],
      );
    });
  });

  group('chaos: VUnion with preprocess that coerces', () {
    test('preprocess tries numeric cast before union matches int option', () {
      final schema = V.union([V.int(), V.string().email()]).preprocess(
        (v) => v is String ? (int.tryParse(v) ?? v) : v,
      );

      expect(schema.validate('42'), isTrue);
      expect(schema.validate('a@b.com'), isTrue);
      expect(schema.validate('oops'), isFalse);
    });
  });

  group('chaos: VLiteral with preprocess normalization', () {
    test('trim + lowercase preprocess lets uppercase input match literal', () {
      final schema = V.literal('admin').preprocess(
            (v) => v is String ? v.trim().toLowerCase() : v,
          );

      expect(schema.validate('  ADMIN  '), isTrue);
      expect(schema.validate('USER'), isFalse);
    });
  });

  group('chaos: VArray + every element-level preprocess', () {
    test('outer preprocess + element validator + array-level unique', () {
      var outerRan = 0;
      final schema = V.string().min(1).array().preprocess((v) {
        outerRan++;

        return v;
      }).unique();

      expect(schema.validate(['a', 'b', 'c']), isTrue);
      expect(outerRan, 1);
      expect(schema.validate(['a', 'a']), isFalse);
    });
  });
}

/// Small helper to make `buildSchema`'s declared return type compile even
/// though the test above uses a local schema instead (kept to demonstrate
/// the intended shape without pulling in a global entity class).
extension _MapObjectCast on VMap {
  VObject<Map<String, String>> cast() =>
      V.object<Map<String, String>>().field('_dummy', (_) => '', V.string());
}
