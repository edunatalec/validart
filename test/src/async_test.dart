import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('refineAsync', () {
    test('validateAsync returns true when check passes', () async {
      final schema = V.string().refineAsync((v) async => v.length >= 3);
      expect(await schema.validateAsync('hello'), isTrue);
    });

    test('validateAsync returns false when check fails', () async {
      final schema = V.string().refineAsync((v) async => v.length >= 3);
      expect(await schema.validateAsync('hi'), isFalse);
    });

    test('errorsAsync returns custom message', () async {
      final schema = V.string().refineAsync(
            (v) async => v.contains('@'),
            message: 'Must contain @',
          );
      final errors = await schema.errorsAsync('nope');
      expect(errors!.first.message, 'Must contain @');
    });

    test('errorsAsync returns custom code', () async {
      final schema = V.string().refineAsync(
            (v) async => v.isNotEmpty,
            code: 'not_empty_async',
          );
      final errors = await schema.errorsAsync('');
      expect(errors!.first.code, 'not_empty_async');
    });

    test('parseAsync returns value when valid', () async {
      final schema = V.string().refineAsync((v) async => v.length >= 3);
      expect(await schema.parseAsync('hello'), 'hello');
    });

    test('parseAsync throws VException on failure', () async {
      final schema = V.string().refineAsync((v) async => v.length >= 3);
      expect(
        () => schema.parseAsync('ab'),
        throwsA(isA<VException>()),
      );
    });

    test('safeParseAsync returns VSuccess on valid', () async {
      final schema = V.string().refineAsync((v) async => true);
      final result = await schema.safeParseAsync('hello');
      expect(result, isA<VSuccess<String?>>());
    });

    test('safeParseAsync returns VFailure on invalid', () async {
      final schema = V.string().refineAsync((v) async => false);
      final result = await schema.safeParseAsync('hello');
      expect(result, isA<VFailure<String?>>());
    });
  });

  group('hasAsync detection', () {
    test('schema without async has hasAsync = false', () {
      final schema = V.string().email();
      expect(schema.hasAsync, isFalse);
    });

    test('schema with refineAsync has hasAsync = true', () {
      final schema = V.string().refineAsync((v) async => true);
      expect(schema.hasAsync, isTrue);
    });
  });

  group('sync consumers throw VAsyncRequiredException', () {
    test('validate throws', () {
      final schema = V.string().refineAsync((v) async => true);
      expect(
        () => schema.validate('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('safeParse throws', () {
      final schema = V.string().refineAsync((v) async => true);
      expect(
        () => schema.safeParse('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('parse throws', () {
      final schema = V.string().refineAsync((v) async => true);
      expect(
        () => schema.parse('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('errors throws', () {
      final schema = V.string().refineAsync((v) async => true);
      expect(
        () => schema.errors('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('exception includes suggested method name', () {
      final schema = V.string().refineAsync((v) async => true);
      try {
        schema.validate('x');
        fail('expected throw');
      } on VAsyncRequiredException catch (e) {
        expect(e.methodName, 'validate');
        expect(e.suggestion, 'validateAsync');
        expect(e.toString(), contains('validateAsync'));
      }
    });
  });

  group('sync-capable schemas still work sync', () {
    test('validate works when no async', () {
      final schema = V.string().refine((v) => v.length >= 3);
      expect(schema.validate('hello'), isTrue);
    });

    test('validateAsync also works on sync-only schema', () async {
      final schema = V.string().refine((v) => v.length >= 3);
      expect(await schema.validateAsync('hello'), isTrue);
    });
  });

  group('execution order', () {
    test('multiple refineAsync run in order', () async {
      final log = <String>[];
      final schema = V.string().refineAsync((v) async {
        log.add('first');
        return true;
      }).refineAsync((v) async {
        log.add('second');
        return true;
      });

      await schema.validateAsync('x');
      expect(log, ['first', 'second']);
    });

    test('sync and async refine collect all errors', () async {
      final schema = V
          .string()
          .refine((v) => v.length >= 10, code: 'too_short_sync')
          .refineAsync((v) async => v.startsWith('x'), code: 'not_x_async');

      final errors = await schema.errorsAsync('ab');
      expect(errors!.length, 2);
      expect(errors[0].code, 'too_short_sync');
      expect(errors[1].code, 'not_x_async');
    });
  });

  group('VMap with async field', () {
    test('propagates hasAsync from field', () {
      final schema = V.map({
        'email': V.string().refineAsync((v) async => v.contains('@')),
      });
      expect(schema.hasAsync, isTrue);
    });

    test('field path preserved in async errors', () async {
      final schema = V.map({
        'email': V.string().refineAsync(
              (v) async => v.contains('@'),
              code: 'invalid_email_async',
            ),
      });
      final errors = await schema.errorsAsync({'email': 'nope'});
      expect(errors!.first.code, 'invalid_email_async');
      expect(errors.first.path, ['email']);
    });

    test('async in when-rule propagates hasAsync', () {
      final schema = V.map({
        'type': V.string(),
        'extra': V.string().nullable(),
      }).when('type', equals: 'x', then: {
        'extra': V.string().refineAsync((v) async => v.length > 3),
      });
      expect(schema.hasAsync, isTrue);
    });
  });

  group('VArray with async element', () {
    test('propagates hasAsync', () {
      final schema = V.string().refineAsync((v) async => true).array();
      expect(schema.hasAsync, isTrue);
    });

    test('index path preserved in async errors', () async {
      final schema = V
          .string()
          .refineAsync((v) async => v == 'ok', code: 'not_ok')
          .array();

      final errors = await schema.errorsAsync(['ok', 'fail']);
      expect(errors!.first.code, 'not_ok');
      expect(errors.first.path, [1]);
    });
  });

  group('VObject with async field', () {
    test('propagates hasAsync', () {
      final schema = V.object<_User>().field(
            'name',
            (u) => u.name,
            V.string().refineAsync((v) async => v.isNotEmpty),
          );
      expect(schema.hasAsync, isTrue);
    });

    test('field path preserved in async errors', () async {
      final schema = V.object<_User>().field(
            'name',
            (u) => u.name,
            V.string().refineAsync(
                  (v) async => v.length >= 3,
                  code: 'short_name',
                ),
          );
      final errors = await schema.errorsAsync(_User('x'));
      expect(errors!.first.code, 'short_name');
      expect(errors.first.path, ['name']);
    });
  });

  group('VUnion with async option', () {
    test('propagates hasAsync', () {
      final schema = V.union([
        V.string().refineAsync((v) async => v.isNotEmpty),
        V.int(),
      ]);
      expect(schema.hasAsync, isTrue);
    });

    test('accepts async option match', () async {
      final schema = V.union([
        V.string().refineAsync((v) async => v.length > 3),
        V.int(),
      ]);
      expect(await schema.validateAsync('hello'), isTrue);
      expect(await schema.validateAsync(42), isTrue);
    });
  });

  group('addAsync (AsyncValidator)', () {
    test('accepts when validator returns null', () async {
      final schema = V.string().addAsync(const _AlwaysOkAsync());
      expect(await schema.validateAsync('anything'), isTrue);
    });

    test('rejects when validator returns non-null', () async {
      final schema = V.string().addAsync(const _AlwaysFailAsync());
      expect(await schema.validateAsync('anything'), isFalse);
    });

    test('propagates hasAsync', () {
      final schema = V.string().addAsync(const _AlwaysOkAsync());
      expect(schema.hasAsync, isTrue);
    });

    test('uses validator code', () async {
      final schema = V.string().addAsync(const _AlwaysFailAsync());
      final errors = await schema.errorsAsync('x');
      expect(errors!.first.code, 'always_fail');
    });
  });

  group('refineAsync timeout', () {
    test('passes when check completes within timeout', () async {
      final schema = V.string().refineAsync(
        (v) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return true;
        },
        timeout: const Duration(milliseconds: 100),
      );
      expect(await schema.validateAsync('x'), isTrue);
    });

    test('fails when check exceeds timeout', () async {
      final schema = V.string().refineAsync(
        (v) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return true;
        },
        timeout: const Duration(milliseconds: 20),
        message: 'Timed out',
      );
      final errors = await schema.errorsAsync('x');
      expect(errors, isNotNull);
      expect(errors!.first.message, 'Timed out');
    });
  });

  group('preprocessAsync', () {
    test('transforms input before validation', () async {
      final schema = V
          .string()
          .preprocessAsync((raw) async => raw.toString().trim())
          .min(3);
      expect(await schema.validateAsync('  hi  '), isFalse);
      expect(await schema.validateAsync('  hello  '), isTrue);
    });

    test('makes schema async-only', () {
      final schema = V.string().preprocessAsync((raw) async => raw);
      expect(schema.hasAsync, isTrue);
      expect(
        () => schema.validate('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('runs after sync preprocessors', () async {
      final log = <String>[];
      final schema = V.string().preprocess((raw) {
        log.add('sync');
        return raw;
      }).preprocessAsync((raw) async {
        log.add('async');
        return raw;
      });

      await schema.validateAsync('x');
      expect(log, ['sync', 'async']);
    });
  });

  group('transformAsync', () {
    test('converts value asynchronously after validation', () async {
      final schema = V.string().min(3).transformAsync<int>((v) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return v.length;
      });
      expect(await schema.parseAsync('hello'), 5);
    });

    test('makes schema async-only', () {
      final schema = V.string().transformAsync<int>((v) async => v.length);
      expect(schema.hasAsync, isTrue);
      expect(
        () => schema.validate('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('propagates inner failure', () async {
      final schema =
          V.string().min(5).transformAsync<int>((v) async => v.length);
      final errors = await schema.errorsAsync('ab');
      expect(errors!.first.code, 'string.too_small');
    });

    test('chains after refineAsync (async-to-async)', () async {
      final schema = V
          .string()
          .refineAsync((v) async => v.length >= 3)
          .transformAsync<int>((v) async => v.length);
      expect(await schema.parseAsync('hello'), 5);
    });
  });

  group('async + nullable/defaultValue interaction', () {
    test('refineAsync does not run for null when nullable', () async {
      var callCount = 0;
      final schema = V.string().nullable().refineAsync((v) async {
        callCount++;
        return false;
      });

      expect(await schema.validateAsync(null), isTrue);
      expect(callCount, 0, reason: 'check should not run on null');
    });

    test('defaultValue is validated by the pipeline', () async {
      final schemaOk = V.string().defaultValue('hello').refineAsync(
            (v) async => v.length >= 3,
          );
      expect(await schemaOk.validateAsync(null), isTrue);

      final schemaBad = V.string().defaultValue('x').refineAsync(
            (v) async => v.length >= 3,
          );
      expect(
        await schemaBad.validateAsync(null),
        isFalse,
        reason: 'default violates refineAsync — must fail',
      );
    });

    test('sync defaultValue is also validated (symmetry)', () {
      final schema = V.string().defaultValue('x').min(3);
      expect(schema.validate(null), isFalse);
    });

    test('safeParseAsync on null without nullable returns required error',
        () async {
      final schema = V.string().refineAsync((v) async => true);
      final result = await schema.safeParseAsync(null);

      expect(result, isA<VFailure<String?>>());
      expect((result as VFailure).errors.first.code, 'string.required');
    });
  });

  group('preprocessAsync edge cases', () {
    test('runs before coercion', () async {
      var preprocessorRan = false;
      final schema = V.coerce.int().preprocessAsync((raw) async {
        preprocessorRan = true;
        return raw.toString();
      });

      expect(await schema.parseAsync(42), 42);
      expect(preprocessorRan, isTrue);
    });

    test('can return null for a nullable schema', () async {
      final schema = V.string().nullable().preprocessAsync((raw) async => null);
      expect(await schema.parseAsync('x'), isNull);
    });

    test('preprocessor returning null fails required for non-nullable',
        () async {
      final schema = V.string().preprocessAsync((raw) async => null);
      final result = await schema.safeParseAsync('x');
      expect(result, isA<VFailure<String?>>());
    });

    test('chain multiple preprocessAsync in order', () async {
      final log = <int>[];
      final schema = V.string().preprocessAsync((raw) async {
        log.add(1);
        return raw;
      }).preprocessAsync((raw) async {
        log.add(2);
        return raw;
      });

      await schema.validateAsync('x');
      expect(log, [1, 2]);
    });

    test('value flows sync -> async preprocess -> validation', () async {
      final schema = V
          .string()
          .preprocess((v) => (v as String).trim())
          .preprocessAsync((v) async => (v as String).toLowerCase())
          .email();

      expect(await schema.validateAsync('  USER@MAIL.COM  '), isTrue);
    });
  });

  group('transformAsync edge cases', () {
    test('null propagates without calling transform', () async {
      var transformCalled = false;
      final schema = V.string().nullable().transformAsync<int>((v) async {
        transformCalled = true;
        return v.length;
      });

      expect(await schema.parseAsync(null), isNull);
      expect(transformCalled, isFalse);
    });

    test('transformAsync on failed validation does not run transform',
        () async {
      var transformCalled = false;
      final schema = V.string().min(5).transformAsync<int>((v) async {
        transformCalled = true;
        return v.length;
      });

      final result = await schema.safeParseAsync('ab');
      expect(result, isA<VFailure<int?>>());
      expect(transformCalled, isFalse);
    });

    test('chain two transformAsync', () async {
      final schema = V
          .string()
          .transformAsync<int>((v) async => v.length)
          .transformAsync<String>((n) async => 'len=$n');

      expect(await schema.parseAsync('hello'), 'len=5');
    });

    test('chain transform (sync) then transformAsync', () async {
      final schema = V
          .string()
          .transform<String>((v) => v.toUpperCase())
          .transformAsync<int>((v) async => v.length);

      expect(await schema.parseAsync('hello'), 5);
    });

    test('inner validation failure propagates unchanged', () async {
      final schema = V.string().email().transformAsync<int>(
            (v) async => v.length,
          );

      final errors = await schema.errorsAsync('not-an-email');
      expect(errors!.first.code, 'string.email');
    });

    test('accepts null via inner nullable', () async {
      final schema = V.string().nullable().transformAsync<int>(
            (v) async => v.length,
          );

      expect(await schema.parseAsync(null), isNull);
    });
  });

  group('refineAsync timeout edge cases', () {
    test('zero-duration timeout fails immediately', () async {
      final schema = V.string().refineAsync(
        (v) async {
          await Future<void>.delayed(const Duration(milliseconds: 5));
          return true;
        },
        timeout: Duration.zero,
      );

      expect(await schema.validateAsync('x'), isFalse);
    });

    test('check throwing exception propagates', () async {
      final schema = V.string().refineAsync(
            (v) async => throw StateError('boom'),
          );

      expect(
        () => schema.validateAsync('x'),
        throwsA(isA<StateError>()),
      );
    });

    test('exception in async check propagates (not as VException)', () async {
      final schema = V.string().refineAsync(
            (v) async => throw Exception('IO failure'),
          );

      expect(
        () async => await schema.validateAsync('x'),
        throwsA(isA<Exception>()),
      );
    });

    test('multiple refineAsync with one timing out collects all errors',
        () async {
      final schema = V
          .string()
          .refineAsync(
            (v) async => v.length >= 10,
            code: 'too_short',
          )
          .refineAsync(
        (v) async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return true;
        },
        timeout: const Duration(milliseconds: 20),
        code: 'timed_out',
      );

      final errors = await schema.errorsAsync('ab');
      expect(errors, isNotNull);
      expect(errors!.length, 2);
      expect(errors[0].code, 'too_short');
      expect(errors[1].code, 'timed_out');
    });
  });

  group('VUnion async edge cases', () {
    test('first async option match wins (short-circuit)', () async {
      var secondRan = false;
      final schema = V.union([
        V.string().refineAsync((v) async => true),
        V.string().refineAsync((v) async {
          secondRan = true;
          return true;
        }),
      ]);

      expect(await schema.validateAsync('x'), isTrue);
      expect(secondRan, isFalse, reason: 'short-circuit on first match');
    });

    test('all async options fail -> invalid_union', () async {
      final schema = V.union([
        V.string().refineAsync((v) async => false),
        V.int().refineAsync((v) async => false),
      ]);

      final errors = await schema.errorsAsync('hello');
      expect(errors!.first.code, 'union.invalid');
      expect(errors.first.context, isNotNull);
      expect(errors.first.context!.length, 2);
    });
  });

  group('VObject mixed sync/async fields', () {
    test('hasAsync true when any field is async', () {
      final schema =
          V.object<_MixedUser>().field('name', (u) => u.name, V.string()).field(
                'email',
                (u) => u.email,
                V.string().refineAsync((v) async => v.contains('@')),
              );
      expect(schema.hasAsync, isTrue);
    });

    test('async field error path combines with sync field error', () async {
      final schema = V
          .object<_MixedUser>()
          .field('name', (u) => u.name, V.string().min(3))
          .field(
            'email',
            (u) => u.email,
            V.string().refineAsync(
                  (v) async => v.contains('@'),
                  code: 'bad_email',
                ),
          );

      final errors = await schema.errorsAsync(_MixedUser('ab', 'bad'));
      expect(errors!.length, 2);

      expect(
        errors.any((e) => e.code == 'string.too_small' && e.path[0] == 'name'),
        isTrue,
      );
      expect(
        errors.any((e) => e.code == 'bad_email' && e.path[0] == 'email'),
        isTrue,
      );
    });
  });

  group('VObject mixed when-rules + async', () {
    test('when-rule async runs only if condition matches', () async {
      var whenRan = 0;

      final schema = V
          .object<_MixedUser>()
          .field('name', (u) => u.name, V.string())
          .field('email', (u) => u.email, V.string())
          .when('name', equals: 'trigger', then: {
        'email': V.string().refineAsync((v) async {
          whenRan++;
          return v.contains('@');
        }),
      });

      await schema.validateAsync(_MixedUser('other', 'bad'));
      expect(whenRan, 0);

      await schema.validateAsync(_MixedUser('trigger', 'a@b.com'));
      expect(whenRan, 1);
    });

    test('hasAsync true when any when-rule validator is async', () {
      final schema = V
          .object<_MixedUser>()
          .field('name', (u) => u.name, V.string())
          .field('email', (u) => u.email, V.string())
          .when('name', equals: 'x', then: {
        'email': V.string().refineAsync((v) async => true),
      });

      expect(schema.hasAsync, isTrue);
    });

    test('when-rule async error includes field path', () async {
      final schema = V
          .object<_MixedUser>()
          .field('name', (u) => u.name, V.string())
          .field('email', (u) => u.email, V.string())
          .when('name', equals: 'trigger', then: {
        'email': V.string().refineAsync(
              (v) async => v.contains('@'),
              code: 'bad_email',
            ),
      });

      final errors = await schema.errorsAsync(_MixedUser('trigger', 'bad'));

      expect(errors, isNotNull);
      expect(errors!.first.code, 'bad_email');
      expect(errors.first.path, ['email']);
    });

    test(
        'async field error AND sync when-rule error are both collected in one '
        'errorsAsync call', () async {
      final schema = V
          .object<_MixedUser>()
          .field(
            'name',
            (u) => u.name,
            V.string().refineAsync(
                  (v) async => v.length >= 3,
                  code: 'short_name_async',
                ),
          )
          .field('email', (u) => u.email, V.string())
          .when('name', equals: 'x', then: {
        'email': V.string().min(20),
      });

      final errors = await schema.errorsAsync(_MixedUser('x', 'bad'));

      expect(errors, isNotNull);
      expect(
        errors!.map((e) => e.code).toSet(),
        containsAll(<String>['short_name_async', 'string.too_small']),
      );
    });
  });

  group('VMap mixed when-rules + async', () {
    test('when-rule async runs only if condition matches', () async {
      var whenRan = 0;

      final schema = V.map({
        'type': V.string(),
        'name': V.string().nullable(),
      }).when('type', equals: 'user', then: {
        'name': V.string().refineAsync((v) async {
          whenRan++;
          return v.length >= 3;
        }),
      });

      await schema.validateAsync({'type': 'other', 'name': 'x'});
      expect(whenRan, 0);

      await schema.validateAsync({'type': 'user', 'name': 'bob'});
      expect(whenRan, 1);
    });
  });

  group('VMap strict/passthrough + async', () {
    test('strict with async field rejects extra keys and validates async',
        () async {
      final schema = V.map({
        'email': V.string().refineAsync((v) async => v.contains('@')),
      }).strict();

      final errors = await schema.errorsAsync({
        'email': 'bad',
        'extra': 1,
      });

      expect(errors, isNotNull);
      expect(errors!.any((e) => e.code == 'map.unrecognized_key'), isTrue);
      expect(errors.any((e) => e.code == 'custom'), isTrue);
    });

    test('passthrough with async field keeps extras in parsed output',
        () async {
      final schema = V.map({
        'email': V.string().refineAsync((v) async => v.contains('@')),
      }).passthrough();

      final result = await schema.parseAsync({
        'email': 'a@b.com',
        'extra': 'kept',
      });

      expect(result, {'email': 'a@b.com', 'extra': 'kept'});
    });
  });

  group('deeply nested async', () {
    test('map of array of strings with async refine', () async {
      final schema = V.map({
        'tags': V
            .string()
            .refineAsync(
              (v) async => v.length >= 2,
              code: 'short_tag',
            )
            .array(),
      });

      final errors = await schema.errorsAsync({
        'tags': ['ok', 'x', 'long'],
      });

      expect(errors!.length, 1);
      expect(errors.first.code, 'short_tag');
      expect(errors.first.path, ['tags', 1]);
    });

    test('array of map of async fields', () async {
      final item = V.map({
        'name': V.string().refineAsync(
              (v) async => v.isNotEmpty,
              code: 'empty_name',
            ),
      });
      final schema = item.array();

      final errors = await schema.errorsAsync([
        {'name': 'ok'},
        {'name': ''},
      ]);

      expect(errors!.length, 1);
      expect(errors.first.code, 'empty_name');
      expect(errors.first.path, [1, 'name']);
    });
  });

  group('locale + async', () {
    test('async validator respects custom locale', () async {
      V.setLocale(const VLocale({'custom': 'Regra customizada falhou'}));

      final schema =
          V.string().refineAsync((v) async => v == 'ok', code: 'custom');
      final errors = await schema.errorsAsync('bad');

      expect(errors!.first.message, 'Regra customizada falhou');
    });
  });

  group('coerce + refineAsync', () {
    test('preprocess coercion applies in async path', () async {
      final schema = V.coerce.int().refineAsync((v) async => v > 0);
      expect(await schema.validateAsync('5'), isTrue);
      expect(await schema.validateAsync('-1'), isFalse);
      expect(await schema.validateAsync('not a number'), isFalse);
    });
  });
}

class _MixedUser {
  final String name;
  final String email;
  _MixedUser(this.name, [this.email = 'x@y.com']);
}

class _AlwaysOkAsync extends AsyncValidator<String> {
  const _AlwaysOkAsync();
  @override
  String get code => 'always_ok';
  @override
  Future<Map<String, dynamic>?> validate(String value) async => null;
}

class _AlwaysFailAsync extends AsyncValidator<String> {
  const _AlwaysFailAsync();
  @override
  String get code => 'always_fail';
  @override
  Future<Map<String, dynamic>?> validate(String value) async => {};
}

class _User {
  final String name;
  _User(this.name);
}
