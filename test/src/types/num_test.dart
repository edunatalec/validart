import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.num();

      expect(validator.validate(10), true);
      expect(validator.validate(0), true);
      expect(validator.validate(-5), true);
      expect(validator.validate(null), false);
    });
  });

  group('min', () {
    test('should validate minimum value', () {
      final validator = k.num().min(5);

      expect(validator.validate(4), false);
      expect(validator.validate(5), true);
      expect(validator.validate(10), true);
    });
  });

  group('max', () {
    test('should validate maximum value', () {
      final validator = k.num().max(10);

      expect(validator.validate(11), false);
      expect(validator.validate(10), true);
      expect(validator.validate(5), true);
    });
  });

  group('positive', () {
    test('should validate positive numbers', () {
      final validator = k.num().positive();

      expect(validator.validate(1), true);
      expect(validator.validate(0), false);
      expect(validator.validate(-1), false);
    });
  });

  group('negative', () {
    test('should validate negative numbers', () {
      final validator = k.num().negative();

      expect(validator.validate(-1), true);
      expect(validator.validate(0), false);
      expect(validator.validate(1), false);
    });
  });

  group('between', () {
    test('should validate number range', () {
      final validator = k.num().between(5, 10);

      expect(validator.validate(4), false);
      expect(validator.validate(5), true);
      expect(validator.validate(7), true);
      expect(validator.validate(10), true);
      expect(validator.validate(11), false);
    });
  });

  group('multipleOf', () {
    test('should validate multiples of a number', () {
      final validator = k.num().multipleOf(3);

      expect(validator.validate(6), true);
      expect(validator.validate(9), true);
      expect(validator.validate(7), false);
    });
  });

  group('nullable', () {
    test('should allow null values when nullable', () {
      final validator = k.num().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate(10), true);
    });
  });

  group('optional', () {
    test('should allow skipping optional values', () {
      final validator = k.num().optional();

      expect(validator.validate(5), true);
      expect(validator.validate(null), false);
    });
  });

  group('refine', () {
    test('should validate custom refine function', () {
      final validator = k.num().refine((data) => data! > 100);

      expect(validator.validate(200), true);
      expect(validator.validate(50), false);
    });
  });
}
