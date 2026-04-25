import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

enum Color { red, green, blue }

enum Status { active, inactive }

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VEnum', () {
    test('should pass for valid enum value', () {
      final schema = VEnum(Color.values);
      expect(schema.validate(Color.red), isTrue);
      expect(schema.validate(Color.green), isTrue);
      expect(schema.validate(Color.blue), isTrue);
    });

    test('should fail for wrong enum type', () {
      final schema = VEnum(Color.values);
      expect(schema.validate(Status.active), isFalse);
    });

    test('should fail for non-enum value', () {
      final schema = VEnum(Color.values);
      expect(schema.validate('red'), isFalse);
      expect(schema.validate(0), isFalse);
    });

    test('should fail for null by default', () {
      final schema = VEnum(Color.values);
      expect(schema.validate(null), isFalse);
    });

    test('should pass for null when nullable', () {
      final schema = VEnum(Color.values).nullable();
      expect(schema.validate(null), isTrue);
    });

    test('should return correct error code', () {
      final schema = VEnum(Color.values);
      final errs = schema.errors('invalid');
      expect(errs!.first.code, 'enum.invalid');
    });

    test('should include valid values in error message', () {
      final schema = VEnum(Color.values);
      final errs = schema.errors('invalid');
      expect(errs!.first.message, contains('red'));
      expect(errs.first.message, contains('green'));
      expect(errs.first.message, contains('blue'));
    });

    test('should parse valid enum', () {
      final schema = VEnum(Color.values);
      expect(schema.parse(Color.blue), Color.blue);
    });

    test('should work with array', () {
      final schema = VEnum(Color.values).array();
      expect(schema.validate([Color.red, Color.blue]), isTrue);
      expect(schema.validate([Color.red, 'invalid']), isFalse);
    });

    test('should support refine', () {
      final schema = VEnum(Color.values)
          .refine((v) => v != Color.red, message: 'Red not allowed');
      expect(schema.validate(Color.green), isTrue);
      expect(schema.validate(Color.red), isFalse);
    });

    group('array', () {
      test('should validate array of enums', () {
        final schema = VEnum(Color.values).array();
        expect(schema.validate([Color.red, Color.blue]), isTrue);
      });

      test('should fail for invalid enum in array', () {
        final schema = VEnum(Color.values).array();
        expect(schema.validate([Color.red, 'invalid']), isFalse);
      });
    });

    group('preprocess propagation (regression)', () {
      test('sync preprocess runs before validation', () {
        var ran = 0;
        final schema = V.enm(Color.values).preprocess((v) {
          ran++;

          return v;
        });

        schema.validate(Color.red);
        expect(ran, 1);
      });

      test('preprocess can map a string to an enum value before validation',
          () {
        final schema = V.enm(Color.values).preprocess((v) {
          if (v is String) {
            return Color.values.firstWhere(
              (c) => c.name == v,
              orElse: () => Color.red,
            );
          }

          return v;
        });

        expect(schema.validate('green'), isTrue);
      });
    });
  });
}
