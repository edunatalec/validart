import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.date();

      expect(validator.validate(DateTime(2025, 1, 1)), true);
      expect(validator.validate(null), false);
    });
  });

  group('after', () {
    test('should validate after correctly', () {
      final validator = v.date().after(DateTime(2025, 1, 1));

      expect(validator.validate(DateTime(2025, 1, 2)), true);
      expect(validator.validate(DateTime(2025, 1, 1)), false);
      expect(validator.validate(DateTime(2024, 12, 31)), false);
    });
  });

  group('before', () {
    test('should validate before correctly', () {
      final validator = v.date().before(DateTime(2025, 1, 1));

      expect(validator.validate(DateTime(2024, 12, 31)), true);
      expect(validator.validate(DateTime(2025, 1, 1)), false);
      expect(validator.validate(DateTime(2025, 1, 2)), false);
    });
  });

  group('betweenDates', () {
    test('should validate betweenDates correctly', () {
      final validator = v.date().betweenDates(
            DateTime(2025, 1, 1),
            DateTime(2025, 12, 31),
          );

      expect(validator.validate(DateTime(2025, 6, 15)), true);
      expect(validator.validate(DateTime(2025, 1, 1)), true);
      expect(validator.validate(DateTime(2025, 12, 31)), true);
      expect(validator.validate(DateTime(2024, 12, 31)), false);
      expect(validator.validate(DateTime(2026, 1, 1)), false);
    });
  });

  group('weekday', () {
    test('should validate weekday correctly', () {
      final validator = v.date().weekday();

      expect(validator.validate(DateTime(2025, 2, 17)), true); // Monday
      expect(validator.validate(DateTime(2025, 2, 18)), true); // Tuesday
      expect(validator.validate(DateTime(2025, 2, 19)), true); // Wednesday
      expect(validator.validate(DateTime(2025, 2, 20)), true); // Thursday
      expect(validator.validate(DateTime(2025, 2, 21)), true); // Friday
      expect(validator.validate(DateTime(2025, 2, 22)), false); // Saturday
      expect(validator.validate(DateTime(2025, 2, 23)), false); // Sunday
    });
  });

  group('weekend', () {
    test('should validate weekend correctly', () {
      final validator = v.date().weekend();

      expect(validator.validate(DateTime(2025, 2, 22)), true); // Saturday
      expect(validator.validate(DateTime(2025, 2, 23)), true); // Sunday
      expect(validator.validate(DateTime(2025, 2, 24)), false); // Monday
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = v.date().nullable();

      expect(validator.validate(DateTime(2025, 1, 1)), true);
      expect(validator.validate(null), true);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = v.date().optional();

      expect(validator.validate(DateTime(2025, 1, 1)), true);
      expect(validator.validate(null), false);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = v.date().every([
        v.date().after(DateTime(2025, 1, 1)),
        v.date().before(DateTime(2025, 12, 31)),
      ]);

      expect(validator.validate(DateTime(2025, 6, 15)), true);
      expect(validator.validate(DateTime(2026, 1, 1)), false);
      expect(validator.validate(DateTime(2024, 12, 31)), false);
    });
  });

  group('any', () {
    test('should pass if at least one validator passes', () {
      final validator = v.date().any([
        v.date().after(DateTime(2025, 12, 31)),
        v.date().before(DateTime(2025, 1, 1)),
      ]);

      expect(validator.validate(DateTime(2026, 1, 1)), true);
      expect(validator.validate(DateTime(2024, 12, 31)), true);
      expect(validator.validate(DateTime(2025, 6, 15)), false);
    });
  });

  group('refine', () {
    test('should validate refine function correctly', () {
      final validator = v.date().refine(
            (value) => value.isAfter(DateTime(2025, 1, 1)),
            message: 'The date must be after 2025-01-01',
          );

      expect(validator.validate(DateTime(2025, 6, 15)), true);
      expect(validator.validate(DateTime(2024, 12, 31)), false);
    });
  });

  group('array', () {
    test('should validate an array of dates correctly', () {
      final validator = v.date().array();

      expect(
        validator.validate([
          DateTime(2025, 1, 1),
          DateTime(2025, 6, 15),
          DateTime(2025, 12, 31)
        ]),
        true,
      );
      expect(
        validator.validate([]),
        false,
      );
    });
  });
}
