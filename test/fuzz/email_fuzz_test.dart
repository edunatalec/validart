@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('EmailValidator fuzz', () {
    final schema = V.string().email();

    test('never throws on arbitrary input', () {
      fuzz('any adversarial string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(80) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('accepted inputs always contain exactly one @', () {
      fuzz('valid emails have one @', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(80) + 1);

        if (schema.validate(input)) {
          expect(
            input.split('@').length - 1,
            1,
            reason: 'accepted email should have exactly one "@": $input',
          );
        }
      });
    });

    test('strings without @ are always rejected', () {
      fuzz('no @ means invalid', (rng, _) {
        final raw = randomAscii(rng, rng.nextInt(40) + 1);
        final sanitized = raw.replaceAll('@', 'x');

        expect(schema.validate(sanitized), isFalse);
      });
    });

    test('pure adversarial chars never produce a valid email', () {
      fuzz('junk is junk', (rng, _) {
        final len = rng.nextInt(15) + 1;
        final junk = StringBuffer();

        for (int i = 0; i < len; i++) {
          junk.write(
            kAdversarialChars[rng.nextInt(kAdversarialChars.length)],
          );
        }

        expect(schema.validate(junk.toString()), isFalse);
      });
    });
  });
}
