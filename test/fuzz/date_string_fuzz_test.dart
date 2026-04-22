@Tags(['fuzz'])
library;

import 'package:test/test.dart';
import 'package:validart/validart.dart';

import 'fuzz_helpers.dart';

void main() {
  group('DateStringValidator fuzz', () {
    final schema = V.string().date();
    final iso = V.string().date(format: 'YYYY-MM-DD');

    test('never throws on arbitrary input', () {
      fuzz('any string returns a bool', (rng, _) {
        final input = randomAdversarial(rng, rng.nextInt(30) + 1);

        expect(schema.validate(input), isA<bool>());
      });
    });

    test('random real DateTimes formatted as ISO always pass', () {
      fuzz('DateTime -> ISO passes', (rng, _) {
        final year = 1900 + rng.nextInt(200);
        final month = 1 + rng.nextInt(12);
        final dt = DateTime(year, month, 1);
        final lastDay = DateTime(year, month + 1, 0).day;
        final day = 1 + rng.nextInt(lastDay);
        final candidate = DateTime(dt.year, dt.month, day);

        final padded = '${candidate.year.toString().padLeft(4, '0')}-'
            '${candidate.month.toString().padLeft(2, '0')}-'
            '${candidate.day.toString().padLeft(2, '0')}';

        expect(schema.validate(padded), isTrue);
        expect(iso.validate(padded), isTrue);
      });
    });

    test('calendar-invalid dates never pass', () {
      // Known bad: February 30th, April 31st, month 13, day 0, month 0
      const bad = [
        '2024-02-30',
        '2024-04-31',
        '2024-13-01',
        '2024-01-00',
        '2024-00-01',
        '0000-00-00',
      ];

      for (final candidate in bad) {
        expect(
          schema.validate(candidate),
          isFalse,
          reason: 'should reject $candidate',
        );
      }
    });

    test('strings without digits never pass', () {
      fuzz('letter soup is not a date', (rng, _) {
        final len = rng.nextInt(20) + 1;
        final buf = StringBuffer();

        for (int i = 0; i < len; i++) {
          buf.writeCharCode(65 + rng.nextInt(26)); // A-Z
        }

        expect(schema.validate(buf.toString()), isFalse);
      });
    });

    test('wrong format is rejected by strict parser', () {
      fuzz('BR date fails ISO-strict', (rng, _) {
        final d = 1 + rng.nextInt(28);
        final m = 1 + rng.nextInt(12);
        final y = 2000 + rng.nextInt(25);
        final br = '${d.toString().padLeft(2, '0')}/'
            '${m.toString().padLeft(2, '0')}/$y';

        expect(iso.validate(br), isFalse);
      });
    });
  });
}
