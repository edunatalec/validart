import 'package:test/test.dart';
import 'package:validart/src/extensions/string_extensions.dart';

void main() {
  group('onlyDigits', () {
    test('should remove all non-digit characters', () {
      expect('Phone: +1 (123) 456-7890'.onlyDigits, '11234567890');
      expect('CPF: 123.456.789-09'.onlyDigits, '12345678909');
      expect('CNPJ: 12.345.678/0001-95'.onlyDigits, '12345678000195');
      expect('Random Text 9876'.onlyDigits, '9876');
      expect('100% Valid!'.onlyDigits, '100');
    });

    test('should return empty string when no digits are present', () {
      expect('No Numbers!'.onlyDigits, '');
      expect('###'.onlyDigits, '');
      expect('abcDEF'.onlyDigits, '');
    });

    test('should return the same string if it only contains digits', () {
      expect('123456789'.onlyDigits, '123456789');
      expect('00000'.onlyDigits, '00000');
    });
  });

  group('isRepeatedCharacters', () {
    test(
      'should return true for strings with only one unique repeated character',
      () {
        expect('111111'.isRepeatedCharacters, true);
        expect('00000000000'.isRepeatedCharacters, true);
        expect('aaaaa'.isRepeatedCharacters, true);
        expect('BBBBBB'.isRepeatedCharacters, true);
      },
    );

    test('should return false for strings with mixed characters', () {
      expect('abcdef'.isRepeatedCharacters, false);
      expect('aaaBBB'.isRepeatedCharacters, false);
      expect('123456'.isRepeatedCharacters, false);
      expect('00001'.isRepeatedCharacters, false);
    });

    test('should return false for empty string', () {
      expect(''.isRepeatedCharacters, false);
    });

    test('should return true for single-character strings', () {
      expect('a'.isRepeatedCharacters, true);
      expect('1'.isRepeatedCharacters, true);
      expect('#'.isRepeatedCharacters, true);
    });
  });
}
