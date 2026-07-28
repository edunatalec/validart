// Contract tests — every concrete [VType] MUST honor the pipeline
// invariants (preprocess, refine, nullable, defaultValue — sync + async).
//
// A subclass that overrides `safeParse` / `safeParseAsync` without running
// the base-class preprocess loop, or routes the success path through
// `VSuccess(value)` directly instead of `_runPipeline(value)`, fails the
// contract immediately.
//
// To register a new VType, add one more `_runPipelineContract<T>(...)` call
// in `main()` with a factory and a valid-input fixture.

import 'package:test/test.dart';
import 'package:validart/validart.dart';

enum _Color { red, green, blue }

class _Entity {
  const _Entity(this.name);
  final String name;
}

void _runPipelineContract<T>({
  required String typeName,
  required VType<T> Function() factory,
  required Object validInput,
  required T defaultVal,
  // For containers (VMap/VObject) the dependsOn key is asserted against
  // the schema at construction; pass a real declared key. For primitives
  // and other types, dependsOn is accepted but ignored at runtime, so
  // any string works.
  String dependsOnKey = 'fake',
}) {
  group('$typeName pipeline contract', () {
    setUp(() => V.setLocale(const VLocale()));

    test('preprocess runs before validation (sync path)', () {
      var ran = 0;
      factory().preprocess((v) {
        ran++;

        return v;
      }).validate(validInput);
      expect(
        ran,
        1,
        reason:
            '$typeName.safeParse must run _preprocessors loop before _resolveNull',
      );
    });

    test('sync + async preprocess both run in validateAsync', () async {
      var syncRan = 0;
      var asyncRan = 0;
      final schema = factory().preprocess((v) {
        syncRan++;

        return v;
      }).preprocessAsync((v) async {
        asyncRan++;

        return v;
      });

      await schema.validateAsync(validInput);
      expect(
        syncRan,
        1,
        reason:
            '$typeName.safeParseAsync must run sync preprocessors before async ones',
      );
      expect(
        asyncRan,
        1,
        reason: '$typeName.safeParseAsync must run _asyncPreprocessors',
      );
    });

    test('refine check is invoked on valid input', () {
      var ran = 0;
      factory().refine((v) {
        ran++;

        return true;
      }).validate(validInput);
      expect(ran, 1, reason: '$typeName dropped refine step');
    });

    test('refineAsync check is invoked on validateAsync', () async {
      var ran = 0;
      final schema = factory().refineAsync((v) async {
        ran++;

        return true;
      });

      expect(schema.hasAsync, isTrue, reason: '$typeName hasAsync regressed');
      await schema.validateAsync(validInput);
      expect(ran, 1, reason: '$typeName dropped refineAsync step');
    });

    test('nullable() accepts null', () {
      expect(
        factory().nullable().validate(null),
        isTrue,
        reason: '$typeName nullable() regressed',
      );
    });

    test('nullable() preserves hasAsync = false for fully sync chain', () {
      expect(factory().nullable().hasAsync, isFalse);
    });

    test('defaultValue() is substituted on null input', () {
      final parsed = factory().defaultValue(defaultVal).parse(null);
      expect(
        parsed,
        defaultVal,
        reason: '$typeName dropped defaultValue() substitution',
      );
    });

    test('preprocess + refine + nullable + defaultValue all combined', () {
      var preRan = 0;
      var refRan = 0;
      final schema = factory().preprocess((v) {
        preRan++;

        return v;
      }).refine((v) {
        refRan++;

        return true;
      }).defaultValue(defaultVal);

      schema.parse(validInput);
      expect(preRan, 1, reason: '$typeName dropped preprocess when chained');
      expect(refRan, 1, reason: '$typeName dropped refine when chained');

      expect(
        schema.parse(null),
        defaultVal,
        reason: '$typeName dropped defaultValue when chained',
      );
    });

    test('refine with dependsOn parameter compiles and runs on valid input',
        () {
      // dependsOn is the field-skip mechanism used by VMap/VObject.
      // For primitives the failedFieldPaths set is always empty, so the
      // step still executes. Pins the covariant override on every
      // subclass (it must accept dependsOn).
      var ran = 0;
      factory().refine(
        (v) {
          ran++;

          return true;
        },
        dependsOn: {dependsOnKey},
      ).validate(validInput);
      expect(
        ran,
        1,
        reason: '$typeName must run refine(dependsOn:) on valid input',
      );
    });

    test('hasPreprocessors is false on a bare factory()', () {
      expect(
        factory().hasPreprocessors,
        isFalse,
        reason: '$typeName.hasPreprocessors must start as false',
      );
    });

    test('hasPreprocessors flips to true after preprocess()', () {
      expect(
        factory().preprocess((v) => v).hasPreprocessors,
        isTrue,
        reason: '$typeName.hasPreprocessors must reflect preprocess()',
      );
    });

    test('hasPreprocessors flips to true after preprocessAsync()', () {
      expect(
        factory().preprocessAsync((v) async => v).hasPreprocessors,
        isTrue,
        reason: '$typeName.hasPreprocessors must reflect preprocessAsync()',
      );
    });

    test('runPreprocessors invokes the registered sync chain', () {
      var ran = 0;
      factory().preprocess((v) {
        ran++;

        return v;
      }).runPreprocessors(validInput);
      expect(
        ran,
        1,
        reason: '$typeName.runPreprocessors must execute sync preprocessors',
      );
    });

    test(
      'runPreprocessors throws VAsyncRequiredException on async preprocessor',
      () {
        final schema = factory().preprocessAsync((v) async => v);
        expect(
          () => schema.runPreprocessors(validInput),
          throwsA(isA<VAsyncRequiredException>()),
          reason: '$typeName.runPreprocessors must reject schemas with async '
              'preprocessors and point callers at runPreprocessorsAsync',
        );
      },
    );

    test(
      'runPreprocessorsAsync invokes both sync and async preprocessors',
      () async {
        var syncRan = 0;
        var asyncRan = 0;
        await factory().preprocess((v) {
          syncRan++;

          return v;
        }).preprocessAsync((v) async {
          asyncRan++;

          return v;
        }).runPreprocessorsAsync(validInput);

        expect(
          syncRan,
          1,
          reason: '$typeName.runPreprocessorsAsync must run sync chain',
        );
        expect(
          asyncRan,
          1,
          reason: '$typeName.runPreprocessorsAsync must run async chain',
        );
      },
    );

    test(
      'refineAsync with dependsOn parameter compiles and runs '
      'on valid input',
      () async {
        var ran = 0;
        final schema = factory().refineAsync(
          (v) async {
            ran++;

            return true;
          },
          dependsOn: {dependsOnKey},
        );
        await schema.validateAsync(validInput);
        expect(ran, 1, reason: '$typeName dropped refineAsync(dependsOn:)');
      },
    );
  });
}

void main() {
  _runPipelineContract<String>(
    typeName: 'VString',
    factory: V.string,
    validInput: 'hello',
    defaultVal: 'default',
  );

  _runPipelineContract<int>(
    typeName: 'VInt',
    factory: V.int,
    validInput: 42,
    defaultVal: 0,
  );

  _runPipelineContract<double>(
    typeName: 'VDouble',
    factory: V.double,
    validInput: 3.14,
    defaultVal: 0.0,
  );

  _runPipelineContract<bool>(
    typeName: 'VBool',
    factory: V.bool,
    validInput: true,
    defaultVal: false,
  );

  _runPipelineContract<DateTime>(
    typeName: 'VDate',
    factory: V.date,
    validInput: DateTime(2024, 1, 1),
    defaultVal: DateTime(2000, 1, 1),
  );

  _runPipelineContract<List<String>>(
    typeName: 'VArray<String>',
    factory: () => V.array(V.string()),
    validInput: const <String>['a', 'b'],
    defaultVal: const <String>['default'],
  );

  _runPipelineContract<Map<String, dynamic>>(
    typeName: 'VMap',
    factory: () => V.map({'name': V.string()}),
    validInput: const {'name': 'Jo'},
    defaultVal: const {'name': 'fallback'},
    dependsOnKey: 'name',
  );

  _runPipelineContract<_Entity>(
    typeName: 'VObject<_Entity>',
    factory: () => V.object<_Entity>().field('name', (e) => e.name, V.string()),
    validInput: const _Entity('Jo'),
    defaultVal: const _Entity('fallback'),
    dependsOnKey: 'name',
  );

  _runPipelineContract<_Color>(
    typeName: 'VEnum<_Color>',
    factory: () => V.enm(_Color.values),
    validInput: _Color.red,
    defaultVal: _Color.red,
  );

  _runPipelineContract<String>(
    typeName: 'VLiteral<String>',
    factory: () => V.literal('admin'),
    validInput: 'admin',
    defaultVal: 'admin',
  );

  _runPipelineContract<Object>(
    typeName: 'VUnion',
    factory: () => V.union([V.string(), V.int()]),
    validInput: 'hello',
    defaultVal: 'default',
  );

  _runPipelineContract<int>(
    typeName: 'VTransformed<String, int>',
    factory: () => V.string().transform<int>((s) => s.length),
    validInput: 'hello',
    defaultVal: 0,
  );

  group('whenMatches contract', () {
    test('VMap: preprocess runs before whenMatches; refine runs after', () {
      final order = <String>[];
      final schema = V.map({'name': V.string()}).preprocess((v) {
        order.add('preprocess');
        return v;
      }).whenMatches(
        (m) {
          order.add('whenMatches');
          return false;
        },
        dependsOn: const {'name'},
        then: const {},
      ).refine(
        (m) {
          order.add('refine');
          return true;
        },
        dependsOn: const {'name'},
      );

      schema.validate({'name': 'Jo'});
      expect(order, ['preprocess', 'whenMatches', 'refine']);
    });

    test('VObject: preprocess runs before whenMatches; refine runs after', () {
      final order = <String>[];
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .preprocess((v) {
        order.add('preprocess');
        return v;
      }).whenMatches(
        (e) {
          order.add('whenMatches');
          return false;
        },
        dependsOn: const {'name'},
        then: const {},
      ).refine(
        (e) {
          order.add('refine');
          return true;
        },
        dependsOn: const {'name'},
      );

      schema.validate(const _Entity('Jo'));
      expect(order, ['preprocess', 'whenMatches', 'refine']);
    });

    test(
      'VMap: whenMatches.then validator failures contribute to '
      'failedFieldPaths and gate later refine(dependsOn:)',
      () {
        var refineRan = false;
        final schema = V.map(
          {'role': V.string(), 'audit': V.string().nullable()},
        ).whenMatches(
          (m) => m['role'] == 'admin',
          dependsOn: const {'role'},
          then: {'audit': V.string().min(8)},
        ).refine(
          (m) {
            refineRan = true;
            return true;
          },
          code: 'unused',
          dependsOn: const {'audit'},
        );

        // role == 'admin' triggers whenMatches; "no" fails min(8) → error
        // on path [audit] → failedFieldPaths includes 'audit' → refine
        // skipped because dependsOn intersects.
        schema.validate({'role': 'admin', 'audit': 'no'});
        expect(refineRan, isFalse);

        // Reset for the second case.
        refineRan = false;

        // role != 'admin' → whenMatches skipped → no audit error → refine
        // runs because failedFieldPaths is empty.
        schema.validate({'role': 'user', 'audit': null});
        expect(refineRan, isTrue);
      },
    );
  });

  group('VObject.safeParseRaw contract', () {
    setUp(() => V.setLocale(const VLocale()));

    test('container preprocess runs once before any per-field validation', () {
      var ran = 0;
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .preprocess((v) {
        ran++;
        return v;
      });

      schema.validateRaw({'name': 'Jo'});
      expect(ran, 1);
    });

    test('refineField(stage: pre) is skipped (T-typed, no T in raw mode)', () {
      var ran = 0;
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .refineField(
        (e) {
          ran++;
          return false;
        },
        path: 'name',
        stage: RefineStage.pre,
      );

      schema.validateRaw({'name': 'Jo'});
      expect(ran, 0);
    });

    test('refineFieldRaw (Map-typed) RUNS in raw mode', () {
      var ran = 0;
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .refineFieldRaw(
        (m) {
          ran++;
          return true;
        },
        path: 'name',
      );

      schema.validateRaw({'name': 'Jo'});
      expect(ran, 1);
    });

    test('entity-level refine is skipped (callback never invoked)', () {
      var ran = 0;
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .refine((e) {
        ran++;
        return false;
      });

      schema.validateRaw({'name': 'Jo'});
      expect(ran, 0);
    });

    test('entity-level transform wrapper does not expose raw-mode API', () {
      // Once a schema is wrapped by transform(), it becomes a VTransformed
      // — only VObject<T> itself exposes safeParseRaw / parseRaw / etc.
      // The raw-mode API is therefore opt-in at the leaf, not chainable
      // through transform wrappers. Recorded here as a documented limit.
      final wrapped = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .transform<String>((e) => 'transformed');

      // ignore: avoid_dynamic_calls
      expect(
        () => (wrapped as dynamic).parseRaw({'name': 'Jo'}),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('whenMatchesRaw.condition receives the raw map input as-is', () {
      Map<String, dynamic>? seen;
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .whenMatchesRaw(
        (m) {
          seen = m;
          return false;
        },
        dependsOn: const {'name'},
        then: const {},
      );

      schema.validateRaw({'name': 'Jo', 'unknown': 1});
      expect(seen, {'name': 'Jo', 'unknown': 1});
    });

    test(
        'safeParseRaw on a schema with whenMatches (entity-only) throws '
        'VException', () {
      final schema = V
          .object<_Entity>()
          .field('name', (e) => e.name, V.string())
          .whenMatches(
        (e) => true,
        dependsOn: const {'name'},
        then: const {},
      );

      expect(
        () => schema.safeParseRaw({'name': 'Jo'}),
        throwsA(isA<VException>()),
      );
    });

    test('async: preprocessor + per-field refineAsync both honored', () async {
      var preRan = 0;
      var refineRan = 0;
      final schema = V
          .object<_Entity>()
          .field(
            'name',
            (e) => e.name,
            V.string().refineAsync((s) async {
              refineRan++;
              return true;
            }),
          )
          .preprocessAsync((v) async {
        preRan++;
        return v;
      });

      expect(await schema.validateRawAsync({'name': 'Jo'}), isTrue);
      expect(preRan, 1);
      expect(refineRan, 1);
    });
  });
}
