import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('CountryCodeFormat', () {
    test('exposes three variants', () {
      expect(CountryCodeFormat.values, hasLength(3));
      expect(CountryCodeFormat.values, contains(CountryCodeFormat.required));
      expect(CountryCodeFormat.values, contains(CountryCodeFormat.optional));
      expect(CountryCodeFormat.values, contains(CountryCodeFormat.none));
    });
  });

  group('E164PhonePattern countryCode', () {
    test('optional (default) accepts with or without +', () {
      final schema = V.string().phone();

      expect(schema.safeParse('+14155552671').isValid, isTrue);
      expect(schema.safeParse('14155552671').isValid, isTrue);
    });

    test('required rejects numbers without +', () {
      final schema = V.string().phone(
        patterns: [
          const E164PhonePattern(
            countryCode: CountryCodeFormat.required,
          ),
        ],
      );

      expect(schema.safeParse('+14155552671').isValid, isTrue);
      expect(schema.safeParse('14155552671').isValid, isFalse);
    });

    test('none rejects numbers that start with +', () {
      final schema = V.string().phone(
        patterns: [const E164PhonePattern(countryCode: CountryCodeFormat.none)],
      );

      expect(schema.safeParse('14155552671').isValid, isTrue);
      expect(schema.safeParse('+14155552671').isValid, isFalse);
    });

    test('rejects malformed inputs regardless of mode', () {
      const required = E164PhonePattern(
        countryCode: CountryCodeFormat.required,
      );

      const optional = E164PhonePattern(
        countryCode: CountryCodeFormat.optional,
      );

      const none = E164PhonePattern(countryCode: CountryCodeFormat.none);

      for (final pattern in [required, optional, none]) {
        final schema = V.string().phone(patterns: [pattern]);

        expect(schema.safeParse('').isValid, isFalse);
        expect(schema.safeParse('abc').isValid, isFalse);
        expect(schema.safeParse('+0123').isValid, isFalse);
      }
    });
  });
}
