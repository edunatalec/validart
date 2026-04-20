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
      final schema = V.object<_User>(
        configure: (o) => o.field(
          'name',
          (u) => u.name,
          V.string().refineAsync((v) async => v.isNotEmpty),
        ),
      );
      expect(schema.hasAsync, isTrue);
    });

    test('field path preserved in async errors', () async {
      final schema = V.object<_User>(
        configure: (o) => o.field(
          'name',
          (u) => u.name,
          V.string().refineAsync(
                (v) async => v.length >= 3,
                code: 'short_name',
              ),
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
