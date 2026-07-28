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

    group('date.weekday', () {
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
        expect(errs!.first.code, 'date.weekday');
      });

      test('should use custom message', () {
        final custom = VDate().weekday(message: 'Business days only');
        final errs = custom.errors(DateTime(2024, 1, 6));
        expect(errs!.first.message, 'Business days only');
      });
    });

    group('date.weekend', () {
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
        expect(errs!.first.code, 'date.weekend');
      });

      test('should use custom message', () {
        final custom = VDate().weekend(message: 'Weekends only');
        final errs = custom.errors(DateTime(2024, 1, 1));
        expect(errs!.first.message, 'Weekends only');
      });
    });

    group('date.isToday', () {
      final schema = VDate().isToday();

      DateTime today({int hour = 0, int minute = 0}) {
        final now = DateTime.now();

        return DateTime(now.year, now.month, now.day, hour, minute);
      }

      test('should pass for any time on the current day', () {
        expect(schema.validate(today()), isTrue);
        expect(schema.validate(today(hour: 9, minute: 30)), isTrue);
        expect(schema.validate(today(hour: 23, minute: 59)), isTrue);
      });

      test('should fail for yesterday and tomorrow', () {
        expect(
          schema.validate(today().subtract(const Duration(days: 1))),
          isFalse,
        );
        expect(
          schema.validate(today().add(const Duration(days: 1))),
          isFalse,
        );
      });

      test('should return error with code date.is_today', () {
        final errs = schema.errors(today().add(const Duration(days: 1)));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.is_today');
      });

      test('default message reads "Must be today"', () {
        final errs = schema.errors(today().add(const Duration(days: 1)));
        expect(errs!.first.message, 'Must be today');
      });

      test('should use custom message', () {
        final custom = VDate().isToday(message: 'Pick today');
        final errs = custom.errors(today().add(const Duration(days: 1)));
        expect(errs!.first.message, 'Pick today');
      });
    });

    group('date.sameDayAs', () {
      final reference = DateTime(2026, 5, 16, 14, 0);
      final schema = VDate().sameDayAs(reference);

      test('should pass when y/m/d matches, regardless of time', () {
        expect(schema.validate(DateTime(2026, 5, 16)), isTrue);
        expect(schema.validate(DateTime(2026, 5, 16, 9, 30)), isTrue);
        expect(schema.validate(DateTime(2026, 5, 16, 23, 59, 59)), isTrue);
      });

      test('should fail when day differs by one', () {
        expect(schema.validate(DateTime(2026, 5, 15, 14, 0)), isFalse);
        expect(schema.validate(DateTime(2026, 5, 17, 14, 0)), isFalse);
      });

      test('should fail when month or year differs', () {
        expect(schema.validate(DateTime(2026, 6, 16)), isFalse);
        expect(schema.validate(DateTime(2027, 5, 16)), isFalse);
      });

      test('should return error with code date.same_day', () {
        final errs = schema.errors(DateTime(2026, 5, 17));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.same_day');
      });

      test('default message interpolates {date}', () {
        final errs = schema.errors(DateTime(2026, 5, 17));
        expect(errs!.first.message, 'Must be the same day as $reference');
      });

      test('should use custom message function', () {
        final custom = VDate().sameDayAs(
          reference,
          message: (d) => 'Pick the day of ${d.toIso8601String()}',
        );

        final errs = custom.errors(DateTime(2026, 5, 17));
        expect(
          errs!.first.message,
          'Pick the day of ${reference.toIso8601String()}',
        );
      });
    });

    group('date.afterToday', () {
      final schema = VDate().afterToday();

      DateTime today() {
        final now = DateTime.now();

        return DateTime(now.year, now.month, now.day);
      }

      test('should pass for any future day', () {
        expect(
          schema.validate(today().add(const Duration(days: 1))),
          isTrue,
        );
        expect(
          schema.validate(today().add(const Duration(days: 30))),
          isTrue,
        );
      });

      test('should reject today (strict comparison)', () {
        final now = DateTime.now();
        expect(schema.validate(now), isFalse);
        expect(schema.validate(today()), isFalse);
      });

      test('should reject any past day', () {
        expect(
          schema.validate(today().subtract(const Duration(days: 1))),
          isFalse,
        );
      });

      test('should return error with code date.after_today', () {
        final errs = schema.errors(DateTime.now());
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.after_today');
      });

      test('should use custom message', () {
        final custom = VDate().afterToday(message: 'Must be in the future');
        final errs = custom.errors(DateTime.now());
        expect(errs!.first.message, 'Must be in the future');
      });
    });

    group('date.beforeToday', () {
      final schema = VDate().beforeToday();

      DateTime today() {
        final now = DateTime.now();

        return DateTime(now.year, now.month, now.day);
      }

      test('should pass for any past day', () {
        expect(
          schema.validate(today().subtract(const Duration(days: 1))),
          isTrue,
        );
        expect(
          schema.validate(today().subtract(const Duration(days: 365))),
          isTrue,
        );
      });

      test('should reject today (strict comparison)', () {
        expect(schema.validate(DateTime.now()), isFalse);
        expect(schema.validate(today()), isFalse);
      });

      test('should reject any future day', () {
        expect(
          schema.validate(today().add(const Duration(days: 1))),
          isFalse,
        );
      });

      test('should return error with code date.before_today', () {
        final errs = schema.errors(DateTime.now());
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.before_today');
      });

      test('should use custom message', () {
        final custom = VDate().beforeToday(message: 'Must be in the past');
        final errs = custom.errors(DateTime.now());
        expect(errs!.first.message, 'Must be in the past');
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

    group('date.age', () {
      final now = DateTime.now();

      DateTime birthAgedYears(int years) {
        return DateTime(now.year - years, now.month, now.day);
      }

      test('should pass when age meets min', () {
        final schema = VDate().age(min: 18);
        expect(schema.validate(birthAgedYears(18)), isTrue);
        expect(schema.validate(birthAgedYears(40)), isTrue);
      });

      test('should fail when age below min', () {
        final schema = VDate().age(min: 18);
        expect(schema.validate(birthAgedYears(17)), isFalse);
      });

      test('should pass when age meets max', () {
        final schema = VDate().age(max: 65);
        expect(schema.validate(birthAgedYears(30)), isTrue);
      });

      test('should fail when age above max', () {
        final schema = VDate().age(max: 65);
        expect(schema.validate(birthAgedYears(70)), isFalse);
      });

      test('should accept within range', () {
        final schema = VDate().age(min: 18, max: 65);
        expect(schema.validate(birthAgedYears(30)), isTrue);
      });

      test('should reject outside range', () {
        final schema = VDate().age(min: 18, max: 65);
        expect(schema.validate(birthAgedYears(17)), isFalse);
        expect(schema.validate(birthAgedYears(66)), isFalse);
      });

      test('should count birthday today as full year', () {
        final schema = VDate().age(min: 18);
        final todayMinus18 = DateTime(now.year - 18, now.month, now.day);
        expect(schema.validate(todayMinus18), isTrue);
      });

      test('should not count years when birthday is later this year', () {
        final schema = VDate().age(min: 18);
        final tomorrow = now.add(const Duration(days: 1));
        final todayMinus18ButTomorrow = DateTime(
          now.year - 18,
          tomorrow.month,
          tomorrow.day,
        );

        if (todayMinus18ButTomorrow.year == now.year - 18 &&
            (todayMinus18ButTomorrow.month > now.month ||
                (todayMinus18ButTomorrow.month == now.month &&
                    todayMinus18ButTomorrow.day > now.day))) {
          expect(schema.validate(todayMinus18ButTomorrow), isFalse);
        }
      });

      test('should return error with code age', () {
        final schema = VDate().age(min: 18);
        final errs = schema.errors(birthAgedYears(10));
        expect(errs, isNotNull);
        expect(errs!.first.code, 'date.age');
      });
    });

    group('array', () {
      test('should create array of dates', () {
        final now = DateTime.now();
        final future = now.add(const Duration(days: 1));
        final schema = VDate().after(now).array();

        expect(schema.validate([future]), isTrue);
        expect(
          schema.validate([now.subtract(const Duration(days: 1))]),
          isFalse,
        );
      });
    });

    group('age edge cases', () {
      test('future birthdate yields negative age, fails age(min: 0)', () {
        final schema = VDate().age(min: 0);
        final future = DateTime.now().add(const Duration(days: 365));
        expect(schema.validate(future), isFalse);
      });

      test('very old birthdate passes reasonable max', () {
        final schema = VDate().age(max: 150);
        final oldDate = DateTime(1900, 1, 1);
        expect(schema.validate(oldDate), isTrue);
      });

      test('today birthdate = age 0', () {
        final schema = VDate().age(min: 0);
        expect(schema.validate(DateTime.now()), isTrue);
      });

      test('asserts when both min and max are null', () {
        expect(() => VDate().age(), throwsA(isA<AssertionError>()));
      });
    });
  });
}
