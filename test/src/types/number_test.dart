import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VInt', () {
    group('min', () {
      final schema = VInt().min(5);

      test('should pass when value >= min', () {
        expect(schema.validate(5), isTrue);
        expect(schema.validate(10), isTrue);
      });

      test('should fail when value < min', () {
        expect(schema.validate(4), isFalse);
      });

      test('should return error with code too_small', () {
        final errs = schema.errors(3);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'number.too_small');
      });
    });

    group('max', () {
      final schema = VInt().max(10);

      test('should pass when value <= max', () {
        expect(schema.validate(10), isTrue);
        expect(schema.validate(5), isTrue);
      });

      test('should fail when value > max', () {
        expect(schema.validate(11), isFalse);
      });

      test('should return error with code too_big', () {
        final errs = schema.errors(11);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'number.too_big');
      });
    });

    group('positive', () {
      final schema = VInt().positive();

      test('should pass when value is positive', () {
        expect(schema.validate(1), isTrue);
        expect(schema.validate(100), isTrue);
      });

      test('should fail when value is zero or negative', () {
        expect(schema.validate(0), isFalse);
        expect(schema.validate(-1), isFalse);
      });

      test('should return error with code positive', () {
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'positive');
      });
    });

    group('negative', () {
      final schema = VInt().negative();

      test('should pass when value is negative', () {
        expect(schema.validate(-1), isTrue);
        expect(schema.validate(-100), isTrue);
      });

      test('should fail when value is zero or positive', () {
        expect(schema.validate(0), isFalse);
        expect(schema.validate(1), isFalse);
      });

      test('should return error with code negative', () {
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'negative');
      });
    });

    group('between', () {
      final schema = VInt().between(1, 10);

      test('should pass when value is within range', () {
        expect(schema.validate(1), isTrue);
        expect(schema.validate(5), isTrue);
        expect(schema.validate(10), isTrue);
      });

      test('should fail when value is outside range', () {
        expect(schema.validate(0), isFalse);
        expect(schema.validate(11), isFalse);
      });

      test('should return error with code not_in_range', () {
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'number.not_in_range');
      });
    });

    group('multipleOf', () {
      final schema = VInt().multipleOf(3);

      test('should pass when value is a multiple of factor', () {
        expect(schema.validate(0), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(9), isTrue);
      });

      test('should fail when value is not a multiple of factor', () {
        expect(schema.validate(1), isFalse);
        expect(schema.validate(7), isFalse);
      });

      test('should return error with code multiple_of', () {
        final errs = schema.errors(4);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'multiple_of');
      });
    });

    group('even', () {
      final schema = VInt().even();

      test('should pass when value is even', () {
        expect(schema.validate(0), isTrue);
        expect(schema.validate(2), isTrue);
        expect(schema.validate(-4), isTrue);
      });

      test('should fail when value is odd', () {
        expect(schema.validate(1), isFalse);
        expect(schema.validate(3), isFalse);
        expect(schema.validate(-5), isFalse);
      });

      test('should return error with code even', () {
        final errs = schema.errors(1);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'even');
      });
    });

    group('odd', () {
      final schema = VInt().odd();

      test('should pass when value is odd', () {
        expect(schema.validate(1), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(-5), isTrue);
      });

      test('should fail when value is even', () {
        expect(schema.validate(0), isFalse);
        expect(schema.validate(2), isFalse);
        expect(schema.validate(-4), isFalse);
      });

      test('should return error with code odd', () {
        final errs = schema.errors(2);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'odd');
      });
    });

    group('prime', () {
      final schema = VInt().prime();

      test('should pass for prime numbers', () {
        expect(schema.validate(2), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(7), isTrue);
        expect(schema.validate(13), isTrue);
      });

      test('should fail for non-prime numbers', () {
        expect(schema.validate(0), isFalse);
        expect(schema.validate(1), isFalse);
        expect(schema.validate(4), isFalse);
        expect(schema.validate(9), isFalse);
      });

      test('should return error with code prime', () {
        final errs = schema.errors(4);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'prime');
      });
    });

    group('validate', () {
      final schema = VInt();

      test('should return true for valid int', () {
        expect(schema.validate(42), isTrue);
        expect(schema.validate(0), isTrue);
        expect(schema.validate(-1), isTrue);
      });

      test('should return false for null', () {
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        expect(schema.validate('42'), isFalse);
        expect(schema.validate(3.14), isFalse);
      });
    });

    group('parse', () {
      final schema = VInt();

      test('should return value when valid', () {
        expect(schema.parse(42), 42);
      });

      test('should throw when null', () {
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      final schema = VInt().nullable();

      test('should allow null when nullable', () {
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('defaultValue', () {
      final schema = VInt().defaultValue(0);

      test('should use default when value is null', () {
        expect(schema.parse(null), 0);
      });

      test('should not use default when value is provided', () {
        expect(schema.parse(42), 42);
      });
    });
  });

  group('VDouble', () {
    group('min', () {
      final schema = VDouble().min(1.5);

      test('should pass when value >= min', () {
        expect(schema.validate(1.5), isTrue);
        expect(schema.validate(2.0), isTrue);
      });

      test('should fail when value < min', () {
        expect(schema.validate(1.4), isFalse);
      });
    });

    group('max', () {
      final schema = VDouble().max(9.9);

      test('should pass when value <= max', () {
        expect(schema.validate(9.9), isTrue);
        expect(schema.validate(5.0), isTrue);
      });

      test('should fail when value > max', () {
        expect(schema.validate(10.0), isFalse);
      });
    });

    group('positive', () {
      final schema = VDouble().positive();

      test('should pass when value is positive', () {
        expect(schema.validate(0.1), isTrue);
      });

      test('should fail when value is zero or negative', () {
        expect(schema.validate(0.0), isFalse);
        expect(schema.validate(-0.1), isFalse);
      });
    });

    group('negative', () {
      final schema = VDouble().negative();

      test('should pass when value is negative', () {
        expect(schema.validate(-0.1), isTrue);
      });

      test('should fail when value is zero or positive', () {
        expect(schema.validate(0.0), isFalse);
        expect(schema.validate(0.1), isFalse);
      });
    });

    group('between', () {
      final schema = VDouble().between(1.0, 10.0);

      test('should pass when value is within range', () {
        expect(schema.validate(1.0), isTrue);
        expect(schema.validate(5.5), isTrue);
        expect(schema.validate(10.0), isTrue);
      });

      test('should fail when value is outside range', () {
        expect(schema.validate(0.9), isFalse);
        expect(schema.validate(10.1), isFalse);
      });
    });

    group('multipleOf', () {
      test('should pass when value is a multiple of factor', () {
        final schema = VDouble().multipleOf(0.5);
        expect(schema.validate(1.0), isTrue);
        expect(schema.validate(1.5), isTrue);
      });

      test('should fail when value is not a multiple of factor', () {
        final schema = VDouble().multipleOf(0.5);
        expect(schema.validate(1.3), isFalse);
      });

      test('should handle IEEE-754 imprecise multiples', () {
        final schema = VDouble().multipleOf(0.1);

        expect(schema.validate(0.3), isTrue);
        expect(schema.validate(0.6), isTrue);
        expect(schema.validate(0.9), isTrue);
        expect(schema.validate(1.3), isTrue);
      });
    });

    group('finite', () {
      final schema = VDouble().finite();

      test('should pass for normal finite values', () {
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.0), isTrue);
        expect(schema.validate(-1.5), isTrue);
      });

      test('should fail for infinity', () {
        expect(schema.validate(double.infinity), isFalse);
        expect(schema.validate(double.negativeInfinity), isFalse);
      });

      test('should fail for NaN', () {
        expect(schema.validate(double.nan), isFalse);
      });

      test('should return error with code finite', () {
        final errs = schema.errors(double.infinity);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'finite');
      });
    });

    group('decimal', () {
      final schema = VDouble().decimal();

      test('should pass when value has fractional part', () {
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.5), isTrue);
      });

      test('should fail when value is a whole number', () {
        expect(schema.validate(3.0), isFalse);
        expect(schema.validate(0.0), isFalse);
      });

      test('should return error with code decimal', () {
        final errs = schema.errors(3.0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'decimal');
      });
    });

    group('integer', () {
      final schema = VDouble().integer();

      test('should pass when value is a whole number', () {
        expect(schema.validate(3.0), isTrue);
        expect(schema.validate(0.0), isTrue);
      });

      test('should fail when value has fractional part', () {
        expect(schema.validate(3.14), isFalse);
        expect(schema.validate(0.5), isFalse);
      });

      test('should return error with code integer', () {
        final errs = schema.errors(3.14);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'integer');
      });
    });

    group('validate', () {
      final schema = VDouble();

      test('should return true for valid double', () {
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.0), isTrue);
      });

      test('should return false for null', () {
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        expect(schema.validate('3.14'), isFalse);
      });
    });

    group('parse', () {
      final schema = VDouble();

      test('should return value when valid', () {
        expect(schema.parse(3.14), 3.14);
      });

      test('should throw when null', () {
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      final schema = VDouble().nullable();

      test('should allow null when nullable', () {
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('defaultValue', () {
      final schema = VDouble().defaultValue(0.0);

      test('should use default when value is null', () {
        expect(schema.parse(null), 0.0);
      });

      test('should not use default when value is provided', () {
        expect(schema.parse(3.14), 3.14);
      });
    });

    group('array', () {
      test('should create array of doubles', () {
        final schema = (VDouble().finite()).array();
        expect(schema.validate([1.0, 2.5]), isTrue);
        expect(schema.validate([1.0, double.infinity]), isFalse);
      });
    });
  });

  group('VInt array', () {
    test('should create array of ints', () {
      final schema = (VInt().min(0)).array();
      expect(schema.validate([1, 2, 3]), isTrue);
      expect(schema.validate([1, -1, 3]), isFalse);
    });
  });
}
