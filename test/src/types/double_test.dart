import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.double();

      expect(validator.validate(1.0), true);
      expect(validator.validate(0.0), true);
      expect(validator.validate(null), false);
    });
  });

  group('min', () {
    test('should validate minimum value correctly', () {
      final validator = k.double().min(10.5);

      expect(validator.validate(10.5), true);
      expect(validator.validate(11.0), true);
      expect(validator.validate(9.9), false);
    });
  });

  group('max', () {
    test('should validate maximum value correctly', () {
      final validator = k.double().max(100.0);

      expect(validator.validate(99.9), true);
      expect(validator.validate(100.0), true);
      expect(validator.validate(100.1), false);
    });
  });

  group('between', () {
    test('should validate range correctly', () {
      final validator = k.double().between(10.0, 20.0);

      expect(validator.validate(10.0), true);
      expect(validator.validate(15.5), true);
      expect(validator.validate(20.0), true);
      expect(validator.validate(9.9), false);
      expect(validator.validate(20.1), false);
    });
  });

  group('multipleOf', () {
    test('should validate multiples correctly', () {
      final validator = k.double().multipleOf(2.5);

      expect(validator.validate(5.0), true);
      expect(validator.validate(7.5), true);
      expect(validator.validate(3.0), false);
    });
  });

  group('positive', () {
    test('should validate positive numbers correctly', () {
      final validator = k.double().positive();

      expect(validator.validate(1.0), true);
      expect(validator.validate(100.5), true);
      expect(validator.validate(0.0), false);
      expect(validator.validate(-1.0), false);
    });
  });

  group('negative', () {
    test('should validate negative numbers correctly', () {
      final validator = k.double().negative();

      expect(validator.validate(-1.0), true);
      expect(validator.validate(-100.5), true);
      expect(validator.validate(0.0), false);
      expect(validator.validate(1.0), false);
    });
  });

  group('finite', () {
    test('should validate finite numbers correctly', () {
      final validator = k.double().finite();

      expect(validator.validate(1.0), true);
      expect(validator.validate(-1.0), true);
      expect(validator.validate(double.infinity), false);
      expect(validator.validate(double.negativeInfinity), false);
      expect(validator.validate(double.nan), false);
    });
  });

  group('decimal', () {
    test('should validate decimal numbers correctly', () {
      final validator = k.double().decimal();

      expect(validator.validate(1.5), true);
      expect(validator.validate(10.25), true);
      expect(validator.validate(100.0), false);
    });
  });

  group('integer', () {
    test('should validate integer values correctly', () {
      final validator = k.double().integer();

      expect(validator.validate(10.0), true);
      expect(validator.validate(0.0), true);
      expect(validator.validate(15.5), false);
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = k.double().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate(10.5), true);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = k.double().optional();

      expect(validator.validate(10.5), true);
      expect(validator.validate(null), false);
    });
  });

  group('refine', () {
    test('should validate refine function correctly', () {
      final validator = k.double().refine(
        (value) => value! > 10.0,
        message: 'The value must be greater than 10.',
      );

      expect(validator.validate(15.0), true);
      expect(validator.validate(10.0), false);
    });
  });
}
