import 'package:validart/validart.dart';
import 'package:test/test.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.bool();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), false);
    });
  });

  group('isTrue', () {
    test('should validate isTrue correctly', () {
      final validator = v.bool().isTrue();

      expect(validator.validate(true), true);
      expect(validator.validate(false), false);
      expect(validator.validate(null), false);
    });
  });

  group('isFalse', () {
    test('should validate isFalse correctly', () {
      final validator = v.bool().isFalse();

      expect(validator.validate(false), true);
      expect(validator.validate(true), false);
      expect(validator.validate(null), false);
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = v.bool().nullable();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), true);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = v.bool().optional();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), false);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = v.bool().every([
        v.bool().isFalse(),
      ]);

      expect(validator.validate(false), true);
      expect(validator.validate(true), false);
      expect(validator.validate(null), false);
    });
  });

  group('any', () {
    test('should pass if at least one validator passes', () {
      final validator = v.bool().any([
        v.bool().isFalse(),
        v.bool().isTrue(),
      ]);

      expect(validator.validate(false), true);
      expect(validator.validate(true), true);
      expect(validator.validate(null), false);
    });
  });

  group('refine', () {
    test('should validate refine function correctly', () {
      final validator = v.bool().refine(
        (value) => value == true,
        message: 'The value must be true.',
      );

      expect(validator.validate(true), true);
      expect(validator.validate(false), false);
      expect(validator.validate(null), false);
    });
  });
}
