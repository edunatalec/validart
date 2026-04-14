import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VInt', () {
    group('min', () {
      test('should pass when value >= min', () {
        final schema = VInt()..min(5);
        expect(schema.validate(5), isTrue);
        expect(schema.validate(10), isTrue);
      });

      test('should fail when value < min', () {
        final schema = VInt()..min(5);
        expect(schema.validate(4), isFalse);
      });

      test('should return error with code too_small', () {
        final schema = VInt()..min(5);
        final errs = schema.errors(3);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'too_small');
      });
    });

    group('max', () {
      test('should pass when value <= max', () {
        final schema = VInt()..max(10);
        expect(schema.validate(10), isTrue);
        expect(schema.validate(5), isTrue);
      });

      test('should fail when value > max', () {
        final schema = VInt()..max(10);
        expect(schema.validate(11), isFalse);
      });

      test('should return error with code too_big', () {
        final schema = VInt()..max(10);
        final errs = schema.errors(11);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'too_big');
      });
    });

    group('positive', () {
      test('should pass when value is positive', () {
        final schema = VInt()..positive();
        expect(schema.validate(1), isTrue);
        expect(schema.validate(100), isTrue);
      });

      test('should fail when value is zero or negative', () {
        final schema = VInt()..positive();
        expect(schema.validate(0), isFalse);
        expect(schema.validate(-1), isFalse);
      });

      test('should return error with code positive', () {
        final schema = VInt()..positive();
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'positive');
      });
    });

    group('negative', () {
      test('should pass when value is negative', () {
        final schema = VInt()..negative();
        expect(schema.validate(-1), isTrue);
        expect(schema.validate(-100), isTrue);
      });

      test('should fail when value is zero or positive', () {
        final schema = VInt()..negative();
        expect(schema.validate(0), isFalse);
        expect(schema.validate(1), isFalse);
      });

      test('should return error with code negative', () {
        final schema = VInt()..negative();
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'negative');
      });
    });

    group('between', () {
      test('should pass when value is within range', () {
        final schema = VInt()..between(1, 10);
        expect(schema.validate(1), isTrue);
        expect(schema.validate(5), isTrue);
        expect(schema.validate(10), isTrue);
      });

      test('should fail when value is outside range', () {
        final schema = VInt()..between(1, 10);
        expect(schema.validate(0), isFalse);
        expect(schema.validate(11), isFalse);
      });

      test('should return error with code not_in_range', () {
        final schema = VInt()..between(1, 10);
        final errs = schema.errors(0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'not_in_range');
      });
    });

    group('multipleOf', () {
      test('should pass when value is a multiple of factor', () {
        final schema = VInt()..multipleOf(3);
        expect(schema.validate(0), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(9), isTrue);
      });

      test('should fail when value is not a multiple of factor', () {
        final schema = VInt()..multipleOf(3);
        expect(schema.validate(1), isFalse);
        expect(schema.validate(7), isFalse);
      });

      test('should return error with code multiple_of', () {
        final schema = VInt()..multipleOf(3);
        final errs = schema.errors(4);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'multiple_of');
      });
    });

    group('even', () {
      test('should pass when value is even', () {
        final schema = VInt()..even();
        expect(schema.validate(0), isTrue);
        expect(schema.validate(2), isTrue);
        expect(schema.validate(-4), isTrue);
      });

      test('should fail when value is odd', () {
        final schema = VInt()..even();
        expect(schema.validate(1), isFalse);
        expect(schema.validate(3), isFalse);
        expect(schema.validate(-5), isFalse);
      });

      test('should return error with code even', () {
        final schema = VInt()..even();
        final errs = schema.errors(1);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'even');
      });
    });

    group('odd', () {
      test('should pass when value is odd', () {
        final schema = VInt()..odd();
        expect(schema.validate(1), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(-5), isTrue);
      });

      test('should fail when value is even', () {
        final schema = VInt()..odd();
        expect(schema.validate(0), isFalse);
        expect(schema.validate(2), isFalse);
        expect(schema.validate(-4), isFalse);
      });

      test('should return error with code odd', () {
        final schema = VInt()..odd();
        final errs = schema.errors(2);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'odd');
      });
    });

    group('prime', () {
      test('should pass for prime numbers', () {
        final schema = VInt()..prime();
        expect(schema.validate(2), isTrue);
        expect(schema.validate(3), isTrue);
        expect(schema.validate(7), isTrue);
        expect(schema.validate(13), isTrue);
      });

      test('should fail for non-prime numbers', () {
        final schema = VInt()..prime();
        expect(schema.validate(0), isFalse);
        expect(schema.validate(1), isFalse);
        expect(schema.validate(4), isFalse);
        expect(schema.validate(9), isFalse);
      });

      test('should return error with code prime', () {
        final schema = VInt()..prime();
        final errs = schema.errors(4);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'prime');
      });
    });

    group('validate', () {
      test('should return true for valid int', () {
        final schema = VInt();
        expect(schema.validate(42), isTrue);
        expect(schema.validate(0), isTrue);
        expect(schema.validate(-1), isTrue);
      });

      test('should return false for null', () {
        final schema = VInt();
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        final schema = VInt();
        expect(schema.validate('42'), isFalse);
        expect(schema.validate(3.14), isFalse);
      });
    });

    group('parse', () {
      test('should return value when valid', () {
        final schema = VInt();
        expect(schema.parse(42), 42);
      });

      test('should throw when null', () {
        final schema = VInt();
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      test('should allow null when nullable', () {
        final schema = VInt()..nullable();
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('optional', () {
      test('should allow null when optional', () {
        final schema = VInt()..optional();
        expect(schema.validate(null), isTrue);
      });
    });

    group('defaultValue', () {
      test('should use default when value is null', () {
        final schema = VInt()..defaultValue(0);
        expect(schema.parse(null), 0);
      });

      test('should not use default when value is provided', () {
        final schema = VInt()..defaultValue(0);
        expect(schema.parse(42), 42);
      });
    });
  });

  group('VDouble', () {
    group('min', () {
      test('should pass when value >= min', () {
        final schema = VDouble()..min(1.5);
        expect(schema.validate(1.5), isTrue);
        expect(schema.validate(2.0), isTrue);
      });

      test('should fail when value < min', () {
        final schema = VDouble()..min(1.5);
        expect(schema.validate(1.4), isFalse);
      });
    });

    group('max', () {
      test('should pass when value <= max', () {
        final schema = VDouble()..max(9.9);
        expect(schema.validate(9.9), isTrue);
        expect(schema.validate(5.0), isTrue);
      });

      test('should fail when value > max', () {
        final schema = VDouble()..max(9.9);
        expect(schema.validate(10.0), isFalse);
      });
    });

    group('positive', () {
      test('should pass when value is positive', () {
        final schema = VDouble()..positive();
        expect(schema.validate(0.1), isTrue);
      });

      test('should fail when value is zero or negative', () {
        final schema = VDouble()..positive();
        expect(schema.validate(0.0), isFalse);
        expect(schema.validate(-0.1), isFalse);
      });
    });

    group('negative', () {
      test('should pass when value is negative', () {
        final schema = VDouble()..negative();
        expect(schema.validate(-0.1), isTrue);
      });

      test('should fail when value is zero or positive', () {
        final schema = VDouble()..negative();
        expect(schema.validate(0.0), isFalse);
        expect(schema.validate(0.1), isFalse);
      });
    });

    group('between', () {
      test('should pass when value is within range', () {
        final schema = VDouble()..between(1.0, 10.0);
        expect(schema.validate(1.0), isTrue);
        expect(schema.validate(5.5), isTrue);
        expect(schema.validate(10.0), isTrue);
      });

      test('should fail when value is outside range', () {
        final schema = VDouble()..between(1.0, 10.0);
        expect(schema.validate(0.9), isFalse);
        expect(schema.validate(10.1), isFalse);
      });
    });

    group('multipleOf', () {
      test('should pass when value is a multiple of factor', () {
        final schema = VDouble()..multipleOf(0.5);
        expect(schema.validate(1.0), isTrue);
        expect(schema.validate(1.5), isTrue);
      });

      test('should fail when value is not a multiple of factor', () {
        final schema = VDouble()..multipleOf(0.5);
        expect(schema.validate(1.3), isFalse);
      });
    });

    group('finite', () {
      test('should pass for normal finite values', () {
        final schema = VDouble()..finite();
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.0), isTrue);
        expect(schema.validate(-1.5), isTrue);
      });

      test('should fail for infinity', () {
        final schema = VDouble()..finite();
        expect(schema.validate(double.infinity), isFalse);
        expect(schema.validate(double.negativeInfinity), isFalse);
      });

      test('should fail for NaN', () {
        final schema = VDouble()..finite();
        expect(schema.validate(double.nan), isFalse);
      });

      test('should return error with code finite', () {
        final schema = VDouble()..finite();
        final errs = schema.errors(double.infinity);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'finite');
      });
    });

    group('decimal', () {
      test('should pass when value has fractional part', () {
        final schema = VDouble()..decimal();
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.5), isTrue);
      });

      test('should fail when value is a whole number', () {
        final schema = VDouble()..decimal();
        expect(schema.validate(3.0), isFalse);
        expect(schema.validate(0.0), isFalse);
      });

      test('should return error with code decimal', () {
        final schema = VDouble()..decimal();
        final errs = schema.errors(3.0);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'decimal');
      });
    });

    group('integer', () {
      test('should pass when value is a whole number', () {
        final schema = VDouble()..integer();
        expect(schema.validate(3.0), isTrue);
        expect(schema.validate(0.0), isTrue);
      });

      test('should fail when value has fractional part', () {
        final schema = VDouble()..integer();
        expect(schema.validate(3.14), isFalse);
        expect(schema.validate(0.5), isFalse);
      });

      test('should return error with code integer', () {
        final schema = VDouble()..integer();
        final errs = schema.errors(3.14);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'integer');
      });
    });

    group('validate', () {
      test('should return true for valid double', () {
        final schema = VDouble();
        expect(schema.validate(3.14), isTrue);
        expect(schema.validate(0.0), isTrue);
      });

      test('should return false for null', () {
        final schema = VDouble();
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        final schema = VDouble();
        expect(schema.validate('3.14'), isFalse);
      });
    });

    group('parse', () {
      test('should return value when valid', () {
        final schema = VDouble();
        expect(schema.parse(3.14), 3.14);
      });

      test('should throw when null', () {
        final schema = VDouble();
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });
    });

    group('nullable', () {
      test('should allow null when nullable', () {
        final schema = VDouble()..nullable();
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });
    });

    group('optional', () {
      test('should allow null when optional', () {
        final schema = VDouble()..optional();
        expect(schema.validate(null), isTrue);
      });
    });

    group('defaultValue', () {
      test('should use default when value is null', () {
        final schema = VDouble()..defaultValue(0.0);
        expect(schema.parse(null), 0.0);
      });

      test('should not use default when value is provided', () {
        final schema = VDouble()..defaultValue(0.0);
        expect(schema.parse(3.14), 3.14);
      });
    });

    group('array', () {
      test('should create array of doubles', () {
        final schema = (VDouble()..finite()).array();
        expect(schema.validate([1.0, 2.5]), isTrue);
        expect(schema.validate([1.0, double.infinity]), isFalse);
      });
    });
  });

  group('VInt array', () {
    test('should create array of ints', () {
      final schema = (VInt()..min(0)).array();
      expect(schema.validate([1, 2, 3]), isTrue);
      expect(schema.validate([1, -1, 3]), isFalse);
    });
  });
}
