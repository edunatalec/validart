// Dedicated tests for VTransformed<I, O> and VTransformedAsync<I, O>.
//
// Wrapper types track their own `_isNullable` / `_hasDefault` / `_steps`
// independent of the inner schema — both layers must be exercised here.
// The wrapper MUST short-circuit on its own null-handling before
// delegating to inner, otherwise `.nullable()` / `.defaultValue()` set
// on the wrapper would silently no-op.

import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VTransformed — basic transform', () {
    test('runs the inner pipeline first, then applies the transform', () {
      final schema =
          V.string().email().transform<String>((s) => s.toUpperCase());

      // Inner email() rejects 'bad' before the transform runs.
      expect(schema.validate('bad'), isFalse);
      // Inner accepts; transform applies.
      expect(schema.parse('a@b.com'), 'A@B.COM');
    });

    test('transform output type is O, not I', () {
      final schema = V.string().transform<int>((s) => s.length);
      expect(schema.parse('hello'), 5);
      expect(schema.parse('hello'), isA<int>());
    });

    test('chains: O → O via two transforms compose left-to-right', () {
      final schema = V
          .string()
          .pattern(r'^\d+$')
          .transform<int>(int.parse)
          .transform<int>((n) => n * 2);
      expect(schema.parse('21'), 42);
    });
  });

  group('VTransformed — wrapper-level nullable / defaultValue', () {
    test('.nullable() on the WRAPPER returns null on null input', () {
      // The wrapper short-circuits on null before delegating to inner —
      // the inner schema never sees null, so its own .nullable()/required
      // status is irrelevant.
      final schema = V.string().transform<int>((s) => s.length).nullable();
      expect(schema.parse(null), isNull);
    });

    test(
        '.defaultValue(O) on the WRAPPER substitutes a value of the OUTPUT type',
        () {
      // Default is `O` (int), not `I` (String) — so the wrapper does NOT
      // forward the default to inner (which would type-fail with
      // string.invalid_type for the int 0).
      final schema = V.string().transform<int>((s) => s.length).defaultValue(0);
      expect(schema.parse(null), 0);
    });

    test(
      'inner .nullable() is preserved when the wrapper has no own null-handling',
      () {
        // The wrapper delegates to inner when it itself is neither
        // nullable nor has a default — so inner's `.nullable()` still
        // accepts null at the wrapper boundary.
        final schema = V.string().nullable().transform<int>((s) => s.length);
        expect(schema.parse(null), isNull);
      },
    );

    test('wrapper-level default that fails downstream re-runs the pipeline',
        () {
      // Default is `0` (int). The wrapper's _runPipeline applies any
      // post-transform refines on top of that default, so a refine that
      // rejects 0 fires.
      final schema = V
          .string()
          .transform<int>((s) => s.length)
          .defaultValue(0)
          .refine((n) => n > 0, message: 'must be positive');
      final errs = schema.errors(null);
      expect(errs!.first.message, 'must be positive');
    });
  });

  group('VTransformed — refine on wrapper sees O, not I', () {
    test('.refine after transform receives the transformed value', () {
      final schema = V
          .string()
          .transform<int>((s) => s.length)
          .refine((n) => n.isEven, message: 'length must be even');
      expect(schema.validate('1234'), isTrue); // length 4 (even)
      expect(schema.errors('odd')?.first.message, 'length must be even');
    });

    test('.add(validator) on wrapper validates the transformed type', () {
      final schema =
          V.string().transform<int>((s) => s.length).add(const _PositiveInt());
      expect(schema.validate('hello'), isTrue);
      // Empty string → length 0 → fails the wrapper-level positive check.
      expect(schema.errors('')!.first.code, 'positive_int');
    });
  });

  group('VTransformed — preprocess on wrapper', () {
    test('wrapper preprocess runs BEFORE inner', () {
      // The wrapper's preprocess sees raw input — it must run before
      // the inner schema's pipeline so the inner sees the reshaped
      // value, not the original.
      var ran = 0;
      final schema = V.string().transform<int>((s) => s.length).preprocess((v) {
        ran++;

        return v;
      });
      schema.validate('hello');
      expect(ran, 1);
    });

    test('wrapper preprocess can reshape the input to satisfy inner', () {
      // Inner expects a String; wrapper preprocess coerces int → String.
      final schema = V.string().transform<int>((s) => s.length).preprocess(
            (v) => v is int ? v.toString() : v,
          );
      expect(schema.parse(42), 2); // '42'.length
    });
  });

  group('VTransformedAsync — async transform', () {
    test('runs inner async pipeline, then awaits the transform', () async {
      final schema = V.string().email().transformAsync<int>((v) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return v.length;
      });

      // Inner rejects 'bad' before the transform.
      expect(await schema.validateAsync('bad'), isFalse);
      // Inner accepts; transform fires.
      expect(await schema.parseAsync('a@b.com'), 'a@b.com'.length);
    });

    test('schema with transformAsync is async-only', () {
      final schema = V.string().transformAsync<int>((v) async => v.length);
      expect(schema.hasAsync, isTrue);
      expect(
        () => schema.validate('x'),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('.nullable() on the wrapper short-circuits before the transform',
        () async {
      var transformRan = 0;
      final schema = V.string().transformAsync<int>((v) async {
        transformRan++;
        return v.length;
      }).nullable();

      expect(await schema.parseAsync(null), isNull);
      expect(transformRan, 0);
    });

    test('.defaultValue(O) on async wrapper substitutes typed default',
        () async {
      final schema =
          V.string().transformAsync<int>((v) async => v.length).defaultValue(7);
      expect(await schema.parseAsync(null), 7);
    });

    test(
      'refineAsync after transformAsync sees the transformed value',
      () async {
        final schema =
            V.string().transformAsync<int>((v) async => v.length).refineAsync(
                  (n) async => n > 0,
                  message: 'must be positive',
                );
        expect(await schema.validateAsync('hello'), isTrue);
        expect(
          (await schema.errorsAsync(''))?.first.message,
          'must be positive',
        );
      },
    );

    test('failed inner validation skips the async transform', () async {
      var transformRan = 0;
      final schema = V.string().min(5).transformAsync<int>((v) async {
        transformRan++;
        return v.length;
      });

      expect(await schema.validateAsync('hi'), isFalse);
      expect(
        transformRan,
        0,
        reason: 'transformAsync must NOT fire when the inner schema rejected '
            'the input',
      );
    });
  });
}

class _PositiveInt extends Validator<int> {
  const _PositiveInt();

  @override
  String get code => 'positive_int';

  @override
  Map<String, dynamic>? validate(int value) => value > 0 ? null : {};
}
