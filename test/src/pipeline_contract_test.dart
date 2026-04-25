// Contract tests — every concrete [VType] MUST honor the pipeline
// invariants (preprocess, refine, nullable, defaultValue — sync + async).
//
// This file exists to prevent regressions of the 1.4.0 preprocess bug: if
// someone adds a new VType subclass with its own `safeParse` / `safeParseAsync`
// override and forgets to run the base-class preprocess loop, the contract
// test for that type fails immediately.
//
// To register a new VType, add one more `_runPipelineContract<T>(...)` call
// in `main()` with a factory and a valid-input fixture.

import 'package:test/test.dart';
import 'package:validart/validart.dart';

enum _Color { red, green, blue }

class _Entity {
  final String name;
  const _Entity(this.name);
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
    factory: () => V.string(),
    validInput: 'hello',
    defaultVal: 'default',
  );

  _runPipelineContract<int>(
    typeName: 'VInt',
    factory: () => V.int(),
    validInput: 42,
    defaultVal: 0,
  );

  _runPipelineContract<double>(
    typeName: 'VDouble',
    factory: () => V.double(),
    validInput: 3.14,
    defaultVal: 0.0,
  );

  _runPipelineContract<bool>(
    typeName: 'VBool',
    factory: () => V.bool(),
    validInput: true,
    defaultVal: false,
  );

  _runPipelineContract<DateTime>(
    typeName: 'VDate',
    factory: () => V.date(),
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
}
