import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VDate', () {
    group('after', () {
      final schema = VDate().after(DateTime(2024, 1, 1));

      test('should pass when value is after date', () {
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should fail when value is before date', () {
        expect(schema.validate(DateTime(2023, 12, 31)), isFalse);
      });

      test('should fail when value is equal to date', () {
        expect(schema.validate(DateTime(2024, 1, 1)), isFalse);
      });

      test('should return error with code too_small', () {
        final errs = schema.errors(DateTime(2023, 6, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.too_small');
      });

      test('should use custom message', () {
        final custom =
            VDate().after(DateTime(2024, 1, 1), message: (d) => 'Too early');
        final errs = custom.errors(DateTime(2023, 1, 1));
        expect(errs!.first.message, 'Too early');
      });
    });

    group('before', () {
      final schema = VDate().before(DateTime(2024, 12, 31));

      test('should pass when value is before date', () {
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should fail when value is after date', () {
        expect(schema.validate(DateTime(2025, 1, 1)), isFalse);
      });

      test('should fail when value is equal to date', () {
        expect(schema.validate(DateTime(2024, 12, 31)), isFalse);
      });

      test('should return error with code too_big', () {
        final errs = schema.errors(DateTime(2025, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.too_big');
      });

      test('should use custom message', () {
        final custom =
            VDate().before(DateTime(2024, 12, 31), message: (d) => 'Too late');
        final errs = custom.errors(DateTime(2025, 1, 1));
        expect(errs!.first.message, 'Too late');
      });
    });

    group('between', () {
      final min = DateTime(2024, 1, 1);
      final max = DateTime(2024, 12, 31);
      final schema = VDate().between(min, max);

      test('should pass when value is within range', () {
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should pass when value equals min (inclusive)', () {
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
      });

      test('should pass when value equals max (inclusive)', () {
        expect(schema.validate(DateTime(2024, 12, 31)), isTrue);
      });

      test('should fail when value is before min', () {
        expect(schema.validate(DateTime(2023, 12, 31)), isFalse);
      });

      test('should fail when value is after max', () {
        expect(schema.validate(DateTime(2025, 1, 1)), isFalse);
      });

      test('should return error with code not_in_range', () {
        final errs = schema.errors(DateTime(2023, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.not_in_range');
      });

      test('should use custom message', () {
        final custom =
            VDate().between(min, max, message: (a, b) => 'Out of range');
        final errs = custom.errors(DateTime(2023, 1, 1));
        expect(errs!.first.message, 'Out of range');
      });
    });

    group('weekday', () {
      final schema = VDate().weekday();

      test('should pass for Monday through Friday', () {
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
        expect(schema.validate(DateTime(2024, 1, 2)), isTrue);
        expect(schema.validate(DateTime(2024, 1, 3)), isTrue);
        expect(schema.validate(DateTime(2024, 1, 4)), isTrue);
        expect(schema.validate(DateTime(2024, 1, 5)), isTrue);
      });

      test('should fail for Saturday and Sunday', () {
        expect(schema.validate(DateTime(2024, 1, 6)), isFalse);
        expect(schema.validate(DateTime(2024, 1, 7)), isFalse);
      });

      test('should return error with code weekday', () {
        final errs = schema.errors(DateTime(2024, 1, 6));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'weekday');
      });

      test('should use custom message', () {
        final custom = VDate().weekday(message: 'Business days only');
        final errs = custom.errors(DateTime(2024, 1, 6));
        expect(errs!.first.message, 'Business days only');
      });
    });

    group('weekend', () {
      final schema = VDate().weekend();

      test('should pass for Saturday and Sunday', () {
        expect(schema.validate(DateTime(2024, 1, 6)), isTrue);
        expect(schema.validate(DateTime(2024, 1, 7)), isTrue);
      });

      test('should fail for Monday through Friday', () {
        expect(schema.validate(DateTime(2024, 1, 1)), isFalse);
        expect(schema.validate(DateTime(2024, 1, 5)), isFalse);
      });

      test('should return error with code weekend', () {
        final errs = schema.errors(DateTime(2024, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'weekend');
      });

      test('should use custom message', () {
        final custom = VDate().weekend(message: 'Weekends only');
        final errs = custom.errors(DateTime(2024, 1, 1));
        expect(errs!.first.message, 'Weekends only');
      });
    });

    group('validate', () {
      final schema = VDate();

      test('should return true for valid DateTime', () {
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
      });

      test('should return false for null', () {
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        expect(schema.validate('2024-01-01'), isFalse);
        expect(schema.validate(123), isFalse);
      });
    });

    group('parse', () {
      final schema = VDate();

      test('should return value when valid', () {
        final date = DateTime(2024, 6, 15);
        expect(schema.parse(date), date);
      });

      test('should throw when null', () {
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      final schema = VDate().nullable();

      test('should allow null when nullable', () {
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('array', () {
      test('should create array of dates', () {
        final now = DateTime.now();
        final future = now.add(const Duration(days: 1));
        final schema = (VDate().after(now)).array();

        expect(schema.validate([future]), isTrue);
        expect(
          schema.validate([now.subtract(const Duration(days: 1))]),
          isFalse,
        );
      });
    });
  });
}
