import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VLiteral', () {
    test('should pass for matching value', () {
      final schema = VLiteral('admin');
      expect(schema.validate('admin'), isTrue);
    });

    test('should fail for non-matching value', () {
      final schema = VLiteral('admin');
      expect(schema.validate('user'), isFalse);
      expect(schema.validate(''), isFalse);
    });

    test('should work with int literal', () {
      final schema = VLiteral(42);
      expect(schema.validate(42), isTrue);
      expect(schema.validate(43), isFalse);
    });

    test('should work with bool literal', () {
      final schema = VLiteral(true);
      expect(schema.validate(true), isTrue);
      expect(schema.validate(false), isFalse);
    });

    test('should fail for null by default', () {
      final schema = VLiteral('admin');
      expect(schema.validate(null), isFalse);
    });

    test('should pass for null when nullable', () {
      final schema = VLiteral('admin').nullable();
      expect(schema.validate(null), isTrue);
    });

    test('should return correct error code', () {
      final schema = VLiteral('admin');
      final errs = schema.errors('user');
      expect(errs!.first.code, 'literal.invalid');
    });

    test('should include expected value in error message', () {
      final schema = VLiteral('admin');
      final errs = schema.errors('user');
      expect(errs!.first.message, contains('admin'));
    });

    test('should parse matching value', () {
      final schema = VLiteral('admin');
      expect(schema.parse('admin'), 'admin');
    });

    group('preprocess propagation (regression)', () {
      test('sync preprocess runs before validation', () {
        var ran = 0;
        final schema = V.literal('admin').preprocess((v) {
          ran++;

          return v;
        });

        schema.validate('admin');
        expect(ran, 1);
      });

      test('preprocess can normalize the input before literal comparison', () {
        final schema = V.literal('admin').preprocess(
              (v) => v is String ? v.trim().toLowerCase() : v,
            );

        expect(schema.validate('  ADMIN  '), isTrue);
        expect(schema.validate('user'), isFalse);
      });
    });
  });
}
