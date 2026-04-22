@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('NumericStringValidator fuzz', () {
    final schema = V.string().numeric();

    test('never throws on arbitrary input', () {
      fuzz('any string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(30) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('every finite double round-trips through its string form', () {
      fuzz('finite double -> toString passes', (rng, _) {
        final d = randomDouble(rng);
        if (!d.isFinite) return; // filter NaN/Infinity from generator

        expect(schema.validate(d.toString()), isTrue);
      });
    });

    test('NaN and Infinity literals are always rejected', () {
      for (final lit in ['NaN', 'Infinity', '-Infinity', '+Infinity']) {
        expect(schema.validate(lit), isFalse, reason: lit);
      }
    });

    test('random integers always pass', () {
      fuzz('int.toString always numeric', (rng, _) {
        expect(schema.validate(randomInt(rng).toString()), isTrue);
      });
    });

    test('trailing/leading whitespace never passes', () {
      fuzz('padded rejects', (rng, _) {
        final d = randomDouble(rng);
        if (!d.isFinite) return;

        expect(schema.validate(' ${d.toString()}'), isFalse);
        expect(schema.validate('${d.toString()} '), isFalse);
      });
    });

    test('empty string is always invalid', () {
      expect(schema.validate(''), isFalse);
    });
  });
}
