import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VDate', () {
    group('after', () {
      test('should pass when value is after date', () {
        final schema = VDate()..after(DateTime(2024, 1, 1));
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should fail when value is before date', () {
        final schema = VDate()..after(DateTime(2024, 1, 1));
        expect(schema.validate(DateTime(2023, 12, 31)), isFalse);
      });

      test('should fail when value is equal to date', () {
        final schema = VDate()..after(DateTime(2024, 1, 1));
        expect(schema.validate(DateTime(2024, 1, 1)), isFalse);
      });

      test('should return error with code too_small', () {
        final schema = VDate()..after(DateTime(2024, 1, 1));
        final errs = schema.errors(DateTime(2023, 6, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'too_small');
      });

      test('should use custom message', () {
        final schema = VDate()
          ..after(DateTime(2024, 1, 1), message: (d) => 'Too early');
        final errs = schema.errors(DateTime(2023, 1, 1));
        expect(errs!.first.message, 'Too early');
      });
    });

    group('before', () {
      test('should pass when value is before date', () {
        final schema = VDate()..before(DateTime(2024, 12, 31));
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should fail when value is after date', () {
        final schema = VDate()..before(DateTime(2024, 12, 31));
        expect(schema.validate(DateTime(2025, 1, 1)), isFalse);
      });

      test('should fail when value is equal to date', () {
        final schema = VDate()..before(DateTime(2024, 12, 31));
        expect(schema.validate(DateTime(2024, 12, 31)), isFalse);
      });

      test('should return error with code too_big', () {
        final schema = VDate()..before(DateTime(2024, 12, 31));
        final errs = schema.errors(DateTime(2025, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'too_big');
      });

      test('should use custom message', () {
        final schema = VDate()
          ..before(DateTime(2024, 12, 31), message: (d) => 'Too late');
        final errs = schema.errors(DateTime(2025, 1, 1));
        expect(errs!.first.message, 'Too late');
      });
    });

    group('between', () {
      final min = DateTime(2024, 1, 1);
      final max = DateTime(2024, 12, 31);

      test('should pass when value is within range', () {
        final schema = VDate()..between(min, max);
        expect(schema.validate(DateTime(2024, 6, 15)), isTrue);
      });

      test('should pass when value equals min (inclusive)', () {
        final schema = VDate()..between(min, max);
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
      });

      test('should pass when value equals max (inclusive)', () {
        final schema = VDate()..between(min, max);
        expect(schema.validate(DateTime(2024, 12, 31)), isTrue);
      });

      test('should fail when value is before min', () {
        final schema = VDate()..between(min, max);
        expect(schema.validate(DateTime(2023, 12, 31)), isFalse);
      });

      test('should fail when value is after max', () {
        final schema = VDate()..between(min, max);
        expect(schema.validate(DateTime(2025, 1, 1)), isFalse);
      });

      test('should return error with code not_in_range', () {
        final schema = VDate()..between(min, max);
        final errs = schema.errors(DateTime(2023, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'not_in_range');
      });

      test('should use custom message', () {
        final schema = VDate()
          ..between(min, max, message: (a, b) => 'Out of range');
        final errs = schema.errors(DateTime(2023, 1, 1));
        expect(errs!.first.message, 'Out of range');
      });
    });

    group('weekday', () {
      test('should pass for Monday through Friday', () {
        final schema = VDate()..weekday();
        // 2024-01-01 is Monday
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
        // 2024-01-02 is Tuesday
        expect(schema.validate(DateTime(2024, 1, 2)), isTrue);
        // 2024-01-03 is Wednesday
        expect(schema.validate(DateTime(2024, 1, 3)), isTrue);
        // 2024-01-04 is Thursday
        expect(schema.validate(DateTime(2024, 1, 4)), isTrue);
        // 2024-01-05 is Friday
        expect(schema.validate(DateTime(2024, 1, 5)), isTrue);
      });

      test('should fail for Saturday and Sunday', () {
        final schema = VDate()..weekday();
        // 2024-01-06 is Saturday
        expect(schema.validate(DateTime(2024, 1, 6)), isFalse);
        // 2024-01-07 is Sunday
        expect(schema.validate(DateTime(2024, 1, 7)), isFalse);
      });

      test('should return error with code weekday', () {
        final schema = VDate()..weekday();
        final errs = schema.errors(DateTime(2024, 1, 6));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'weekday');
      });

      test('should use custom message', () {
        final schema = VDate()..weekday(message: 'Business days only');
        final errs = schema.errors(DateTime(2024, 1, 6));
        expect(errs!.first.message, 'Business days only');
      });
    });

    group('weekend', () {
      test('should pass for Saturday and Sunday', () {
        final schema = VDate()..weekend();
        // 2024-01-06 is Saturday
        expect(schema.validate(DateTime(2024, 1, 6)), isTrue);
        // 2024-01-07 is Sunday
        expect(schema.validate(DateTime(2024, 1, 7)), isTrue);
      });

      test('should fail for Monday through Friday', () {
        final schema = VDate()..weekend();
        // 2024-01-01 is Monday
        expect(schema.validate(DateTime(2024, 1, 1)), isFalse);
        // 2024-01-05 is Friday
        expect(schema.validate(DateTime(2024, 1, 5)), isFalse);
      });

      test('should return error with code weekend', () {
        final schema = VDate()..weekend();
        final errs = schema.errors(DateTime(2024, 1, 1));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'weekend');
      });

      test('should use custom message', () {
        final schema = VDate()..weekend(message: 'Weekends only');
        final errs = schema.errors(DateTime(2024, 1, 1));
        expect(errs!.first.message, 'Weekends only');
      });
    });

    group('validate', () {
      test('should return true for valid DateTime', () {
        final schema = VDate();
        expect(schema.validate(DateTime(2024, 1, 1)), isTrue);
      });

      test('should return false for null', () {
        final schema = VDate();
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        final schema = VDate();
        expect(schema.validate('2024-01-01'), isFalse);
        expect(schema.validate(123), isFalse);
      });
    });

    group('parse', () {
      test('should return value when valid', () {
        final schema = VDate();
        final date = DateTime(2024, 6, 15);
        expect(schema.parse(date), date);
      });

      test('should throw when null', () {
        final schema = VDate();
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      test('should allow null when nullable', () {
        final schema = VDate()..nullable();
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('optional', () {
      test('should allow null when optional', () {
        final schema = VDate()..optional();
        expect(schema.validate(null), isTrue);
      });
    });
  });
}
