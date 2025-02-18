import 'package:validart/validart.dart';
import 'package:test/test.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.map({'key': v.string()});

      expect(validator.validate({'key': 'value'}), true);
      expect(validator.validate({}), false);
      expect(validator.validate(null), false);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = v.map({'key': v.string()}).optional();

      expect(validator.validate({}), true);
      expect(validator.validate(null), false);
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = v.map({'key': v.string()}).nullable();

      expect(validator.validate(null), true);
      expect(validator.validate({'key': 'value'}), true);
      expect(validator.validate({}), false);
    });
  });

  group('validate nested fields', () {
    test('should validate nested fields correctly', () {
      final validator = v.map({
        'name': v.string().min(3),
        'age': v.int().min(18),
      });

      expect(validator.validate({'name': 'John', 'age': 25}), true);
      expect(validator.validate({'name': 'Jo', 'age': 25}), false);
      expect(validator.validate({'name': 'John', 'age': 16}), false);
    });
  });

  group('refine - confirm password', () {
    test('should validate password confirmation', () {
      final validator = v.map({
        'password': v.string().min(8),
        'confirmPassword': v.string()
      }).refine(
        (data) => data['password'] == data['confirmPassword'],
        path: 'confirmPassword',
      );

      expect(
        validator.validate({
          'password': 'password123',
          'confirmPassword': 'password123',
        }),
        true,
      );
      expect(
        validator.validate({
          'password': 'password123',
          'confirmPassword': 'pass123',
        }),
        false,
      );
    });
  });

  group('refine - custom validation', () {
    test('should validate custom logic', () {
      final validator = v.map({
        'email': v.string().email(),
        'password': v.string().min(8).max(20),
        'confirmPassword': v.string().min(8).max(20),
      }).refine(
        (data) => data['password'] == data['confirmPassword'],
        path: 'confirmPassword',
        message: 'The passwords are not the same',
      );

      expect(
        validator.validate({
          'email': 'user@company.com',
          'password': '12345678',
          'confirmPassword': '12345678',
        }),
        true,
      );
      expect(
        validator.validate({
          'email': 'user@company.com',
          'password': '12345678',
          'confirmPassword': '123456789',
        }),
        false,
      );
    });
  });

  group('validate multiple errors', () {
    test('should return multiple validation errors', () {
      final validator = v.map({
        'email': v.string().email(),
        'age': v.int().min(18),
      });

      final result = validator.getErrorMessage({
        'email': 'invalid-email',
        'age': 16,
      });

      expect(result, {
        'email': 'Enter a valid email',
        'age': 'The number must be at least 18',
      });
    });
  });

  group('validate missing required fields', () {
    test('should return errors for missing required fields', () {
      final validator = v.map({
        'email': v.string().email(),
        'age': v.int().min(18),
      });

      final result = validator.getErrorMessage({});

      expect(result, {'email': 'Required', 'age': 'Required'});
    });
  });

  group('object', () {
    test('should maintain the same number of keys as the original map', () {
      final validator = v.map({
        'email': v.string().email(),
        'age': v.int().min(18),
      });

      expect(validator.object.length, 2);
    });
  });
}
