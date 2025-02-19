import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  group('MinLengthValidator - ArgumentError Tests', () {
    test('Throws ArgumentError when used with an invalid type', () {
      final validator = MinLengthValidator<int>(3, message: 'Invalid type');

      expect(
        () => validator.validate(123),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws ArgumentError when used with a Map', () {
      final validator = MinLengthValidator<Map>(2, message: 'Invalid type');

      expect(
        () => validator.validate({'key': 'value'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Throws ArgumentError when used with a double', () {
      final validator = MinLengthValidator<double>(3, message: 'Invalid type');

      expect(
        () => validator.validate(12.34),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
