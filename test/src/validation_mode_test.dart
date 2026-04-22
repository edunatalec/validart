import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  group('ValidationMode', () {
    test('exposes three variants', () {
      expect(ValidationMode.values, hasLength(3));
      expect(ValidationMode.values, contains(ValidationMode.any));
      expect(ValidationMode.values, contains(ValidationMode.formatted));
      expect(ValidationMode.values, contains(ValidationMode.unformatted));
    });

    test('variants are distinct', () {
      expect(ValidationMode.any, isNot(equals(ValidationMode.formatted)));
      expect(ValidationMode.any, isNot(equals(ValidationMode.unformatted)));

      expect(
        ValidationMode.formatted,
        isNot(equals(ValidationMode.unformatted)),
      );
    });
  });
}
