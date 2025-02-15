import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.bool();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), false);
    });
  });

  group('isTrue', () {
    test('should validate isTrue correctly', () {
      final validator = k.bool().isTrue();

      expect(validator.validate(true), true);
      expect(validator.validate(false), false);
      expect(validator.validate(null), false);
    });
  });

  group('isFalse', () {
    test('should validate isFalse correctly', () {
      final validator = k.bool().isFalse();

      expect(validator.validate(false), true);
      expect(validator.validate(true), false);
      expect(validator.validate(null), false);
    });
  });

  group('nullable', () {
    test('should validate nullable correctly', () {
      final validator = k.bool().nullable();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), true);
    });
  });

  group('optional', () {
    test('should validate optional correctly', () {
      final validator = k.bool().optional();

      expect(validator.validate(true), true);
      expect(validator.validate(false), true);
      expect(validator.validate(null), false);
    });
  });

  group('refine', () {
    test('should validate refine function correctly', () {
      final validator = k.bool().refine(
        (value) => value == true,
        message: 'The value must be true.',
      );

      expect(validator.validate(true), true);
      expect(validator.validate(false), false);
      expect(validator.validate(null), false);
    });
  });
}
