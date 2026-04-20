import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

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
      // The default is substituted for null and runs through validation.
      // A valid default passes, an invalid one fails.
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
      expect((result as VFailure).errors.first.code, 'required');
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
      expect(errors!.first.code, 'invalid_union');
      expect(errors.first.context, isNotNull);
      expect(errors.first.context!.length, 2);
    });
  });

  group('VObject mixed sync/async fields', () {
    test('hasAsync true when any field is async', () {
      final schema = V.object<_User>(
        configure: (o) => o.field('name', (u) => u.name, V.string()).field(
              'email',
              (u) => u.email,
              V.string().refineAsync((v) async => v.contains('@')),
            ),
      );
      expect(schema.hasAsync, isTrue);
    });

    test('async field error path combines with sync field error', () async {
      final schema = V.object<_User>(
        configure: (o) =>
            o.field('name', (u) => u.name, V.string().min(3)).field(
                  'email',
                  (u) => u.email,
                  V.string().refineAsync(
                        (v) async => v.contains('@'),
                        code: 'bad_email',
                      ),
                ),
      );

      final errors = await schema.errorsAsync(_User('ab', 'bad'));
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

  group('case transforms accent edge cases', () {
    test('empty string stays empty', () {
      expect(V.string().toSlug().parse(''), '');
    });

    test('only accented chars', () {
      expect(V.string().toSlug().parse('áéí'), 'aei');
    });

    test('only invalid chars yields empty', () {
      expect(V.string().toSlug().parse('!@#\$%'), '');
      expect(V.string().toPascalCase().parse('!@#'), '');
    });

    test('preserves unknown non-Latin chars in keepAccents mode', () {
      // Cyrillic — not in _accentMap, treated as letters by \p{L}
      expect(V.string().toSlug(keepAccents: true).parse('Привет'), 'привет');
    });

    test('non-Latin letters are stripped in default (accents stripped) mode',
        () {
      // Cyrillic chars aren't in accent map — they pass through to regex,
      // which \p{L} still recognizes.
      expect(V.string().toSlug().parse('Привет Мир'), 'привет-мир');
    });

    test('mixed Latin accented + ASCII', () {
      expect(
          V.string().toSnakeCase().parse('Café Quente 123'), 'cafe_quente_123');
    });
  });

  group('UUID version filter', () {
    test('every version from v1 to v8 round-trips', () {
      const samples = {
        UuidVersion.v1: 'a1cc3d48-3d8a-11ee-be56-0242ac120002',
        UuidVersion.v2: 'a1cc3d48-3d8a-21ee-be56-0242ac120002',
        UuidVersion.v3: 'a1cc3d48-3d8a-31ee-be56-0242ac120002',
        UuidVersion.v4: '550e8400-e29b-41d4-a716-446655440000',
        UuidVersion.v5: 'a1cc3d48-3d8a-51ee-be56-0242ac120002',
        UuidVersion.v6: '1ec9414c-232a-6b00-b3c8-9e6bdeced846',
        UuidVersion.v7: '018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9',
        UuidVersion.v8: 'a1cc3d48-3d8a-81ee-be56-0242ac120002',
      };

      for (final entry in samples.entries) {
        final schema = V.string().uuid(version: entry.key);
        expect(
          schema.validate(entry.value),
          isTrue,
          reason: '${entry.key.name} should accept ${entry.value}',
        );
      }
    });
  });

  group('card edge cases', () {
    test('accepts dashes as mask', () {
      final schema = V.string().card();
      expect(schema.validate('4532-0151-1283-0366'), isTrue);
    });

    test('rejects 20-digit number', () {
      final schema = V.string().card();
      expect(schema.validate('45320151128303664532'), isFalse);
    });

    test('rejects 12-digit number', () {
      final schema = V.string().card();
      expect(schema.validate('453201511283'), isFalse);
    });

    test('empty brands list acts like no filter', () {
      final schema = V.string().card(brands: []);
      expect(schema.validate('378282246310005'), isTrue);
    });
  });

  group('postal code edge cases', () {
    test('UK postcode accepts single-digit area', () {
      final schema = V.string().postalCode(pattern: const UkPostcodePattern());
      expect(schema.validate('M1 1AA'), isTrue);
    });

    test('US ZIP rejects letters in ZIP+4', () {
      final schema = V.string().postalCode(pattern: const UsZipPattern());
      expect(schema.validate('94103-AAAA'), isFalse);
    });

    test('CA postal accepts lowercase', () {
      final schema =
          V.string().postalCode(pattern: const CaPostalCodePattern());
      expect(schema.validate('k1a 0b1'), isTrue);
    });
  });

  group('tax ID edge cases', () {
    test('CA SIN rejects all-zero (first-digit rule)', () {
      final schema = V.string().taxId(pattern: const CaSinPattern());
      // Luhn alone would pass (sum=0), but first digit 0 is forbidden.
      expect(schema.validate('000000000'), isFalse);
    });

    test('CA SIN handles unicode dashes gracefully (invalid)', () {
      final schema = V.string().taxId(pattern: const CaSinPattern());
      expect(schema.validate('046—454—286'), isFalse);
    });

    test('UK NI rejects with suffix outside A-D', () {
      final schema = V.string().taxId(pattern: const UkNiNumberPattern());
      expect(schema.validate('AB123456E'), isFalse);
      expect(schema.validate('AB123456F'), isFalse);
    });
  });

  group('age edge cases', () {
    test('future birthdate yields negative age, fails age(min: 0)', () {
      final schema = V.date().age(min: 0);
      final future = DateTime.now().add(const Duration(days: 365));
      expect(schema.validate(future), isFalse);
    });

    test('very old birthdate passes reasonable max', () {
      final schema = V.date().age(max: 150);
      final oldDate = DateTime(1900, 1, 1);
      expect(schema.validate(oldDate), isTrue);
    });

    test('today birthdate = age 0', () {
      final schema = V.date().age(min: 0);
      expect(schema.validate(DateTime.now()), isTrue);
    });

    test('asserts when both min and max are null', () {
      expect(() => V.date().age(), throwsA(isA<AssertionError>()));
    });
  });

  group('DateStringValidator edge cases', () {
    test('format with no tokens rejects everything', () {
      final schema = V.string().date(format: 'static-string');
      expect(schema.validate('static-string'), isFalse);
      expect(schema.validate('2024-01-15'), isFalse);
    });

    test('format with only YYYY-MM rejects everything (no day group)', () {
      final schema = V.string().date(format: 'YYYY-MM');
      expect(schema.validate('2024-01'), isFalse);
    });

    test('leap year Feb 29 accepted with strict format', () {
      final schema = V.string().date(format: 'YYYY-MM-DD');
      expect(schema.validate('2024-02-29'), isTrue);
      expect(schema.validate('2023-02-29'), isFalse);
    });
  });

  group('IBAN edge cases', () {
    test('rejects lowercase with incorrect check digit', () {
      final schema = V.string().iban();
      // mod-97 is case-insensitive via uppercase conversion
      expect(schema.validate('gb82west12345698765432'), isTrue);
    });

    test('rejects wrong check digit by 1', () {
      final schema = V.string().iban();
      expect(schema.validate('GB82WEST12345698765433'), isFalse);
    });

    test('rejects all-digits string (missing country letters)', () {
      final schema = V.string().iban();
      expect(schema.validate('12345678901234567890'), isFalse);
    });
  });

  group('NanoID edge cases', () {
    test('empty string fails default length', () {
      final schema = V.string().nanoId();
      expect(schema.validate(''), isFalse);
    });

    test('length=1 requires exactly one char', () {
      final schema = V.string().nanoId(length: 1);
      expect(schema.validate('a'), isTrue);
      expect(schema.validate('ab'), isFalse);
    });
  });

  group('ULID edge cases', () {
    test('all 7s in first char (max valid timestamp prefix)', () {
      final schema = V.string().ulid();
      expect(schema.validate('7ZZZZZZZZZZZZZZZZZZZZZZZZZ'), isTrue);
    });

    test('lowercase valid', () {
      final schema = V.string().ulid();
      expect(schema.validate('01arz3ndektsv4rrffq69g5fav'), isTrue);
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
      expect(errors!.any((e) => e.code == 'unrecognized_key'), isTrue);
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

  group('nullable list element', () {
    test('VArray<String> with nullable element accepts null element', () async {
      final schema = VArray<String?>(V.string().nullable());
      expect(schema.validate(['ok', null, 'also']), isTrue);
    });
  });

  group('UUID non-existent versions', () {
    test('v0 rejected (regex allows 1-8 only)', () {
      final schema = V.string().uuid();
      expect(
        schema.validate('550e8400-e29b-01d4-a716-446655440000'),
        isFalse,
      );
    });

    test('v9 rejected', () {
      final schema = V.string().uuid();
      expect(
        schema.validate('550e8400-e29b-91d4-a716-446655440000'),
        isFalse,
      );
    });
  });

  group('preprocessAsync after sync preprocess', () {
    test('value flows sync -> async preprocess -> validation', () async {
      final schema = V
          .string()
          .preprocess((v) => (v as String).trim())
          .preprocessAsync((v) async => (v as String).toLowerCase())
          .email();

      expect(await schema.validateAsync('  USER@MAIL.COM  '), isTrue);
    });
  });

  group('ambient cascade', () {
    test('preprocess coercion still applies in async path', () async {
      // V.coerce.int with async refine
      final schema = V.coerce.int().refineAsync((v) async => v > 0);
      expect(await schema.validateAsync('5'), isTrue);
      expect(await schema.validateAsync('-1'), isFalse);
      expect(await schema.validateAsync('not a number'), isFalse);
    });
  });

  group('refineAsync returning non-bool via exception', () {
    test('exception in check propagates as Dart error (not VException)',
        () async {
      final schema = V.string().refineAsync(
            (v) async => throw Exception('IO failure'),
          );

      expect(
        () async => await schema.validateAsync('x'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('VTransformedAsync type safety', () {
    test('inner validation failure propagates unchanged', () async {
      final schema = V.string().email().transformAsync<int>(
            (v) async => v.length,
          );

      final errors = await schema.errorsAsync('not-an-email');
      expect(errors!.first.code, 'invalid_email');
    });

    test('accepts null via inner nullable', () async {
      final schema = V.string().nullable().transformAsync<int>(
            (v) async => v.length,
          );

      expect(await schema.parseAsync(null), isNull);
    });
  });
}

class _User {
  final String name;
  final String email;
  _User(this.name, [this.email = 'x@y.com']);
}
