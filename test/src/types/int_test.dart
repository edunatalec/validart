import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.int();

      expect(validator.validate(1), true);
      expect(validator.validate(0), true);
      expect(validator.validate(null), false);
    });
  });

  group('min', () {
    test('should validate min correctly', () {
      final validator = k.int().min(10);

      expect(validator.validate(9), false);
      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
    });
  });

  group('max', () {
    test('should validate max correctly', () {
      final validator = k.int().max(20);

      expect(validator.validate(25), false);
      expect(validator.validate(20), true);
      expect(validator.validate(15), true);
    });
  });

  group('positive', () {
    test('should validate positive numbers', () {
      final validator = k.int().positive();

      expect(validator.validate(5), true);
      expect(validator.validate(0), false);
      expect(validator.validate(-5), false);
    });
  });

  group('negative', () {
    test('should validate negative numbers', () {
      final validator = k.int().negative();

      expect(validator.validate(-5), true);
      expect(validator.validate(0), false);
      expect(validator.validate(5), false);
    });
  });

  group('between', () {
    test('should validate numbers within range', () {
      final validator = k.int().between(10, 20);

      expect(validator.validate(9), false);
      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
      expect(validator.validate(20), true);
      expect(validator.validate(21), false);
    });
  });

  group('multipleOf', () {
    test('should validate multiples correctly', () {
      final validator = k.int().multipleOf(5);

      expect(validator.validate(10), true);
      expect(validator.validate(15), true);
      expect(validator.validate(3), false);
    });
  });

  group('even', () {
    test('should validate even numbers', () {
      final validator = k.int().even();

      expect(validator.validate(2), true);
      expect(validator.validate(4), true);
      expect(validator.validate(1), false);
      expect(validator.validate(3), false);
    });
  });

  group('odd', () {
    test('should validate odd numbers', () {
      final validator = k.int().odd();

      expect(validator.validate(1), true);
      expect(validator.validate(3), true);
      expect(validator.validate(2), false);
      expect(validator.validate(4), false);
    });
  });

  group('nullable', () {
    test('should validate nullable values', () {
      final validator = k.int().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate(5), true);
    });
  });

  group('refine', () {
    test('should validate custom refine function', () {
      final validator = k.int().refine((data) => data! > 10);

      expect(validator.validate(15), true);
      expect(validator.validate(10), false);
    });
  });
}
