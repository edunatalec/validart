import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.map({'key': k.string()});

      expect(validator.validate({'key': 'value'}), true);
      expect(validator.validate({}), false);
      expect(validator.validate(null), false);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = k.map({'key': k.string()}).optional();

      expect(validator.validate({}), true);
      expect(validator.validate(null), false);
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = k.map({'key': k.string()}).nullable();

      expect(validator.validate(null), true);
      expect(validator.validate({'key': 'value'}), true);
      expect(validator.validate({}), false);
    });
  });

  group('validate nested fields', () {
    test('should validate nested fields correctly', () {
      final validator = k.map({
        'name': k.string().min(3),
        'age': k.int().min(18),
      });

      expect(validator.validate({'name': 'John', 'age': 25}), true);
      expect(validator.validate({'name': 'Jo', 'age': 25}), false);
      expect(validator.validate({'name': 'John', 'age': 16}), false);
    });
  });

  group('refine - confirm password', () {
    test('should validate password confirmation', () {
      final validator = k
          .map({'password': k.string().min(8), 'confirmPassword': k.string()})
          .refine(
            (data) => data!['password'] == data['confirmPassword'],
            path: 'confirmPassword',
            message: 'Passwords do not match',
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
      final validator = k
          .map({
            'email': k.string().email(),
            'password': k.string().min(8).max(20),
            'confirmPassword': k.string().min(8).max(20),
          })
          .refine(
            (data) => data?['password'] == data?['confirmPassword'],
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
      final validator = k.map({
        'email': k.string().email(),
        'age': k.int().min(18),
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
      final validator = k.map({
        'email': k.string().email(),
        'age': k.int().min(18),
      });

      final result = validator.getErrorMessage({});

      expect(result, {'email': 'Required', 'age': 'Required'});
    });
  });
}
