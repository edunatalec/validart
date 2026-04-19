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
      expect(errs!.first.code, 'invalid_literal');
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
  });
}
