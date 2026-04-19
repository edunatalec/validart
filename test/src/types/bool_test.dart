import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/result.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VBool', () {
    group('isTrue', () {
      final schema = VBool().isTrue();

      test('should pass when value is true', () {
        expect(schema.validate(true), isTrue);
      });

      test('should fail when value is false', () {
        expect(schema.validate(false), isFalse);
      });

      test('should return error with code is_true', () {
        final errs = schema.errors(false);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'is_true');
      });

      test('should use custom message', () {
        final custom = VBool().isTrue(message: 'Please accept');
        final errs = custom.errors(false);
        expect(errs!.first.message, 'Please accept');
      });
    });

    group('isFalse', () {
      final schema = VBool().isFalse();

      test('should pass when value is false', () {
        expect(schema.validate(false), isTrue);
      });

      test('should fail when value is true', () {
        expect(schema.validate(true), isFalse);
      });

      test('should return error with code is_false', () {
        final errs = schema.errors(true);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'is_false');
      });

      test('should use custom message', () {
        final custom = VBool().isFalse(message: 'Must be off');
        final errs = custom.errors(true);
        expect(errs!.first.message, 'Must be off');
      });
    });

    group('validate', () {
      final schema = VBool();

      test('should return true for valid bool', () {
        expect(schema.validate(true), isTrue);
        expect(schema.validate(false), isTrue);
      });

      test('should return false for null', () {
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        expect(schema.validate('true'), isFalse);
        expect(schema.validate(1), isFalse);
      });
    });

    group('parse', () {
      final schema = VBool();

      test('should return value when valid', () {
        expect(schema.parse(true), isTrue);
        expect(schema.parse(false), isFalse);
      });

      test('should throw when null', () {
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });

      test('should throw when wrong type', () {
        expect(() => schema.parse('true'), throwsA(isA<VException>()));
      });
    });

    group('safeParse', () {
      final schema = VBool();

      test('should return VSuccess when valid', () {
        final result = schema.safeParse(true);
        expect(result, isA<VSuccess<bool?>>());
        expect((result as VSuccess<bool?>).value, isTrue);
      });

      test('should return VFailure when null', () {
        final result = schema.safeParse(null);
        expect(result, isA<VFailure<bool?>>());
      });
    });

    group('nullable', () {
      final schema = VBool().nullable();

      test('should allow null when nullable', () {
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });

      test('should still validate type when nullable', () {
        expect(schema.validate(true), isTrue);
      });
    });

    group('defaultValue', () {
      final schema = VBool().defaultValue(true);

      test('should use default when value is null', () {
        expect(schema.parse(null), isTrue);
      });

      test('should not use default when value is provided', () {
        expect(schema.parse(false), isFalse);
      });
    });

    group('array', () {
      test('should create array of bools', () {
        final schema = VBool().isTrue().array();
        expect(schema.validate([true, true]), isTrue);
        expect(schema.validate([true, false]), isFalse);
      });
    });
  });
}
