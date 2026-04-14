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
      test('should pass when value is true', () {
        final schema = VBool()..isTrue();
        expect(schema.validate(true), isTrue);
      });

      test('should fail when value is false', () {
        final schema = VBool()..isTrue();
        expect(schema.validate(false), isFalse);
      });

      test('should return error with code is_true', () {
        final schema = VBool()..isTrue();
        final errs = schema.errors(false);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'is_true');
      });

      test('should use custom message', () {
        final schema = VBool()..isTrue(message: 'Please accept');
        final errs = schema.errors(false);
        expect(errs!.first.message, 'Please accept');
      });
    });

    group('isFalse', () {
      test('should pass when value is false', () {
        final schema = VBool()..isFalse();
        expect(schema.validate(false), isTrue);
      });

      test('should fail when value is true', () {
        final schema = VBool()..isFalse();
        expect(schema.validate(true), isFalse);
      });

      test('should return error with code is_false', () {
        final schema = VBool()..isFalse();
        final errs = schema.errors(true);
        expect(errs, isNotNull);
        expect(errs!.first.code, 'is_false');
      });

      test('should use custom message', () {
        final schema = VBool()..isFalse(message: 'Must be off');
        final errs = schema.errors(true);
        expect(errs!.first.message, 'Must be off');
      });
    });

    group('validate', () {
      test('should return true for valid bool', () {
        final schema = VBool();
        expect(schema.validate(true), isTrue);
        expect(schema.validate(false), isTrue);
      });

      test('should return false for null', () {
        final schema = VBool();
        expect(schema.validate(null), isFalse);
      });

      test('should return false for wrong type', () {
        final schema = VBool();
        expect(schema.validate('true'), isFalse);
        expect(schema.validate(1), isFalse);
      });
    });

    group('parse', () {
      test('should return value when valid', () {
        final schema = VBool();
        expect(schema.parse(true), isTrue);
        expect(schema.parse(false), isFalse);
      });

      test('should throw when null', () {
        final schema = VBool();
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });

      test('should throw when wrong type', () {
        final schema = VBool();
        expect(() => schema.parse('true'), throwsA(isA<VException>()));
      });
    });

    group('safeParse', () {
      test('should return VSuccess when valid', () {
        final schema = VBool();
        final result = schema.safeParse(true);
        expect(result, isA<VSuccess<bool?>>());
        expect((result as VSuccess<bool?>).value, isTrue);
      });

      test('should return VFailure when null', () {
        final schema = VBool();
        final result = schema.safeParse(null);
        expect(result, isA<VFailure<bool?>>());
      });
    });

    group('nullable', () {
      test('should allow null when nullable', () {
        final schema = VBool()..nullable();
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });

      test('should still validate type when nullable', () {
        final schema = VBool()..nullable();
        expect(schema.validate(true), isTrue);
      });
    });

    group('optional', () {
      test('should allow null when optional', () {
        final schema = VBool()..optional();
        expect(schema.validate(null), isTrue);
      });

      test('should still validate type when optional', () {
        final schema = VBool()..optional();
        expect(schema.validate(false), isTrue);
      });
    });

    group('defaultValue', () {
      test('should use default when value is null', () {
        final schema = VBool()..defaultValue(true);
        expect(schema.parse(null), isTrue);
      });

      test('should not use default when value is provided', () {
        final schema = VBool()..defaultValue(true);
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
