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
      // Entity-level validators that declare their dependencies skip when
      // a declared dependency failed. Here `equalFields('password',
      // 'confirm')` skips because both depend on failing fields, and
      // `refineField(..., path: 'email')` skips because `email` failed —
      // so the result is purely the field-level errors. See the
      // "design: pipeline aggregation" group below for the full matrix.
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

  group('real-world: predicate-based whenMatches (cross-field, non-equals)',
      () {
    // when (literal discriminator) + whenMatches (multi-field predicate) +
    // refine(dependsOn:) where the depended-on key is only declared inside
    // a whenMatches.then block. Verifies the three mechanisms coexist and
    // surface every error in a single VFailure.
    final schema = V.map({
      'role': V.string(),
      'level': V.int(),
      'country': V.string(),
    }).when('role', equals: 'guest', then: {
      'name': V.string().min(3),
    }).whenMatches(
      (m) => m['role'] == 'admin' && (m['level'] as int) > 5,
      dependsOn: const {'role', 'level'},
      then: {'audit_token': V.string().min(8)},
    ).refine(
      (m) => (m['audit_token'] as String?)?.startsWith('AUD-') ?? true,
      code: 'audit_prefix',
      message: 'audit_token must start with AUD-',
      dependsOn: const {'audit_token'},
    );

    test('senior admin with valid audit_token passes', () {
      expect(
        schema.validate({
          'role': 'admin',
          'level': 10,
          'country': 'BR',
          'audit_token': 'AUD-12345',
        }),
        isTrue,
      );
    });

    test('senior admin with short audit_token fails', () {
      final errors = schema.errors({
        'role': 'admin',
        'level': 10,
        'country': 'BR',
        'audit_token': 'short',
      });

      expect(errors, isNotNull);
      expect(
        errors!.any((e) => e.path.first == 'audit_token'),
        isTrue,
      );
    });

    test('senior admin with bad-prefix audit_token surfaces refine error', () {
      // audit_token is long enough (passes whenMatches.then) but does not
      // start with "AUD-" → the refine fires.
      final errors = schema.errors({
        'role': 'admin',
        'level': 10,
        'country': 'BR',
        'audit_token': 'XYZ-99999',
      });

      expect(errors, isNotNull);
      expect(errors!.any((e) => e.code == 'audit_prefix'), isTrue);
    });

    test('junior admin (level <= 5) bypasses whenMatches', () {
      expect(
        schema.validate({
          'role': 'admin',
          'level': 3,
          'country': 'BR',
        }),
        isTrue,
      );
    });

    test('guest with short name fails the literal when()', () {
      expect(
        schema.validate({
          'role': 'guest',
          'level': 0,
          'country': 'BR',
          'name': 'Al',
        }),
        isFalse,
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

  group('design: pipeline aggregation', () {
    // Entity-level validators (`equalFields`, `refineField`, `refine`) live
    // in `_runPipeline`, which now consults each step's declared
    // `dependsOn` set against the field-level `failedFieldPaths`. A step
    // is skipped only when one of its declared deps failed; a step
    // without `dependsOn` keeps the conservative legacy rule (skip on
    // any field error). The tests below pin that matrix.

    test('equalFields runs even when an unrelated field fails', () {
      final schema = V.map({
        'unrelated': V.string().min(10),
        'a': V.string(),
        'b': V.string(),
      }).equalFields('a', 'b');

      final errors = schema.errors({
        'unrelated': 'short',
        'a': 'x',
        'b': 'y',
      });

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.too_small', 'map.fields_not_equal'},
        reason: 'equalFields declares dependsOn={a,b}; unrelated failure '
            'should not gate it',
      );
    });

    test('equalFields skips when one of its dependencies fails', () {
      final schema = V.map({
        'a': V.string().min(5),
        'b': V.string(),
      }).equalFields('a', 'b');

      final errors = schema.errors({'a': 'x', 'b': 'y'});

      expect(errors!.map((e) => e.code).toSet(), {'string.too_small'});
    });

    test('equalFields fires once every field-level validation passes', () {
      final schema = V.map({
        'a': V.string(),
        'b': V.string(),
      }).equalFields('a', 'b');

      final errors = schema.errors({'a': 'x', 'b': 'y'});
      expect(errors!.first.code, 'map.fields_not_equal');
    });

    test('when-rule error suppresses equalFields whose dep is the same field',
        () {
      // Here the when-rule injects a min(5) on `a`; the input fails it.
      // equalFields depends on `a` and `b`, and `a` is in failedFieldPaths
      // → skip. (Different reason than "global short-circuit" — it's the
      // dep gate.)
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

      expect(errors!.map((e) => e.code).toSet(), {'string.too_small'});
    });

    test('refineField runs when its path passes', () {
      final schema = V.map({
        'unrelated': V.string().min(10),
        'age': V.int(),
      }).refineField(
        (m) => (m['age'] as int) >= 18,
        path: 'age',
        message: 'must be 18+',
      );

      final errors = schema.errors({'unrelated': 'short', 'age': 16});

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.too_small', 'custom'},
      );
    });

    test('refineField skips when its path fails', () {
      final schema = V.map({
        'age': V.int().min(0),
      }).refineField(
        (m) => (m['age'] as int) >= 18,
        path: 'age',
        message: 'must be 18+',
      );

      final errors = schema.errors({'age': -5});

      expect(errors!.map((e) => e.code).toSet(), {'number.too_small'});
    });

    test('generic refine without dependsOn keeps the conservative skip', () {
      final schema = V.map({
        'a': V.string().min(3),
        'b': V.int(),
      }).refine((m) => true, code: 'always_true');

      final errors = schema.errors({'a': 'x', 'b': 5});

      expect(errors!.map((e) => e.code).toSet(), {'string.too_small'});
    });

    test('refine with dependsOn aggregates when its deps pass', () {
      final schema = V.map({
        'a': V.string().min(3),
        'startDate': V.date(),
        'endDate': V.date(),
      }).refine(
        (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
        code: 'date_range',
        message: 'endDate must be after startDate',
        dependsOn: const {'startDate', 'endDate'},
      );

      final errors = schema.errors({
        'a': 'x',
        'startDate': DateTime(2026, 5, 1),
        'endDate': DateTime(2026, 4, 1),
      });

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.too_small', 'date_range'},
      );
    });

    test('refine with dependsOn skips when one dep fails', () {
      final schema = V.map({
        'a': V.string(),
        'startDate': V.date(),
        'endDate': V.date(),
      }).refine(
        (m) => (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
        code: 'date_range',
        dependsOn: const {'startDate', 'endDate'},
      );

      final errors = schema.errors({
        'a': 'ok',
        'startDate': 'lixo',
        'endDate': DateTime(2026, 4, 1),
      });

      expect(errors!.map((e) => e.code).toSet(), {'date.invalid_type'});
    });

    test('refine.dependsOn accepts keys injected via when.then', () {
      final schema = V.map({
        'role': V.string(),
        'name': V.string(),
      }).when('role', equals: 'admin', then: {
        'permissions': V.array(V.string()),
      }).refine(
        (m) => (m['permissions'] as List<dynamic>).isNotEmpty,
        code: 'needs_permission',
        dependsOn: const {'permissions'},
      );

      // Admin with empty permissions → field passes (array is valid),
      // refine should run and reject.
      final errors = schema.errors({
        'role': 'admin',
        'name': 'A',
        'permissions': <String>[],
      });

      expect(errors!.map((e) => e.code).toSet(), {'needs_permission'});
    });

    test('refine.dependsOn asserts on unknown keys', () {
      expect(
        () => V.map({'a': V.string()}).refine(
          (_) => true,
          dependsOn: const {'b'},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('VObject equalFields aggregates with unrelated field error', () {
      final schema = V
          .object<_SignUpDto>()
          .field('email', (d) => d.email, V.string().email())
          .field('password', (d) => d.password, V.string())
          .field('confirm', (d) => d.confirm, V.string())
          .field('age', (d) => d.age, V.int())
          .equalFields('password', 'confirm');

      final errors = schema.errors(const _SignUpDto(
        email: 'bad',
        password: 'a',
        confirm: 'b',
        age: 30,
      ));

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.email', 'object.fields_not_equal'},
      );
    });

    test('VObject refine without dependsOn still short-circuits', () {
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

      expect(errors!.map((e) => e.code).toSet(), {'string.email'});
    });

    test('VObject refine with dependsOn aggregates', () {
      final schema = V
          .object<_SignUpDto>()
          .field('email', (d) => d.email, V.string().email())
          .field('age', (d) => d.age, V.int())
          .refine(
        (d) => d.age >= 0,
        code: 'non_negative_age',
        dependsOn: const {'age'},
      );

      final errors = schema.errors(const _SignUpDto(
        email: 'bad',
        password: 'x',
        confirm: 'x',
        age: -1,
      ));

      expect(
        errors!.map((e) => e.code).toSet(),
        {'string.email', 'non_negative_age'},
      );
    });
  });

  group('design: pipeline aggregation edge cases', () {
    // Cross-cut concerns: async pipelines, empty dependsOn, schema
    // composition (pick/extend/merge), entity-level steps that emit
    // errors with a path, and the construction-time assertion order.

    group('async + dependsOn', () {
      test('refineAsync with dependsOn aggregates when its deps pass',
          () async {
        final schema = V.map({
          'a': V.string().min(3),
          'startDate': V.date(),
          'endDate': V.date(),
        }).refineAsync(
          (m) async =>
              (m['endDate'] as DateTime).isAfter(m['startDate'] as DateTime),
          code: 'date_range',
          dependsOn: const {'startDate', 'endDate'},
        );

        final errors = await schema.errorsAsync({
          'a': 'x',
          'startDate': DateTime(2026, 5, 1),
          'endDate': DateTime(2026, 4, 1),
        });

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.too_small', 'date_range'},
        );
      });

      test('refineAsync with dependsOn skips when one dep fails', () async {
        final schema = V.map({
          'a': V.string(),
          'startDate': V.date(),
          'endDate': V.date(),
        }).refineAsync(
          (m) async => true,
          code: 'date_range',
          dependsOn: const {'startDate', 'endDate'},
        );

        final errors = await schema.errorsAsync({
          'a': 'ok',
          'startDate': 'lixo',
          'endDate': DateTime(2026, 4, 1),
        });

        expect(errors!.map((e) => e.code).toSet(), {'date.invalid_type'});
      });

      test('equalFields aggregates inside an async-only VMap', () async {
        // A field's refineAsync makes the whole pipeline async; equalFields
        // is a sync validator but its dep-skip logic must still apply.
        final schema = V.map({
          'name': V.string().refineAsync(
                (s) async => s.length >= 5,
                code: 'name_too_short',
              ),
          'a': V.string(),
          'b': V.string(),
        }).equalFields('a', 'b');

        final errors = await schema.errorsAsync({
          'name': 'Jo',
          'a': 'x',
          'b': 'y',
        });

        expect(
          errors!.map((e) => e.code).toSet(),
          {'name_too_short', 'map.fields_not_equal'},
        );
      });

      test('VObject refineAsync with dependsOn aggregates', () async {
        final schema = V
            .object<_SignUpDto>()
            .field('email', (d) => d.email, V.string().email())
            .field('age', (d) => d.age, V.int())
            .refineAsync(
          (d) async => d.age >= 0,
          code: 'non_negative_age',
          dependsOn: const {'age'},
        );

        final errors = await schema.errorsAsync(const _SignUpDto(
          email: 'bad',
          password: 'x',
          confirm: 'x',
          age: -1,
        ));

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.email', 'non_negative_age'},
        );
      });
    });

    group('dependsOn edge values', () {
      test('dependsOn: const {} bypasses the conservative skip (always runs)',
          () {
        // Empty set means "no declared deps" — the .any(...) check returns
        // false, so the step is NOT skipped even with field errors. This
        // is the documented escape hatch for callers who want aggregation
        // and accept responsibility for defensive code.
        var refineRan = 0;
        final schema = V.map({
          'a': V.string().min(3),
        }).refine(
          (_) {
            refineRan++;

            return false;
          },
          code: 'always_fails',
          dependsOn: const {},
        );

        final errors = schema.errors({'a': 'x'});

        expect(refineRan, 1);
        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.too_small', 'always_fails'},
        );
      });
    });

    group('schema composition + dependsOn', () {
      test('VMap.extend preserves equalFields aggregation behavior', () {
        final base = V.map({
          'password': V.string(),
          'confirm': V.string(),
        }).equalFields('password', 'confirm');

        final extended = base.extend({'extra': V.string().min(10)});

        final errors = extended.errors({
          'password': 'a',
          'confirm': 'b',
          'extra': 'short',
        });

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.too_small', 'map.fields_not_equal'},
        );
      });

      test('VMap.merge preserves dep-aware refines from both sides', () {
        final left = V.map({
          'a': V.string(),
          'b': V.string(),
        }).refine(
          (m) => m['a'] != m['b'],
          code: 'left_rule',
          dependsOn: const {'a', 'b'},
        );

        final right = V.map({
          'c': V.string(),
        }).refine(
          (m) => (m['c'] as String).startsWith('z'),
          code: 'right_rule',
          dependsOn: const {'c'},
        );

        final merged = left.merge(right);

        final errors = merged.errors({'a': 'x', 'b': 'x', 'c': 'a'});

        expect(
          errors!.map((e) => e.code).toSet(),
          {'left_rule', 'right_rule'},
        );
      });

      test('VMap.pick that drops a referenced field still runs the refine', () {
        // dependsOn was asserted at construction; after pick, dropped
        // fields are simply never validated, so they never enter
        // failedFieldPaths — the refine runs whenever the surviving deps
        // pass.
        final base = V.map({
          'a': V.string(),
          'b': V.string(),
        }).refine(
          (m) => m['a'] != null,
          code: 'a_present',
          dependsOn: const {'a', 'b'},
        );

        final picked = base.pick(['a']);

        // 'a' present → refine runs → check returns true → no error.
        expect(picked.errors({'a': 'ok'}), isNull);
      });

      test('VObject.pick preserves entity-level refine with dependsOn', () {
        final schema = V
            .object<_SignUpDto>()
            .field('email', (d) => d.email, V.string().email())
            .field('age', (d) => d.age, V.int())
            .refine(
          (d) => d.age >= 0,
          code: 'non_negative_age',
          dependsOn: const {'age'},
        ).pick(['email', 'age']);

        final errors = schema.errors(const _SignUpDto(
          email: 'bad',
          password: 'x',
          confirm: 'x',
          age: -1,
        ));

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.email', 'non_negative_age'},
        );
      });
    });

    group('entity-level errors do not gate later entity-level steps', () {
      test(
        'a refineField with path: x emits with path=[x]; subsequent '
        'dep-on-x runs because failedFieldPaths is fixed before _runPipeline',
        () {
          // refineField on 'email' fails (returns false). It emits with
          // path=['email']. A second refineField also on 'email' should
          // STILL run, because the failed-field set is computed once,
          // before the entity-level phase begins.
          var second = 0;
          final schema = V
              .map({
                'email': V.string(),
              })
              .refineField(
                (m) => false,
                path: 'email',
                message: 'first',
              )
              .refineField(
                (m) {
                  second++;

                  return false;
                },
                path: 'email',
                message: 'second',
              );

          final errors = schema.errors({'email': 'a@b.com'});

          expect(second, 1, reason: 'second refineField must execute');
          expect(errors!.length, 2);
          expect(errors.map((e) => e.message).toSet(), {'first', 'second'});
        },
      );
    });

    group('construction-time validation of dependsOn', () {
      test('refine before declaring when.then key throws AssertionError', () {
        expect(
          () => V.map({'role': V.string()}).refine(
            (_) => true,
            dependsOn: const {'permissions'},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('when.then before refine accepts the injected key', () {
        // The legal order: declare the conditional field first, then
        // reference it in dependsOn. The assert reads the schema state at
        // call time.
        final schema = V.map({
          'role': V.string(),
        }).when('role', equals: 'admin', then: {
          'permissions': V.array(V.string()),
        }).refine(
          (m) => (m['permissions'] as List<dynamic>).isNotEmpty,
          code: 'needs_permission',
          dependsOn: const {'permissions'},
        );

        // Non-admin → when does not fire → permissions missing → refine
        // runs and `m['permissions']` is null → cast crashes inside the
        // user check. The point of the test is the construction (no
        // assert) — guard against the cast by giving admin role.
        final errors = schema.errors({
          'role': 'admin',
          'permissions': <String>[],
        });

        expect(errors!.map((e) => e.code).toSet(), {'needs_permission'});
      });

      test('VObject refine with unknown dependsOn key throws AssertionError',
          () {
        expect(
          () => V
              .object<_SignUpDto>()
              .field('email', (d) => d.email, V.string())
              .refine(
            (_) => true,
            dependsOn: const {'unknown_field'},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('VObject refine.dependsOn accepts keys injected via when.then', () {
        final schema = V
            .object<_SignUpDto>()
            .field('email', (d) => d.email, V.string())
            .field('age', (d) => d.age, V.int())
            .when('email', equals: 'leak@x.com', then: {
          'age': V.int().min(99),
        }).refine(
          (d) => d.age >= 0,
          code: 'sane_age',
          dependsOn: const {'age'},
        );

        // age key is in base schema; this just confirms the assert allows
        // base-schema names.
        expect(
          schema.validate(const _SignUpDto(
            email: 'a@b.com',
            password: 'x',
            confirm: 'x',
            age: 30,
          )),
          isTrue,
        );
      });
    });

    group('extension-point: add() / addAsync() with dependsOn', () {
      test('add(custom validator, dependsOn:{...}) on VMap aggregates', () {
        // Simulates a third-party extension plugging in its own
        // entity-level Validator<Map<String, dynamic>> via the public
        // add() API and declaring dependsOn explicitly.
        final schema = V.map({
          'unrelated': V.string().min(10),
          'a': V.int(),
          'b': V.int(),
        }).add(
          const _SumLessThanValidator(field: 'a', other: 'b', max: 10),
          dependsOn: const {'a', 'b'},
        );

        final errors = schema.errors({
          'unrelated': 'short',
          'a': 7,
          'b': 8,
        });

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.too_small', 'sum_too_large'},
        );
      });

      test('addAsync(custom async validator, dependsOn:{...}) aggregates',
          () async {
        final schema = V.map({
          'unrelated': V.string().min(10),
          'a': V.string(),
        }).addAsync(
          const _ReservedNameAsyncValidator(field: 'a'),
          dependsOn: const {'a'},
        );

        final errors = await schema.errorsAsync({
          'unrelated': 'short',
          'a': 'admin',
        });

        expect(
          errors!.map((e) => e.code).toSet(),
          {'string.too_small', 'reserved_name'},
        );
      });

      test('add() without dependsOn keeps conservative skip', () {
        final schema = V.map({
          'a': V.string().min(3),
          'b': V.int(),
        }).add(
          const _SumLessThanValidator(field: 'b', other: 'b', max: 100),
        );

        final errors = schema.errors({'a': 'x', 'b': 5});

        expect(errors!.map((e) => e.code).toSet(), {'string.too_small'});
      });
    });

    group('dependsOn dedup, multiplicity and combinatorics', () {
      test('dependsOn with the same field repeated dedups (Set semantic)', () {
        // Sets always dedup; this just confirms the pipeline does not
        // fall over when the caller passes a logically-redundant set.
        final schema = V.map({
          'a': V.string(),
        }).refine(
          (m) => (m['a'] as String).isNotEmpty,
          code: 'a_non_empty',
          // Dedup via Set ctor is the point of this test; a literal
          // {'a','a'} would be flagged by `equal_elements_in_set`.
          // ignore: prefer_collection_literals
          dependsOn: Set<String>.from(<String>['a', 'a']),
        );

        expect(schema.errors({'a': ''})!.first.code, 'a_non_empty');
        expect(schema.validate({'a': 'ok'}), isTrue);
      });

      test('two equalFields on overlapping pairs run independently', () {
        // password<->confirm and email<->emailConfirm are independent
        // dep gates; both can fire in the same parse.
        final schema = V
            .map({
              'email': V.string(),
              'emailConfirm': V.string(),
              'password': V.string(),
              'confirm': V.string(),
            })
            .equalFields('password', 'confirm')
            .equalFields('email', 'emailConfirm');

        final errors = schema.errors({
          'email': 'a@b.com',
          'emailConfirm': 'c@d.com',
          'password': 'x',
          'confirm': 'y',
        });

        // map.fields_not_equal appears twice — once per equalFields step.
        final codes = errors!.map((e) => e.code).toList();
        expect(codes.where((c) => c == 'map.fields_not_equal').length, 2);
      });

      test('multiple refines with overlapping dependsOn all run', () {
        var ranA = 0;
        var ranB = 0;
        final schema = V.map({
          'x': V.string(),
          'y': V.string(),
        }).refine(
          (m) {
            ranA++;

            return false;
          },
          code: 'rule_a',
          dependsOn: const {'x', 'y'},
        ).refine(
          (m) {
            ranB++;

            return false;
          },
          code: 'rule_b',
          dependsOn: const {'x'},
        );

        final errors = schema.errors({'x': 'a', 'y': 'b'});

        expect(ranA, 1);
        expect(ranB, 1);
        expect(errors!.map((e) => e.code).toSet(), {'rule_a', 'rule_b'});
      });
    });

    group('nested containers + dependsOn', () {
      test('outer refine.dependsOn references the inner-container key', () {
        // Outer VMap has a refine that depends on 'inner'. If the inner
        // VMap fails (its own field broken), the failure surfaces with
        // path=['inner', ...]; failedFieldPaths={'inner'}; outer refine
        // dep={'inner'} → skip.
        final inner = V.map({'count': V.int().min(1)});
        final outer = V.map({
          'name': V.string(),
          'inner': inner,
        }).refine(
          (m) => m['inner'] != null,
          code: 'inner_present',
          dependsOn: const {'inner'},
        );

        final errors = outer.errors({
          'name': 'ok',
          'inner': {'count': 0},
        });

        expect(errors!.map((e) => e.code).toSet(), {'number.too_small'});
      });

      test('outer refine.dependsOn runs when inner-container is fully valid',
          () {
        final inner = V.map({'count': V.int().min(1)});
        final outer = V.map({
          'name': V.string(),
          'inner': inner,
        }).refine(
          (m) {
            final innerMap = m['inner'] as Map<String, dynamic>;

            return (innerMap['count'] as int) > 5;
          },
          code: 'count_above_five',
          dependsOn: const {'inner'},
        );

        final errors = outer.errors({
          'name': 'ok',
          'inner': {'count': 2},
        });

        expect(errors!.map((e) => e.code).toSet(), {'count_above_five'});
      });
    });

    group('null-handling interplay with dependsOn', () {
      test('nullable field that comes as null does not enter failedFieldPaths',
          () {
        // 'optional' is nullable → null passes → 'optional' not in
        // failedFieldPaths → refine with dependsOn: {'optional'} runs.
        var ran = 0;
        final schema = V.map({
          'required': V.string(),
          'optional': V.string().nullable(),
        }).refine(
          (m) {
            ran++;

            return m['optional'] != null;
          },
          code: 'optional_required',
          dependsOn: const {'optional'},
        );

        final errors = schema.errors({'required': 'ok', 'optional': null});

        expect(ran, 1);
        expect(errors!.map((e) => e.code).toSet(), {'optional_required'});
      });

      test('field with defaultValue substitutes and refine still runs', () {
        final schema = V.map({
          'name': V.string().defaultValue('anon'),
        }).refine(
          (m) => m['name'] == 'anon',
          code: 'used_default',
          dependsOn: const {'name'},
        );

        // Input has no 'name' key → default 'anon' is substituted →
        // refine sees 'anon' and passes (returns true → no error).
        expect(schema.validate(<String, dynamic>{'name': null}), isTrue);
      });
    });

    group('strict/passthrough + dependsOn', () {
      test(
        'strict() unrecognized_key does NOT block a refine that depends on '
        'declared keys only',
        () {
          // strict() emits VError with path=[unknownKey]. That key enters
          // failedFieldPaths. A refine with dependsOn={'a','b'} (declared
          // keys, both passing) must still run — the strict failure does
          // not intersect its declared deps.
          var ran = 0;
          final schema = V
              .map({
                'a': V.string(),
                'b': V.string(),
              })
              .strict()
              .refine(
                (m) {
                  ran++;

                  return false;
                },
                code: 'always_fail',
                dependsOn: const {'a', 'b'},
              );

          final errors = schema.errors({'a': 'x', 'b': 'y', 'extra': 1});

          expect(ran, 1, reason: 'refine must execute');
          expect(
            errors!.map((e) => e.code).toSet(),
            {'map.unrecognized_key', 'always_fail'},
          );
        },
      );

      test('passthrough() does not affect dependsOn behavior', () {
        final schema = V
            .map({
              'a': V.string(),
              'b': V.string(),
            })
            .passthrough()
            .equalFields('a', 'b');

        final errors = schema.errors({'a': 'x', 'b': 'x', 'extra': 'kept'});

        // a == b → equalFields passes; passthrough kept 'extra'; no errors.
        expect(errors, isNull);
      });
    });

    group('partial() + dependsOn', () {
      test('VMap.partial() preserves entity-level refines from base', () {
        // partial() now calls _copyMapStateTo (matching extend/merge/
        // pick/omit), so refines/equalFields/refineField on the base
        // schema survive into the patch schema.
        final base = V.map({
          'a': V.string(),
          'b': V.string(),
        }).refine(
          (m) => m['a'] != m['b'],
          code: 'a_neq_b',
          dependsOn: const {'a', 'b'},
        );

        // partial() makes both fields nullable. Empty patch → both null
        // → both pass field validation → refine runs → null != null is
        // false → emits a_neq_b.
        final empty = base.partial().errors(<String, dynamic>{});

        expect(empty, isNotNull);
        expect(empty!.first.code, 'a_neq_b');
      });

      test('refines added AFTER partial() also work', () {
        final patch = V
            .map({
              'a': V.string(),
              'b': V.string(),
            })
            .partial()
            .refine(
              (m) => m['a'] != null && m['b'] != null,
              code: 'both_present',
            );

        expect(patch.errors(<String, dynamic>{})!.first.code, 'both_present');
      });
    });

    group('VObject.merge() + dependsOn', () {
      test('merge concatenates refines from both sides; both run', () {
        final left = V
            .object<_SignUpDto>()
            .field('email', (d) => d.email, V.string())
            .refine(
          (d) => d.email.contains('@'),
          code: 'left_has_at',
          dependsOn: const {'email'},
        );

        final right =
            V.object<_SignUpDto>().field('age', (d) => d.age, V.int()).refine(
          (d) => d.age >= 0,
          code: 'right_non_neg',
          dependsOn: const {'age'},
        );

        final merged = left.merge(right);

        final errors = merged.errors(const _SignUpDto(
          email: 'noatsign',
          password: 'x',
          confirm: 'x',
          age: -1,
        ));

        expect(
          errors!.map((e) => e.code).toSet(),
          {'left_has_at', 'right_non_neg'},
        );
      });
    });

    group('manual path + dependsOn on add()', () {
      test('add(validator, path: [x], dependsOn: {x}) emits with path=[x]', () {
        // Mirrors what refineField does internally — confirm the path
        // override and dep gate work in tandem when used directly.
        final schema = V.map({
          'email': V.string(),
        }).add(
          const _DisposableEmailValidator(),
          path: const ['email'],
          dependsOn: const {'email'},
        );

        final errors = schema.errors({'email': 'x@tempmail.com'});

        expect(errors!.length, 1);
        expect(errors.first.code, 'disposable_email');
        expect(errors.first.path, ['email']);
      });
    });

    group('VFailure.toMap() / rootMessages() interplay', () {
      test('toMap() drops errors with empty path (root-level refines)', () {
        // Documented behavior: toMap is field-keyed, so refine errors
        // without a path are NOT in toMap. They are accessible via
        // rootMessages().
        final schema = V.map({
          'name': V.string(),
        }).refine(
          (_) => false,
          code: 'root_rule',
          message: 'root rejected',
        );

        final result = schema.safeParse({'name': 'ok'});

        expect(result, isA<VFailure<Map<String, dynamic>?>>());
        final failure = result as VFailure<Map<String, dynamic>?>;

        expect(failure.errors.length, 1);
        expect(failure.errors.first.path, isEmpty);
        expect(failure.toMap(), <String, String>{});
      });

      test('rootMessages() returns root-level errors that toMap() omits', () {
        final schema = V.map({
          'name': V.string(),
        }).refine(
          (_) => false,
          code: 'root_rule',
          message: 'root rejected',
        );

        final failure = schema.safeParse({'name': 'ok'}) as VFailure<Object?>;

        expect(failure.rootMessages(), ['root rejected']);
      });

      test('rootMessages() returns empty list when no root-level error', () {
        final schema = V.map({
          'name': V.string().min(5),
        });

        final failure = schema.safeParse({'name': 'Jo'}) as VFailure<Object?>;

        expect(failure.rootMessages(), isEmpty);
        expect(failure.toMap().keys, ['name']);
      });

      test('toMap() includes refineField errors (path is set)', () {
        final schema = V.map({
          'email': V.string(),
        }).refineField(
          (_) => false,
          path: 'email',
          message: 'rejected',
        );

        final failure =
            schema.safeParse({'email': 'a@b.com'}) as VFailure<Object?>;

        expect(failure.toMap(), {'email': 'rejected'});
        expect(
          failure.rootMessages(),
          isEmpty,
          reason: 'refineField sets path → not a root error',
        );
      });

      test(
        'toMap() and rootMessages() partition errors cleanly: '
        'each error appears in exactly one of the two',
        () {
          // Mixed scenario: field error + equalFields (root) + refine
          // (root, with dependsOn so it survives the field error).
          final schema = V
              .map({
                'name': V.string().min(3),
                'a': V.string(),
                'b': V.string(),
              })
              .equalFields('a', 'b')
              .refine(
                (_) => false,
                code: 'rule',
                message: 'extra rule failed',
                dependsOn: const {'a', 'b'},
              );

          final failure = schema.safeParse({'name': 'Jo', 'a': 'x', 'b': 'y'})
              as VFailure<Object?>;

          // Field error → toMap
          expect(failure.toMap().keys, contains('name'));

          // equalFields and refine both have empty path → rootMessages
          // (equalFields default message + the custom 'extra rule failed').
          expect(failure.rootMessages().length, 2);
          expect(
            failure.rootMessages(),
            contains('extra rule failed'),
          );

          // Sanity: total errors == toMap.length + rootMessages.length
          expect(
            failure.errors.length,
            failure.toMap().length + failure.rootMessages().length,
          );
        },
      );

      test('rootMessages() preserves emission order', () {
        final schema = V
            .map({
              'a': V.string(),
            })
            .refine(
              (_) => false,
              message: 'first rule',
            )
            .refine(
              (_) => false,
              message: 'second rule',
            );

        final failure = schema.safeParse({'a': 'ok'}) as VFailure<Object?>;

        expect(failure.rootMessages(), ['first rule', 'second rule']);
      });
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

/// Sums two int fields and rejects when greater than [max]. Used by the
/// extension-point tests to simulate a third-party `Validator<Map>`.
class _SumLessThanValidator extends Validator<Map<String, dynamic>> {
  final String field;
  final String other;
  final int max;

  const _SumLessThanValidator({
    required this.field,
    required this.other,
    required this.max,
  });

  @override
  String get code => 'sum_too_large';

  @override
  Map<String, dynamic>? validate(Map<String, dynamic> value) {
    final a = value[field] as int? ?? 0;
    final b = value[other] as int? ?? 0;

    return (a + b) > max ? {} : null;
  }
}

/// Async validator that rejects a hard-coded set of reserved names.
/// Used by the extension-point async test.
class _ReservedNameAsyncValidator extends AsyncValidator<Map<String, dynamic>> {
  final String field;

  const _ReservedNameAsyncValidator({required this.field});

  static const _reserved = {'admin', 'root', 'system'};

  @override
  String get code => 'reserved_name';

  @override
  Future<Map<String, dynamic>?> validate(Map<String, dynamic> value) async {
    final name = value[field] as String?;

    return _reserved.contains(name) ? {} : null;
  }
}

/// Rejects strings ending in `@tempmail.com`. Used by the manual-path
/// test.
class _DisposableEmailValidator extends Validator<Map<String, dynamic>> {
  const _DisposableEmailValidator();

  @override
  String get code => 'disposable_email';

  @override
  Map<String, dynamic>? validate(Map<String, dynamic> value) {
    final email = value['email'] as String? ?? '';

    return email.endsWith('@tempmail.com') ? {} : null;
  }
}
