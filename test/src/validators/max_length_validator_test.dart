import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  group('MaxLengthValidator - ArgumentError Tests', () {
    test('Throws ArgumentError when used with an invalid type', () {
      final validator = MaxLengthValidator<int>(5, message: 'Invalid type');

      expect(
        () => validator.validate(123),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws ArgumentError when used with a Map', () {
      final validator = MaxLengthValidator<Map>(3, message: 'Invalid type');

      expect(
        () => validator.validate({'key1': 'value1', 'key2': 'value2'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws ArgumentError when used with a double', () {
      final validator = MaxLengthValidator<double>(4, message: 'Invalid type');

      expect(
        () => validator.validate(12.34),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
