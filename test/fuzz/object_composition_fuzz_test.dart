@Tags(['fuzz'])
library;

import 'dart:math';

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

class _Wide {
  final String f0;
  final String f1;
  final String f2;
  final String f3;
  final String f4;
  final String f5;
  final String f6;
  final String f7;
  final String f8;
  final String f9;

  _Wide({
    required this.f0,
    required this.f1,
    required this.f2,
    required this.f3,
    required this.f4,
    required this.f5,
    required this.f6,
    required this.f7,
    required this.f8,
    required this.f9,
  });

  factory _Wide.uniform(String value) => _Wide(
        f0: value,
        f1: value,
        f2: value,
        f3: value,
        f4: value,
        f5: value,
        f6: value,
        f7: value,
        f8: value,
        f9: value,
      );
}

const List<String> _allKeys = [
  'f0',
  'f1',
  'f2',
  'f3',
  'f4',
  'f5',
  'f6',
  'f7',
  'f8',
  'f9',
];

VObject<_Wide> _baseSchema({int min = 1}) {
  return V
      .object<_Wide>()
      .field('f0', (w) => w.f0, V.string().min(min))
      .field('f1', (w) => w.f1, V.string().min(min))
      .field('f2', (w) => w.f2, V.string().min(min))
      .field('f3', (w) => w.f3, V.string().min(min))
      .field('f4', (w) => w.f4, V.string().min(min))
      .field('f5', (w) => w.f5, V.string().min(min))
      .field('f6', (w) => w.f6, V.string().min(min))
      .field('f7', (w) => w.f7, V.string().min(min))
      .field('f8', (w) => w.f8, V.string().min(min))
      .field('f9', (w) => w.f9, V.string().min(min));
}

List<String> _randomKeys(Random rng, {int? maxLen}) {
  final all = [..._allKeys]..shuffle(rng);
  final cap = maxLen ?? _allKeys.length;
  final n = rng.nextInt(cap + 1);

  return all.take(n).toList();
}

void main() {
  group('VObject composition fuzz', () {
    test('pick(K).schema.keys == K ∩ original.keys (preserving original order)',
        () {
      fuzz('pick narrows to intersection', (rng, _) {
        final keys = _randomKeys(rng);
        final schema = _baseSchema().pick(keys);
        final keySet = keys.toSet();

        final expected = _allKeys.where(keySet.contains).toList();
        expect(schema.schema.keys.toList(), expected);
      });
    });

    test('omit(K).schema.keys == original.keys \\ K (preserving order)', () {
      fuzz('omit subtracts', (rng, _) {
        final keys = _randomKeys(rng);
        final schema = _baseSchema().omit(keys);
        final keySet = keys.toSet();

        final expected = _allKeys.whereNot(keySet.contains).toList();
        expect(schema.schema.keys.toList(), expected);
      });
    });

    test('pick is idempotent', () {
      fuzz('pick(K).pick(K) == pick(K)', (rng, _) {
        final keys = _randomKeys(rng);
        final once = _baseSchema().pick(keys);
        final twice = once.pick(keys);

        expect(twice.schema.keys.toList(), once.schema.keys.toList());
      });
    });

    test('omit is idempotent', () {
      fuzz('omit(K).omit(K) == omit(K)', (rng, _) {
        final keys = _randomKeys(rng);
        final once = _baseSchema().omit(keys);
        final twice = once.omit(keys);

        expect(twice.schema.keys.toList(), once.schema.keys.toList());
      });
    });

    test('pick(K1).pick(K2) yields keys = K1 ∩ K2 ∩ original', () {
      fuzz('chained pick is intersection', (rng, _) {
        final k1 = _randomKeys(rng).toSet();
        final k2 = _randomKeys(rng).toSet();
        final schema = _baseSchema().pick(k1.toList()).pick(k2.toList());

        final expected =
            _allKeys.where((k) => k1.contains(k) && k2.contains(k)).toList();
        expect(schema.schema.keys.toList(), expected);
      });
    });

    test('omit(K1).omit(K2) yields keys = original \\ (K1 ∪ K2)', () {
      fuzz('chained omit is union-subtract', (rng, _) {
        final k1 = _randomKeys(rng).toSet();
        final k2 = _randomKeys(rng).toSet();
        final schema = _baseSchema().omit(k1.toList()).omit(k2.toList());

        final union = {...k1, ...k2};
        final expected = _allKeys.whereNot(union.contains).toList();
        expect(schema.schema.keys.toList(), expected);
      });
    });

    test('pick(K) ∪ omit(K) = original.keys (partition property)', () {
      fuzz('pick and omit partition the keyspace', (rng, _) {
        final keys = _randomKeys(rng);
        final picked = _baseSchema().pick(keys);
        final omitted = _baseSchema().omit(keys);

        final union = <String>{
          ...picked.schema.keys,
          ...omitted.schema.keys,
        };
        expect(union, _allKeys.toSet());
      });
    });

    test('merge(empty) keeps original key set (with possible duplicates)', () {
      fuzz('merge with empty other does not lose fields', (rng, _) {
        final keys = _randomKeys(rng);
        final base = _baseSchema().pick(keys);
        final empty = V.object<_Wide>();

        final merged = base.merge(empty);

        // Merge concatenates entries; empty contributes none.
        expect(merged.schema.keys.toSet(), base.schema.keys.toSet());
      });
    });

    test('nullable propagates through pick/omit/merge regardless of operation',
        () {
      fuzz('nullable survives composition', (rng, _) {
        final keys = _randomKeys(rng);
        final picked = _baseSchema().nullable().pick(keys);
        final omitted = _baseSchema().nullable().omit(keys);
        final mergedA = _baseSchema().nullable().merge(V.object<_Wide>());
        final mergedB = V.object<_Wide>().merge(_baseSchema().nullable());

        for (final s in [picked, omitted, mergedA, mergedB]) {
          expect(
            s.validate(null),
            isTrue,
            reason: 'nullable should propagate through composition',
          );
        }
      });
    });

    test(
        'validation never throws on a well-typed instance regardless of '
        'pick/omit shape', () {
      fuzz('no crashes on composition shapes', (rng, _) {
        final keys = _randomKeys(rng);
        final op = rng.nextInt(3);
        final schema = switch (op) {
          0 => _baseSchema().pick(keys),
          1 => _baseSchema().omit(keys),
          _ => _baseSchema().pick(keys).omit(_randomKeys(rng)),
        };

        // Build an instance with random non-empty / empty fields.
        final value = randomAscii(rng, rng.nextInt(5));
        final instance = _Wide.uniform(value);

        expect(schema.validate(instance), isA<bool>());
      });
    });

    test('pick(all) is validation-equivalent to base for accept/reject pattern',
        () {
      fuzz('picking all keys preserves accept/reject behavior', (rng, _) {
        final base = _baseSchema(min: 3);
        final picked = base.pick(_allKeys);

        final value = randomAscii(rng, rng.nextInt(8));
        final instance = _Wide.uniform(value);

        expect(picked.validate(instance), base.validate(instance));
      });
    });

    test(
        'when condition with random equals does not affect rules whose '
        'condition does not match', () {
      fuzz('non-matching when never fires', (rng, _) {
        final randomTrigger = randomAscii(rng, rng.nextInt(8) + 1);
        final actual = randomAscii(rng, rng.nextInt(8) + 1);

        // Make sure they differ (bias towards mismatch).
        if (randomTrigger == actual) return;

        final schema = _baseSchema().when(
          'f0',
          equals: randomTrigger,
          then: {
            // Impossible-to-pass validator: if it ever fires, validation fails.
            'f1': V.string().min(10000),
          },
        );

        final instance = _Wide.uniform(actual);

        // Baseline alone should validate (every f* has length >= 1).
        // 'when' must not trigger since f0 == actual ≠ randomTrigger.
        if (actual.isNotEmpty) {
          expect(
            schema.validate(instance),
            isTrue,
            reason: 'when fired despite condition mismatch '
                '(trigger=$randomTrigger actual=$actual)',
          );
        }
      });
    });

    test('equalFields stays consistent through pick (extractor captured)', () {
      fuzz('equalFields after pick still validates the dropped field',
          (rng, _) {
        final base =
            _baseSchema().equalFields('f0', 'f1').pick(['f2', 'f3', 'f4']);

        final same = randomAscii(rng, rng.nextInt(5) + 1);
        final equalInstance = _Wide.uniform(same);

        // f0 == f1 — equalFields should pass.
        expect(base.validate(equalInstance), isTrue);

        final differentF1 = _Wide(
          f0: same,
          f1: '$same!diff',
          f2: same,
          f3: same,
          f4: same,
          f5: same,
          f6: same,
          f7: same,
          f8: same,
          f9: same,
        );
        // f0 != f1 — equalFields should fail despite f1 not being in the schema.
        expect(base.validate(differentF1), isFalse);
      });
    });
  });
}

extension _IterableExt<T> on Iterable<T> {
  Iterable<T> whereNot(bool Function(T) f) => where((e) => !f(e));
}
