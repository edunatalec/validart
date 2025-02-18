import 'package:validart/validart.dart';
import 'package:test/test.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.num();

      expect(validator.validate(10), true);
      expect(validator.validate(0), true);
      expect(validator.validate(-5), true);
      expect(validator.validate(null), false);
    });
  });

  group('min', () {
    test('should validate minimum value', () {
      final validator = v.num().min(5);

      expect(validator.validate(4), false);
      expect(validator.validate(5), true);
      expect(validator.validate(10), true);
    });
  });

  group('max', () {
    test('should validate maximum value', () {
      final validator = v.num().max(10);

      expect(validator.validate(11), false);
      expect(validator.validate(10), true);
      expect(validator.validate(5), true);
    });
  });

  group('positive', () {
    test('should validate positive numbers', () {
      final validator = v.num().positive();

      expect(validator.validate(1), true);
      expect(validator.validate(0), false);
      expect(validator.validate(-1), false);
    });
  });

  group('negative', () {
    test('should validate negative numbers', () {
      final validator = v.num().negative();

      expect(validator.validate(-1), true);
      expect(validator.validate(0), false);
      expect(validator.validate(1), false);
    });
  });

  group('between', () {
    test('should validate number range', () {
      final validator = v.num().between(5, 10);

      expect(validator.validate(4), false);
      expect(validator.validate(5), true);
      expect(validator.validate(7), true);
      expect(validator.validate(10), true);
      expect(validator.validate(11), false);
    });
  });

  group('multipleOf', () {
    test('should validate multiples of a number', () {
      final validator = v.num().multipleOf(3);

      expect(validator.validate(6), true);
      expect(validator.validate(9), true);
      expect(validator.validate(7), false);
    });
  });

  group('nullable', () {
    test('should allow null values when nullable', () {
      final validator = v.num().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate(10), true);
    });
  });

  group('optional', () {
    test('should allow skipping optional values', () {
      final validator = v.num().optional();

      expect(validator.validate(5), true);
      expect(validator.validate(null), false);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = v.num().every([
        v.num().min(5),
        v.num().max(10),
      ]);

      expect(validator.validate(5), true);
      expect(validator.validate(6), true);
      expect(validator.validate(10), true);
      expect(validator.validate(11), false);
      expect(validator.validate(null), false);
    });
  });

  group('any', () {
    test('should pass if at least one validator passes', () {
      final validator = v.num().any([
        v.num().min(10),
        v.num().max(100),
      ]);

      expect(validator.validate(10), true);
      expect(validator.validate(11), true);
      expect(validator.validate(99), true);
      expect(validator.validate(100), true);
      expect(validator.validate(101), true);
    });
  });

  group('refine', () {
    test('should validate custom refine function', () {
      final validator = v.num().refine((data) => data > 100);

      expect(validator.validate(200), true);
      expect(validator.validate(50), false);
    });
  });
}
