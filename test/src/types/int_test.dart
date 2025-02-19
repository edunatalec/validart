import 'package:validart/validart.dart';
import 'package:test/test.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.int();

      expect(validator.validate(1), true);
      expect(validator.validate(0), true);
      expect(validator.validate(null), false);
    });
  });

  group('min', () {
    test('should validate min correctly', () {
      final validator = v.int().min(10);

      expect(validator.validate(9), false);
      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
    });
  });

  group('max', () {
    test('should validate max correctly', () {
      final validator = v.int().max(20);

      expect(validator.validate(25), false);
      expect(validator.validate(20), true);
      expect(validator.validate(15), true);
    });
  });

  group('positive', () {
    test('should validate positive numbers', () {
      final validator = v.int().positive();

      expect(validator.validate(5), true);
      expect(validator.validate(0), false);
      expect(validator.validate(-5), false);
    });
  });

  group('negative', () {
    test('should validate negative numbers', () {
      final validator = v.int().negative();

      expect(validator.validate(-5), true);
      expect(validator.validate(0), false);
      expect(validator.validate(5), false);
    });
  });

  group('between', () {
    test('should validate numbers within range', () {
      final validator = v.int().between(10, 20);

      expect(validator.validate(9), false);
      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
      expect(validator.validate(20), true);
      expect(validator.validate(21), false);
    });
  });

  group('multipleOf', () {
    test('should validate multiples correctly', () {
      final validator = v.int().multipleOf(5);

      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
      expect(validator.validate(3), false);
    });
  });

  group('even', () {
    test('should validate even numbers', () {
      final validator = v.int().even();

      expect(validator.validate(2), true);
      expect(validator.validate(4), true);
      expect(validator.validate(1), false);
      expect(validator.validate(3), false);
    });
  });

  group('odd', () {
    test('should validate odd numbers', () {
      final validator = v.int().odd();

      expect(validator.validate(1), true);
      expect(validator.validate(3), true);
      expect(validator.validate(2), false);
      expect(validator.validate(4), false);
    });
  });

  group('prime', () {
    test('should validate prime numbers correctly', () {
      final validator = v.int().prime();

      expect(validator.validate(2), true);
      expect(validator.validate(3), true);
      expect(validator.validate(5), true);
      expect(validator.validate(7), true);
      expect(validator.validate(11), true);
      expect(validator.validate(13), true);

      expect(validator.validate(1), false);
      expect(validator.validate(4), false);
      expect(validator.validate(6), false);
      expect(validator.validate(8), false);
      expect(validator.validate(9), false);
      expect(validator.validate(10), false);
      expect(validator.validate(15), false);
      expect(validator.validate(20), false);
      expect(validator.validate(25), false);
      expect(validator.validate(100), false);
    });
  });

  group('nullable', () {
    test('should validate nullable values', () {
      final validator = v.int().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate(5), true);
    });
  });

  group('optional', () {
    test('should validate nullable values', () {
      final validator = v.int().optional();

      expect(validator.validate(5), true);
      expect(validator.validate(null), false);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = v.int().every([
        v.int().min(5),
        v.int().max(10),
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
      final validator = v.int().any([
        v.int().min(10),
        v.int().max(100),
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
      final validator = v.int().refine((data) => data > 10);

      expect(validator.validate(15), true);
      expect(validator.validate(10), false);
    });
  });
}
