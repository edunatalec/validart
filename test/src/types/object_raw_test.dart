import 'package:test/test.dart';
import 'package:validart/validart.dart';

class _StrictDto {
  _StrictDto({required this.title, required this.scheduledDate});

  final String title;
  final DateTime scheduledDate;
}

class _UserDto {
  _UserDto({required this.name, required this.age});

  final String name;
  final int age;
}

class _TaxPayer {
  _TaxPayer(this.country, this.taxId);
  final String country;
  final String taxId;
}

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VObject.safeParseRaw', () {
    group('red-first: motivating example', () {
      test(
          'input parcial com campo required ausente: retorna erros sem '
          'precisar montar T', () {
        final VObject<_StrictDto> schema = V
            .object<_StrictDto>()
            .field('title', (_StrictDto d) => d.title, V.string())
            .field(
              'scheduledDate',
              (_StrictDto d) => d.scheduledDate,
              V.date(),
            );

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'title': 'meeting'});

        expect(errors, isNotNull);
        expect(
          errors!.where((VError e) => e.path.first == 'scheduledDate'),
          isNotEmpty,
        );
      });
    });

    group('happy path', () {
      test('returns the validated map keyed by field name', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string().min(2))
            .field('age', (_UserDto d) => d.age, V.int().positive());

        final VResult<Map<String, dynamic>?> result =
            schema.safeParseRaw(<String, dynamic>{'name': 'Alice', 'age': 30});

        expect(result, isA<VSuccess<Map<String, dynamic>?>>());
        final Map<String, dynamic> value =
            (result as VSuccess<Map<String, dynamic>?>).value!;
        expect(value, <String, dynamic>{'name': 'Alice', 'age': 30});
      });

      test('error path includes the failing field name', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string().min(5))
            .field('age', (_UserDto d) => d.age, V.int().positive());

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'age': 30});

        expect(errors, isNotNull);
        expect(errors!.first.path, <Object>['name']);
      });

      test('missing required field surfaces the field-typed required code', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int());

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo'});

        expect(errors, isNotNull);
        final VError ageError =
            errors!.firstWhere((VError e) => e.path.first == 'age');
        expect(ageError.code, VIntCode.required);
      });

      test('aggregates multiple field errors in a single pass', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string().min(5))
            .field('age', (_UserDto d) => d.age, V.int().positive());

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'age': -1});

        expect(errors, isNotNull);
        expect(
          errors!.map((VError e) => e.path.first).toSet(),
          <String>{'name', 'age'},
        );
      });

      test('per-field transforms are applied to the resulting map', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field(
              'name',
              (_UserDto d) => d.name,
              V.string().transform<String>((String s) => s.toUpperCase()),
            )
            .field('age', (_UserDto d) => d.age, V.int());

        final Map<String, dynamic>? parsed =
            schema.parseRaw(<String, dynamic>{'name': 'alice', 'age': 30});

        expect(parsed!['name'], 'ALICE');
        expect(parsed['age'], 30);
      });
    });

    group('parseRaw / validateRaw / errorsRaw mirrors', () {
      final VObject<_UserDto> schema = V
          .object<_UserDto>()
          .field('name', (_UserDto d) => d.name, V.string())
          .field('age', (_UserDto d) => d.age, V.int().positive());

      test('parseRaw returns the map on success', () {
        final Map<String, dynamic>? value =
            schema.parseRaw(<String, dynamic>{'name': 'Jo', 'age': 1});
        expect(value, <String, dynamic>{'name': 'Jo', 'age': 1});
      });

      test('parseRaw throws VException on failure', () {
        expect(
          () => schema.parseRaw(<String, dynamic>{'name': 'Jo', 'age': -1}),
          throwsA(isA<VException>()),
        );
      });

      test('validateRaw returns true on success', () {
        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
        );
      });

      test('validateRaw returns false on failure', () {
        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': -1}),
          isFalse,
        );
      });

      test('errorsRaw returns null on success', () {
        expect(
          schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isNull,
        );
      });
    });

    group('type and null handling', () {
      final VObject<_UserDto> schema = V
          .object<_UserDto>()
          .field('name', (_UserDto d) => d.name, V.string())
          .field('age', (_UserDto d) => d.age, V.int());

      test('null input emits object.required when not nullable', () {
        final List<VError>? errors = schema.errorsRaw(null);

        expect(errors, isNotNull);
        expect(errors!.single.code, VObjectCode.required);
      });

      test('null input is accepted when nullable() is set', () {
        final VObject<_UserDto> nullable = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .nullable();

        final VResult<Map<String, dynamic>?> result =
            nullable.safeParseRaw(null);
        expect(result, isA<VSuccess<Map<String, dynamic>?>>());
        expect(
          (result as VSuccess<Map<String, dynamic>?>).value,
          isNull,
        );
      });

      test('defaultValue is a no-op in raw mode (cannot substitute T into Map)',
          () {
        final VObject<_UserDto> withDefault = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .defaultValue(_UserDto(name: 'x', age: 0));

        final List<VError>? errors = withDefault.errorsRaw(null);

        expect(errors, isNotNull);
        expect(errors!.single.code, VObjectCode.required);
      });

      test('non-Map input emits object.invalid_type', () {
        final List<VError>? errors = schema.errorsRaw('not a map');

        expect(errors, isNotNull);
        expect(errors!.single.code, VObjectCode.invalidType);
      });
    });

    group('strict / passthrough', () {
      test('strict() rejects unknown keys with object.unrecognized_key', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .strict();

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'extra': true});

        expect(errors, isNotNull);
        final VError extra = errors!
            .firstWhere((VError e) => e.code == VObjectCode.unrecognizedKey);
        expect(extra.path, <Object>['extra']);
        expect(extra.message, 'Unrecognized key "extra"');
      });

      test('passthrough() copies unknown keys into the validated map', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .passthrough();

        final Map<String, dynamic>? value =
            schema.parseRaw(<String, dynamic>{'name': 'Jo', 'extra': true});

        expect(value, <String, dynamic>{'name': 'Jo', 'extra': true});
      });

      test('strict() is a no-op in entity mode (safeParse(T))', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .strict();

        expect(schema.validate(_UserDto(name: 'Jo', age: 1)), isTrue);
      });
    });

    group('when / whenMatches in raw mode', () {
      test('when applies extra validators on matching equality', () {
        final VObject<_TaxPayer> schema = V
            .object<_TaxPayer>()
            .field('country', (_TaxPayer t) => t.country, V.string())
            .field('taxId', (_TaxPayer t) => t.taxId, V.string())
            .when('country', equals: 'US', then: {'taxId': V.string().min(9)});

        expect(
          schema.validateRaw(
            <String, dynamic>{'country': 'US', 'taxId': '123456789'},
          ),
          isTrue,
        );
        expect(
          schema.validateRaw(
            <String, dynamic>{'country': 'US', 'taxId': 'short'},
          ),
          isFalse,
        );
        expect(
          schema.validateRaw(
            <String, dynamic>{'country': 'BR', 'taxId': 'short'},
          ),
          isTrue,
          reason: 'country != US → when bypassed',
        );
      });

      test(
          'whenMatchesRaw is skipped when a declared dependsOn field failed '
          'per-field (raw mode)', () {
        int conditionRan = 0;
        final VObject<_TaxPayer> schema = V
            .object<_TaxPayer>()
            .field('country', (_TaxPayer t) => t.country, V.string())
            .field('taxId', (_TaxPayer t) => t.taxId, V.string().min(3))
            .whenMatchesRaw(
          (Map<String, dynamic> m) {
            conditionRan++;
            return true;
          },
          dependsOn: const <String>{'taxId'},
          then: const <String, VType>{},
        );

        // taxId fails its per-field min(3) → whenMatchesRaw must skip.
        schema.errorsRaw(<String, dynamic>{'country': 'US', 'taxId': 'a'});

        expect(conditionRan, 0);
      });

      test('whenMatchesRaw.condition receives the raw input map directly', () {
        Map<String, dynamic>? seen;
        final VObject<_TaxPayer> schema = V
            .object<_TaxPayer>()
            .field('country', (_TaxPayer t) => t.country, V.string())
            .field('taxId', (_TaxPayer t) => t.taxId, V.string())
            .whenMatchesRaw(
          (Map<String, dynamic> m) {
            seen = m;
            return false;
          },
          dependsOn: const <String>{'country'},
          then: const <String, VType>{},
        );

        schema.validateRaw(
          <String, dynamic>{'country': 'US', 'taxId': '123456789'},
        );

        expect(seen, <String, dynamic>{'country': 'US', 'taxId': '123456789'});
      });

      test('safeParseRaw on a schema with whenMatches (entity) throws', () {
        final VObject<_TaxPayer> schema = V
            .object<_TaxPayer>()
            .field('country', (_TaxPayer t) => t.country, V.string())
            .field('taxId', (_TaxPayer t) => t.taxId, V.string())
            .whenMatches(
          (_TaxPayer t) => true,
          dependsOn: const <String>{'country'},
          then: const <String, VType>{},
        );

        expect(
          () => schema
              .safeParseRaw(<String, dynamic>{'country': 'US', 'taxId': 'x'}),
          throwsA(isA<VException>()),
        );
      });
    });

    group('hasAsync gating', () {
      VObject<_UserDto> asyncSchema() => V
          .object<_UserDto>()
          .field('name', (_UserDto d) => d.name, V.string())
          .field('age', (_UserDto d) => d.age, V.int())
          .refineAsync((_UserDto d) async => true);

      test('safeParseRaw throws when schema has async piece', () {
        expect(
          () => asyncSchema()
              .safeParseRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          throwsA(isA<VAsyncRequiredException>()),
        );
      });

      test('parseRaw throws when schema has async piece', () {
        expect(
          () =>
              asyncSchema().parseRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          throwsA(isA<VAsyncRequiredException>()),
        );
      });

      test('validateRaw throws when schema has async piece', () {
        expect(
          () => asyncSchema()
              .validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          throwsA(isA<VAsyncRequiredException>()),
        );
      });

      test('errorsRaw throws when schema has async piece', () {
        expect(
          () => asyncSchema()
              .errorsRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          throwsA(isA<VAsyncRequiredException>()),
        );
      });
    });

    group('pipeline order in raw mode (skipped entity-level rules)', () {
      test('refineField(stage: pre) is silently skipped (T-typed)', () {
        int ran = 0;
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .refineField(
          (_UserDto _) {
            ran += 1;
            return false;
          },
          path: 'name',
          stage: RefineStage.pre,
        );

        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
        );
        expect(ran, 0);
      });

      test('refine (entity-level) is silently skipped', () {
        int ran = 0;
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .refine((_UserDto _) {
          ran += 1;
          return false;
        });

        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
        );
        expect(ran, 0);
      });

      test('refineField (entity-level scoped) is silently skipped', () {
        int ran = 0;
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .refineField(
          (_UserDto _) {
            ran += 1;
            return false;
          },
          path: 'name',
        );

        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
        );
        expect(ran, 0);
      });

      test('equalFields (entity-level) is silently skipped', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .equalFields('name', 'age');

        expect(
          schema.validateRaw(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
          reason: 'mismatched name/age would fail entity mode, but raw '
              'mode skips entity-level rules',
        );
      });

      test('container preprocess still runs before validation', () {
        int ran = 0;
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .preprocess((Object? v) {
          ran += 1;
          return v;
        });

        schema.validateRaw(<String, dynamic>{'name': 'Jo'});
        expect(ran, 1);
      });
    });

    group('dual-mode coexistence', () {
      final VObject<_UserDto> schema = V
          .object<_UserDto>()
          .field('name', (_UserDto d) => d.name, V.string())
          .field('age', (_UserDto d) => d.age, V.int().positive());

      test('safeParse(T) returns T on success', () {
        final VResult<_UserDto?> result =
            schema.safeParse(_UserDto(name: 'Jo', age: 1));
        expect(result, isA<VSuccess<_UserDto?>>());
      });

      test('safeParseRaw(Map) returns Map on success', () {
        final VResult<Map<String, dynamic>?> result =
            schema.safeParseRaw(<String, dynamic>{'name': 'Jo', 'age': 1});
        expect(result, isA<VSuccess<Map<String, dynamic>?>>());
      });

      test('both surface field errors with identical paths', () {
        final List<VError>? a = schema.errors(_UserDto(name: 'Jo', age: -1));
        final List<VError>? b =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'age': -1});

        expect(a, isNotNull);
        expect(b, isNotNull);
        expect(a!.first.path, b!.first.path);
        expect(a.first.code, b.first.code);
      });
    });

    group('composition preserves raw-mode behavior', () {
      test('pick preserves strict flag', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .strict()
            .pick(<String>['name']);

        final List<VError>? errors =
            schema.errorsRaw(<String, dynamic>{'name': 'Jo', 'extra': true});

        expect(errors, isNotNull);
        expect(
          errors!.where((VError e) => e.code == VObjectCode.unrecognizedKey),
          isNotEmpty,
        );
      });

      test('omit preserves passthrough flag', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int())
            .passthrough()
            .omit(<String>['age']);

        final Map<String, dynamic>? value =
            schema.parseRaw(<String, dynamic>{'name': 'Jo', 'extra': true});

        expect(value, <String, dynamic>{'name': 'Jo', 'extra': true});
      });

      test('merge OR-es strict from either side', () {
        final VObject<_UserDto> base = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string());
        final VObject<_UserDto> ext = V
            .object<_UserDto>()
            .field('age', (_UserDto d) => d.age, V.int())
            .strict();

        final VObject<_UserDto> merged = base.merge(ext);

        final List<VError>? errors = merged.errorsRaw(<String, dynamic>{
          'name': 'Jo',
          'age': 1,
          'extra': true,
        });

        expect(errors, isNotNull);
        expect(
          errors!.where((VError e) => e.code == VObjectCode.unrecognizedKey),
          isNotEmpty,
        );
      });

      test('async: safeParseRawAsync mirrors the sync semantics', () async {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field(
              'name',
              (_UserDto d) => d.name,
              V.string().refineAsync((String s) async => s.length >= 2),
            )
            .field('age', (_UserDto d) => d.age, V.int().positive());

        expect(schema.hasAsync, isTrue);

        final Map<String, dynamic>? ok = await schema
            .parseRawAsync(<String, dynamic>{'name': 'Alice', 'age': 30});
        expect(ok, <String, dynamic>{'name': 'Alice', 'age': 30});

        final List<VError>? errors = await schema
            .errorsRawAsync(<String, dynamic>{'name': 'X', 'age': 30});
        expect(errors, isNotNull);
        expect(errors!.first.path, <Object>['name']);

        expect(
          await schema
              .validateRawAsync(<String, dynamic>{'name': 'Alice', 'age': 30}),
          isTrue,
        );
      });

      test('async: whenMatchesRaw.then async validator runs in raw mode',
          () async {
        final VObject<_TaxPayer> schema = V
            .object<_TaxPayer>()
            .field('country', (_TaxPayer t) => t.country, V.string())
            .field('taxId', (_TaxPayer t) => t.taxId, V.string())
            .whenMatchesRaw(
          (Map<String, dynamic> m) => m['country'] == 'US',
          dependsOn: const <String>{'country'},
          then: {
            'taxId':
                V.string().refineAsync((String s) async => s.startsWith('US-')),
          },
        );

        expect(
          await schema.validateRawAsync(
            <String, dynamic>{'country': 'US', 'taxId': 'US-12345'},
          ),
          isTrue,
        );
        expect(
          await schema.validateRawAsync(
            <String, dynamic>{'country': 'US', 'taxId': 'BR-12345'},
          ),
          isFalse,
        );
        expect(
          await schema.validateRawAsync(
            <String, dynamic>{'country': 'BR', 'taxId': 'anything'},
          ),
          isTrue,
        );
      });

      test('async preprocessor runs in raw mode', () async {
        int ran = 0;
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .preprocessAsync((Object? v) async {
          ran += 1;
          return v;
        });

        await schema.validateRawAsync(<String, dynamic>{'name': 'Jo'});
        expect(ran, 1);
      });

      test('sync schema works through safeParseRawAsync', () async {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string())
            .field('age', (_UserDto d) => d.age, V.int().positive());

        expect(
          await schema
              .validateRawAsync(<String, dynamic>{'name': 'Jo', 'age': 1}),
          isTrue,
        );
      });

      test('partial wraps fields with nullable, strict preserved', () {
        final VObject<_UserDto> schema = V
            .object<_UserDto>()
            .field('name', (_UserDto d) => d.name, V.string().min(2))
            .field('age', (_UserDto d) => d.age, V.int())
            .strict()
            .partial();

        expect(
          schema.validateRaw(<String, dynamic>{'name': null, 'age': null}),
          isTrue,
        );
        expect(
          schema.validateRaw(
            <String, dynamic>{'name': null, 'age': null, 'extra': true},
          ),
          isFalse,
          reason: 'strict still rejects unknown keys after partial()',
        );
      });
    });
  });
}
