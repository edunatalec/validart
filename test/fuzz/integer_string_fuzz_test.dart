@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('IntegerStringValidator fuzz', () {
    final schema = V.string().integer();

    test('never throws on arbitrary input', () {
      fuzz('any string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(20) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('any valid int round-trips through its string form', () {
      fuzz('int -> toString passes', (rng, _) {
        final n = randomInt(rng);

        expect(schema.validate(n.toString()), isTrue);
      });
    });

    test('decimal representations never pass', () {
      fuzz('3.14 is not an integer', (rng, _) {
        final n = randomInt(rng);
        final frac = rng.nextInt(999) + 1;

        expect(schema.validate('$n.$frac'), isFalse);
      });
    });

    test('scientific notation never passes', () {
      fuzz('e-notation is not an integer', (rng, _) {
        final base = randomInt(rng);
        final exp = rng.nextInt(10);

        expect(schema.validate('${base}e$exp'), isFalse);
      });
    });

    test('padded-with-whitespace never passes', () {
      fuzz('leading/trailing space rejects', (rng, _) {
        final n = randomInt(rng);
        final variant = rng.nextInt(3);
        final candidate = switch (variant) {
          0 => ' ${n.toString()}',
          1 => '${n.toString()} ',
          _ => ' ${n.toString()} ',
        };

        expect(schema.validate(candidate), isFalse);
      });
    });

    test('hex/binary prefixes never pass', () {
      fuzz('0x / 0b rejected in decimal-only validator', (rng, _) {
        final digits = randomDigits(rng, rng.nextInt(6) + 1);
        final prefix = rng.nextBool() ? '0x' : '0b';

        expect(schema.validate('$prefix$digits'), isFalse);
      });
    });

    test('empty string is always invalid', () {
      expect(schema.validate(''), isFalse);
    });
  });
}
