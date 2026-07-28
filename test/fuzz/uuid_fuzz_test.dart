@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('UuidValidator fuzz', () {
    final schema = V.string().uuid();

    test('never throws on arbitrary input', () {
      fuzz('any string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(60) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('accepted inputs always match the canonical UUID shape', () {
      final shape = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
          r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

      fuzz('valid uuid hits 8-4-4-4-12', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(60) + 1);

        if (schema.validate(input)) {
          expect(shape.hasMatch(input), isTrue, reason: 'accepted: $input');
        }
      });
    });

    test('wrong length never validates', () {
      fuzz('off-length is invalid', (rng, _) {
        // 36 is the exact valid length — pick anything else.
        final len = rng.nextInt(80);
        if (len == 36) return;

        final input = randomAscii(rng, len);
        expect(schema.validate(input), isFalse);
      });
    });

    test('version filter matches the emitted UUID version', () {
      for (final version in UuidVersion.values) {
        final versioned = V.string().uuid(version: version);

        fuzz(
          'only matching version passes ($version)',
          (rng, _) {
            final input = randomAdversarial(rng, rng.nextInt(60) + 1);

            if (versioned.validate(input)) {
              // 15th char (index 14) encodes the version digit in UUIDs.
              final versionChar = input[14].toLowerCase();
              final expected = version.toString().split('.').last.substring(1);
              expect(versionChar, expected, reason: 'accepted: $input');
            }
          },
          iterations: 100,
        );
      }
    });
  });
}
