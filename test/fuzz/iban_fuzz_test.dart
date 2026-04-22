@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('IbanValidator fuzz', () {
    final schema = V.string().iban();

    test('never throws on arbitrary input', () {
      fuzz('any string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(40) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('accepted inputs always start with two letters + two digits', () {
      final shape = RegExp(r'^[A-Za-z]{2}\d{2}');

      fuzz('valid iban hits country+check prefix', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(40) + 4);

        if (schema.validate(input)) {
          final stripped = input.replaceAll(' ', '');
          expect(shape.hasMatch(stripped), isTrue, reason: 'accepted: $input');
        }
      });
    });

    test('tampering with a known-valid IBAN breaks the checksum', () {
      const valid = 'GB82WEST12345698765432';

      fuzz('flip one digit -> invalid', (rng, _) {
        // Pick an index in the numeric portion and bump it by 1.
        final idx = 4 + rng.nextInt(valid.length - 4);
        final ch = valid[idx];
        if (int.tryParse(ch) == null) return;

        final bumped = (int.parse(ch) + 1) % 10;
        final tampered = valid.replaceRange(idx, idx + 1, bumped.toString());

        expect(
          schema.validate(tampered),
          isFalse,
          reason: 'tampered checksum accepted: $tampered',
        );
      });
    });

    test('strings shorter than 15 or longer than 34 never pass', () {
      fuzz('out-of-range length rejects', (rng, _) {
        // IBAN: min 15, max 34 chars (stripped).
        final tooShort = randomAscii(rng, rng.nextInt(14) + 1);
        final tooLong = randomAscii(rng, 35 + rng.nextInt(40));

        expect(schema.validate(tooShort), isFalse);
        expect(schema.validate(tooLong), isFalse);
      });
    });
  });
}
