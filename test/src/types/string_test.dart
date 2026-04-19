import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';
import 'package:validart/src/validators/string/card_brand_pattern.dart';
import 'package:validart/src/validators/string/phone_pattern.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VString', () {
    group('min', () {
      test('should pass when string length >= min', () {
        final schema = VString().min(3);
        expect(schema.validate('abc'), isTrue);
      });

      test('should pass when string length > min', () {
        final schema = VString().min(3);
        expect(schema.validate('abcd'), isTrue);
      });

      test('should fail when string length < min', () {
        final schema = VString().min(3);
        expect(schema.validate('ab'), isFalse);
      });

      test('should fail when string is empty', () {
        final schema = VString().min(1);
        expect(schema.validate(''), isFalse);
      });

      test('should return error code too_small', () {
        final schema = VString().min(3);
        final errors = schema.errors('ab');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'string.too_small');
      });

      test('should support custom message', () {
        final schema = VString().min(3, message: (len) => 'At least $len');
        final errors = schema.errors('ab');
        expect(errors!.first.message, 'At least 3');
      });
    });

    group('max', () {
      test('should pass when string length <= max', () {
        final schema = VString().max(5);
        expect(schema.validate('hello'), isTrue);
      });

      test('should pass when string length < max', () {
        final schema = VString().max(5);
        expect(schema.validate('hi'), isTrue);
      });

      test('should fail when string length > max', () {
        final schema = VString().max(5);
        expect(schema.validate('toolong'), isFalse);
      });

      test('should return error code too_big', () {
        final schema = VString().max(3);
        final errors = schema.errors('abcd');
        expect(errors!.first.code, 'string.too_big');
      });

      test('should support custom message', () {
        final schema = VString().max(3, message: (len) => 'Max $len');
        final errors = schema.errors('abcd');
        expect(errors!.first.message, 'Max 3');
      });
    });

    group('length', () {
      test('should pass when string has exact length', () {
        final schema = VString().length(4);
        expect(schema.validate('abcd'), isTrue);
      });

      test('should fail when string is shorter', () {
        final schema = VString().length(4);
        expect(schema.validate('abc'), isFalse);
      });

      test('should fail when string is longer', () {
        final schema = VString().length(4);
        expect(schema.validate('abcde'), isFalse);
      });

      test('should return error code length', () {
        final schema = VString().length(4);
        final errors = schema.errors('ab');
        expect(errors!.first.code, 'string.length');
      });

      test('should support custom message', () {
        final schema = VString().length(4, message: (len) => 'Need $len');
        final errors = schema.errors('ab');
        expect(errors!.first.message, 'Need 4');
      });
    });

    group('email', () {
      final schema = VString().email();

      test('should pass for valid email', () {
        expect(schema.validate('user@example.com'), isTrue);
      });

      test('should pass for email with plus tag', () {
        expect(schema.validate('user+tag@example.com'), isTrue);
      });

      test('should fail for missing @', () {
        expect(schema.validate('userexample.com'), isFalse);
      });

      test('should fail for missing domain', () {
        expect(schema.validate('user@'), isFalse);
      });

      test('should fail for double dots', () {
        expect(schema.validate('user..name@example.com'), isFalse);
      });

      test('should return error code invalid_email', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_email');
      });

      test('should support custom message', () {
        final custom = VString().email(message: 'Bad email');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad email');
      });
    });

    group('url', () {
      final schema = VString().url();

      test('should pass for valid http url', () {
        expect(schema.validate('http://example.com'), isTrue);
      });

      test('should pass for valid https url', () {
        expect(schema.validate('https://example.com/path?q=1'), isTrue);
      });

      test('should fail for missing protocol', () {
        expect(schema.validate('example.com'), isFalse);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should return error code invalid_url', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_url');
      });

      test('should support custom message', () {
        final custom = VString().url(message: 'Bad url');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad url');
      });
    });

    group('uuid', () {
      final schema = VString().uuid();

      test('should pass for valid uuid v4', () {
        expect(schema.validate('550e8400-e29b-41d4-a716-446655440000'), isTrue);
      });

      test('should fail for invalid uuid', () {
        expect(schema.validate('not-a-uuid'), isFalse);
      });

      test('should fail for uuid missing dashes', () {
        expect(schema.validate('550e8400e29b41d4a716446655440000'), isFalse);
      });

      test('should return error code invalid_uuid', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_uuid');
      });

      test('should support custom message', () {
        final custom = VString().uuid(message: 'Bad uuid');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad uuid');
      });
    });

    group('ip', () {
      final schema = VString().ip();

      test('should pass for valid IPv4', () {
        expect(schema.validate('192.168.1.1'), isTrue);
      });

      test('should pass for valid IPv6', () {
        expect(
          schema.validate('2001:0db8:85a3:0000:0000:8a2e:0370:7334'),
          isTrue,
        );
      });

      test('should fail for invalid IP', () {
        expect(schema.validate('999.999.999.999'), isFalse);
      });

      test('should fail for random string', () {
        expect(schema.validate('not-an-ip'), isFalse);
      });

      test('should return error code invalid_ip', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_ip');
      });

      test('should support custom message', () {
        final custom = VString().ip(message: 'Bad ip');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad ip');
      });
    });

    group('pattern', () {
      test('should pass when value matches regex', () {
        final schema = VString().pattern(r'^\d{3}$');
        expect(schema.validate('123'), isTrue);
      });

      test('should fail when value does not match regex', () {
        final schema = VString().pattern(r'^\d{3}$');
        expect(schema.validate('abc'), isFalse);
      });

      test('should return error code invalid_format', () {
        final schema = VString().pattern(r'^\d+$');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'invalid_format');
      });

      test('should support custom message', () {
        final schema = VString().pattern(r'^\d+$', message: 'Numbers only');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Numbers only');
      });
    });

    group('date', () {
      final schema = VString().date();
      final br = VString().date(format: 'DD/MM/YYYY');
      final us = VString().date(format: 'MM/DD/YYYY');
      final iso = VString().date(format: 'YYYY-MM-DD');
      final eu = VString().date(format: 'DD.MM.YYYY');

      test('should pass for valid ISO date', () {
        expect(schema.validate('2024-01-15'), isTrue);
      });

      test('should pass for valid date edge cases', () {
        expect(schema.validate('2024-12-31'), isTrue);
      });

      test('should fail for invalid month', () {
        expect(schema.validate('2024-13-01'), isFalse);
      });

      test('should fail for invalid day', () {
        expect(schema.validate('2024-01-32'), isFalse);
      });

      test('should fail for incomplete format', () {
        expect(schema.validate('01/15'), isFalse);
      });

      test('should pass for BR format (DD/MM/YYYY)', () {
        expect(schema.validate('15/01/2024'), isTrue);
      });

      test('should pass for US format (MM/DD/YYYY)', () {
        expect(schema.validate('01/15/2024'), isTrue);
      });

      test('should pass for EU format (DD.MM.YYYY)', () {
        expect(schema.validate('15.01.2024'), isTrue);
      });

      test('should pass for ISO basic (YYYYMMDD)', () {
        expect(schema.validate('20240115'), isTrue);
      });

      test('should pass for ambiguous BR/US date', () {
        expect(schema.validate('02/03/2020'), isTrue);
      });

      test('should fail when no format interprets calendar-validly', () {
        expect(schema.validate('30/02/2020'), isFalse);
      });

      test('should return error code invalid_date', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_date');
      });

      test('should support custom message', () {
        final custom = VString().date(message: 'Bad date');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad date');
      });

      test('should fail for calendar-invalid February 30', () {
        expect(schema.validate('2024-02-30'), isFalse);
      });

      test('should fail for calendar-invalid April 31', () {
        expect(schema.validate('2024-04-31'), isFalse);
      });

      test('should fail for Feb 29 on non-leap year', () {
        expect(schema.validate('2023-02-29'), isFalse);
      });

      test('should pass for Feb 29 on leap year', () {
        expect(schema.validate('2024-02-29'), isTrue);
      });

      test('should fail for date with time component', () {
        expect(schema.validate('2024-01-15T10:30:00'), isFalse);
      });

      test('should fail for date with space time', () {
        expect(schema.validate('2024-01-15 10:30'), isFalse);
      });

      test('should pass with strict format DD/MM/YYYY', () {
        expect(br.validate('15/01/2024'), isTrue);
      });

      test('should fail with strict DD/MM/YYYY for ISO input', () {
        expect(br.validate('2024-01-15'), isFalse);
      });

      test('should pass with strict MM/DD/YYYY for US input', () {
        expect(us.validate('01/15/2024'), isTrue);
      });

      test('should fail with strict MM/DD/YYYY for invalid month', () {
        expect(us.validate('15/01/2024'), isFalse);
      });

      test('should pass with strict YYYY-MM-DD', () {
        expect(iso.validate('2024-01-15'), isTrue);
      });

      test('should fail with strict YYYY-MM-DD for BR input', () {
        expect(iso.validate('15/01/2024'), isFalse);
      });

      test('should fail with strict DD/MM/YYYY for calendar-invalid', () {
        expect(br.validate('31/02/2024'), isFalse);
      });

      test('should pass with strict DD.MM.YYYY', () {
        expect(eu.validate('15.01.2024'), isTrue);
      });
    });

    group('time', () {
      final schema = VString().time();

      test('should pass for HH:MM format', () {
        expect(schema.validate('14:30'), isTrue);
      });

      test('should pass for HH:MM:SS format', () {
        expect(schema.validate('14:30:59'), isTrue);
      });

      test('should pass for midnight', () {
        expect(schema.validate('00:00'), isTrue);
      });

      test('should fail for invalid hour', () {
        expect(schema.validate('25:00'), isFalse);
      });

      test('should fail for invalid minute', () {
        expect(schema.validate('12:60'), isFalse);
      });

      test('should fail for random string', () {
        expect(schema.validate('not-time'), isFalse);
      });

      test('should return error code invalid_time', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_time');
      });

      test('should support custom message', () {
        final custom = VString().time(message: 'Bad time');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad time');
      });
    });

    group('contains', () {
      test('should pass when string contains value', () {
        final schema = VString().contains('world');
        expect(schema.validate('hello world'), isTrue);
      });

      test('should fail when string does not contain value', () {
        final schema = VString().contains('world');
        expect(schema.validate('hello'), isFalse);
      });

      test('should return error code contains', () {
        final schema = VString().contains('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'contains');
      });

      test('should support custom message', () {
        final schema = VString().contains('x', message: 'Must have x');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must have x');
      });
    });

    group('startsWith', () {
      test('should pass when string starts with prefix', () {
        final schema = VString().startsWith('hello');
        expect(schema.validate('hello world'), isTrue);
      });

      test('should fail when string does not start with prefix', () {
        final schema = VString().startsWith('hello');
        expect(schema.validate('world hello'), isFalse);
      });

      test('should return error code starts_with', () {
        final schema = VString().startsWith('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'starts_with');
      });

      test('should support custom message', () {
        final schema = VString().startsWith('x', message: 'Must start with x');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must start with x');
      });
    });

    group('endsWith', () {
      test('should pass when string ends with suffix', () {
        final schema = VString().endsWith('.dart');
        expect(schema.validate('main.dart'), isTrue);
      });

      test('should fail when string does not end with suffix', () {
        final schema = VString().endsWith('.dart');
        expect(schema.validate('main.js'), isFalse);
      });

      test('should return error code ends_with', () {
        final schema = VString().endsWith('z');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'ends_with');
      });

      test('should support custom message', () {
        final schema = VString().endsWith('z', message: 'Must end with z');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must end with z');
      });
    });

    group('equals', () {
      test('should pass when string equals value', () {
        final schema = VString().equals('exact');
        expect(schema.validate('exact'), isTrue);
      });

      test('should fail when string does not equal value', () {
        final schema = VString().equals('exact');
        expect(schema.validate('other'), isFalse);
      });

      test('should be case sensitive', () {
        final schema = VString().equals('Hello');
        expect(schema.validate('hello'), isFalse);
      });

      test('should return error code equals', () {
        final schema = VString().equals('x');
        final errors = schema.errors('y');
        expect(errors!.first.code, 'equals');
      });

      test('should support custom message', () {
        final schema = VString().equals('x', message: 'Must be x');
        final errors = schema.errors('y');
        expect(errors!.first.message, 'Must be x');
      });
    });

    group('alpha', () {
      final schema = VString().alpha();

      test('should pass for only letters', () {
        expect(schema.validate('abcXYZ'), isTrue);
      });

      test('should fail for string with numbers', () {
        expect(schema.validate('abc123'), isFalse);
      });

      test('should fail for string with spaces', () {
        expect(schema.validate('hello world'), isFalse);
      });

      test('should fail for string with special chars', () {
        expect(schema.validate('abc!'), isFalse);
      });

      test('should return error code alpha', () {
        final errors = schema.errors('123');
        expect(errors!.first.code, 'alpha');
      });

      test('should support custom message', () {
        final custom = VString().alpha(message: 'Letters only');
        final errors = custom.errors('123');
        expect(errors!.first.message, 'Letters only');
      });
    });

    group('alphanumeric', () {
      final schema = VString().alphanumeric();

      test('should pass for letters and numbers', () {
        expect(schema.validate('abc123'), isTrue);
      });

      test('should pass for only letters', () {
        expect(schema.validate('abc'), isTrue);
      });

      test('should pass for only numbers', () {
        expect(schema.validate('123'), isTrue);
      });

      test('should fail for string with spaces', () {
        expect(schema.validate('abc 123'), isFalse);
      });

      test('should fail for string with special chars', () {
        expect(schema.validate('abc!@#'), isFalse);
      });

      test('should return error code alphanumeric', () {
        final errors = schema.errors('a b');
        expect(errors!.first.code, 'alphanumeric');
      });

      test('should support custom message', () {
        final custom = VString().alphanumeric(message: 'Alphanumeric only');
        final errors = custom.errors('a b');
        expect(errors!.first.message, 'Alphanumeric only');
      });
    });

    group('slug', () {
      final schema = VString().slug();

      test('should pass for valid slug', () {
        expect(schema.validate('hello-world'), isTrue);
      });

      test('should pass for single word slug', () {
        expect(schema.validate('hello'), isTrue);
      });

      test('should pass for slug with numbers', () {
        expect(schema.validate('post-123'), isTrue);
      });

      test('should fail for uppercase', () {
        expect(schema.validate('Hello-World'), isFalse);
      });

      test('should fail for spaces', () {
        expect(schema.validate('hello world'), isFalse);
      });

      test('should fail for leading hyphen', () {
        expect(schema.validate('-hello'), isFalse);
      });

      test('should fail for trailing hyphen', () {
        expect(schema.validate('hello-'), isFalse);
      });

      test('should return error code slug', () {
        final errors = schema.errors('NOT VALID');
        expect(errors!.first.code, 'slug');
      });

      test('should support custom message', () {
        final custom = VString().slug(message: 'Bad slug');
        final errors = custom.errors('NOT VALID');
        expect(errors!.first.message, 'Bad slug');
      });
    });

    group('password', () {
      final schema = VString().password();

      test('should pass for strong password', () {
        expect(schema.validate('Abcdef1!'), isTrue);
      });

      test('should fail for too short', () {
        expect(schema.validate('Ab1!'), isFalse);
      });

      test('should fail for no uppercase', () {
        expect(schema.validate('abcdef1!'), isFalse);
      });

      test('should fail for no lowercase', () {
        expect(schema.validate('ABCDEF1!'), isFalse);
      });

      test('should fail for no digit', () {
        expect(schema.validate('Abcdefg!'), isFalse);
      });

      test('should fail for no special character', () {
        expect(schema.validate('Abcdefg1'), isFalse);
      });

      test('should return error code password', () {
        final errors = schema.errors('weak');
        expect(errors!.first.code, 'password');
      });

      test('should support custom message', () {
        final custom = VString().password(message: 'Too weak');
        final errors = custom.errors('weak');
        expect(errors!.first.message, 'Too weak');
      });
    });

    group('jwt', () {
      final schema = VString().jwt();

      test('should pass for valid JWT', () {
        expect(
          schema.validate(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U',
          ),
          isTrue,
        );
      });

      test('should fail for missing part', () {
        expect(schema.validate('part1.part2'), isFalse);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should fail for random string', () {
        expect(schema.validate('not-a-jwt'), isFalse);
      });

      test('should return error code jwt', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'jwt');
      });

      test('should support custom message', () {
        final custom = VString().jwt(message: 'Bad JWT');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad JWT');
      });
    });

    group('card', () {
      final schema = VString().card();
      final visa = VString().card(brands: [const VisaBrand()]);
      final mastercard = VString().card(brands: [const MastercardBrand()]);
      final amex = VString().card(brands: [const AmexBrand()]);
      final diners = VString().card(brands: [const DinersBrand()]);
      final discover = VString().card(brands: [const DiscoverBrand()]);
      final jcb = VString().card(brands: [const JcbBrand()]);
      final visaOrMaster =
          VString().card(brands: [const VisaBrand(), const MastercardBrand()]);

      test('should pass for valid card number (Luhn)', () {
        expect(schema.validate('4532015112830366'), isTrue);
      });

      test('should pass for valid card with spaces', () {
        expect(schema.validate('4532 0151 1283 0366'), isTrue);
      });

      test('should fail for invalid card number', () {
        expect(schema.validate('1234567890123456'), isFalse);
      });

      test('should fail for too short number', () {
        expect(schema.validate('123'), isFalse);
      });

      test('should return error code card', () {
        final errors = schema.errors('1234567890123456');
        expect(errors!.first.code, 'card');
      });

      test('should support custom message', () {
        final custom = VString().card(message: 'Bad card');
        final errors = custom.errors('1234567890123456');
        expect(errors!.first.message, 'Bad card');
      });

      test('should accept Visa when brand is Visa', () {
        expect(visa.validate('4111111111111111'), isTrue);
      });

      test('should accept Visa with mask when brand is Visa', () {
        expect(visa.validate('4111 1111 1111 1111'), isTrue);
      });

      test('should reject Mastercard when brand is Visa', () {
        expect(visa.validate('5555555555554444'), isFalse);
      });

      test('should reject Visa when brand is Mastercard', () {
        expect(mastercard.validate('4111111111111111'), isFalse);
      });

      test('should accept Mastercard (51-55 range)', () {
        expect(mastercard.validate('5555555555554444'), isTrue);
      });

      test('should accept Mastercard (2221-2720 range)', () {
        expect(mastercard.validate('2223003122003222'), isTrue);
      });

      test('should accept Amex (34 prefix)', () {
        expect(amex.validate('378282246310005'), isTrue);
      });

      test('should accept Amex (37 prefix)', () {
        expect(amex.validate('371449635398431'), isTrue);
      });

      test('should reject Amex with 16 digits', () {
        expect(amex.validate('3400000000000001'), isFalse);
      });

      test('should accept Diners', () {
        expect(diners.validate('30569309025904'), isTrue);
      });

      test('should accept Discover', () {
        expect(discover.validate('6011111111111117'), isTrue);
      });

      test('should accept JCB', () {
        expect(jcb.validate('3530111333300000'), isTrue);
      });

      test('should accept when any of multiple brands matches', () {
        expect(visaOrMaster.validate('4111111111111111'), isTrue);
        expect(visaOrMaster.validate('5555555555554444'), isTrue);
      });

      test('should reject when none of multiple brands matches', () {
        expect(visaOrMaster.validate('378282246310005'), isFalse);
      });

      test('should reject when brand matches but Luhn fails', () {
        expect(visa.validate('4111111111111112'), isFalse);
      });

      test('should return error code card when brand does not match', () {
        final errors = visa.errors('5555555555554444');
        expect(errors!.first.code, 'card');
      });

      test('should accept any brand when brands is empty', () {
        final empty = VString().card(brands: []);
        expect(empty.validate('4111111111111111'), isTrue);
        expect(empty.validate('5555555555554444'), isTrue);
      });
    });

    group('phone', () {
      final schema = VString().phone();
      final fake = VString().phone(pattern: const _FakePhonePattern());

      test('should pass for valid E.164 phone', () {
        expect(schema.validate('+14155552671'), isTrue);
      });

      test('should pass for phone without +', () {
        expect(schema.validate('14155552671'), isTrue);
      });

      test('should fail for phone starting with 0', () {
        expect(schema.validate('014155552671'), isFalse);
      });

      test('should fail for letters in phone', () {
        expect(schema.validate('+1abc5552671'), isFalse);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should return error code invalid_phone', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_phone');
      });

      test('should support custom message', () {
        final custom = VString().phone(message: 'Bad phone');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad phone');
      });

      test('should accept a custom PhonePattern', () {
        expect(fake.validate('LOCAL:1234'), isTrue);
        expect(fake.validate('+5511987654321'), isFalse);
      });

      test('custom pattern drives the error code', () {
        final errors = fake.errors('bad');
        expect(errors!.first.code, 'invalid_phone_fake');
      });
    });

    group('trim', () {
      final schema = VString().trim();

      test('should trim whitespace from both ends', () {
        expect(schema.parse('  hello  '), 'hello');
      });

      test('should not modify string without whitespace', () {
        expect(schema.parse('hello'), 'hello');
      });
    });

    group('toLowerCase', () {
      final schema = VString().toLowerCase();

      test('should convert to lowercase', () {
        expect(schema.parse('HELLO'), 'hello');
      });

      test('should not modify already lowercase string', () {
        expect(schema.parse('hello'), 'hello');
      });
    });

    group('toUpperCase', () {
      final schema = VString().toUpperCase();

      test('should convert to uppercase', () {
        expect(schema.parse('hello'), 'HELLO');
      });

      test('should not modify already uppercase string', () {
        expect(schema.parse('HELLO'), 'HELLO');
      });
    });

    group('toPascalCase', () {
      final schema = VString().toPascalCase();

      test('should convert space-separated to PascalCase', () {
        expect(schema.parse('hello world'), 'HelloWorld');
      });

      test('should convert camelCase to PascalCase', () {
        expect(schema.parse('helloWorld'), 'HelloWorld');
      });

      test('should convert snake_case to PascalCase', () {
        expect(schema.parse('user_profile_id'), 'UserProfileId');
      });

      test('should convert SCREAMING_SNAKE_CASE to PascalCase', () {
        expect(schema.parse('HELLO_WORLD'), 'HelloWorld');
      });

      test('should convert kebab-case to PascalCase', () {
        expect(schema.parse('hello-world'), 'HelloWorld');
      });

      test('should split acronyms in XMLHttpRequest', () {
        expect(schema.parse('XMLHttpRequest'), 'XmlHttpRequest');
      });

      test('should keep digits as their own segment', () {
        expect(schema.parse('version2Alpha'), 'Version2Alpha');
      });

      test('should drop invalid characters', () {
        expect(schema.parse('hello@world!'), 'HelloWorld');
      });

      test('should collapse extra whitespace', () {
        expect(schema.parse('  foo   bar  '), 'FooBar');
      });

      test('should return empty string for empty input', () {
        expect(schema.parse(''), '');
      });

      test('should return empty string for input with only symbols', () {
        expect(schema.parse('!@#\$%'), '');
      });
    });

    group('toCamelCase', () {
      final schema = VString().toCamelCase();

      test('should convert PascalCase to camelCase', () {
        expect(schema.parse('HelloWorld'), 'helloWorld');
      });

      test('should convert snake_case to camelCase', () {
        expect(schema.parse('hello_world'), 'helloWorld');
      });

      test('should convert SCREAMING_SNAKE_CASE to camelCase', () {
        expect(schema.parse('HELLO_WORLD'), 'helloWorld');
      });

      test('should convert kebab-case to camelCase', () {
        expect(schema.parse('user-profile-id'), 'userProfileId');
      });

      test('should convert space-separated to camelCase', () {
        expect(schema.parse('hello world foo bar'), 'helloWorldFooBar');
      });

      test('should split acronym in XMLHttpRequest', () {
        expect(schema.parse('XMLHttpRequest'), 'xmlHttpRequest');
      });

      test('should handle mixed separators', () {
        expect(schema.parse('Hello_world-foo bar'), 'helloWorldFooBar');
      });

      test('should drop invalid characters', () {
        expect(schema.parse('hello@world!'), 'helloWorld');
      });

      test('should handle single word', () {
        expect(schema.parse('HELLO'), 'hello');
      });

      test('should return empty string for empty input', () {
        expect(schema.parse(''), '');
      });
    });

    group('toSnakeCase', () {
      final schema = VString().toSnakeCase();

      test('should convert PascalCase to snake_case', () {
        expect(schema.parse('HelloWorld'), 'hello_world');
      });

      test('should convert camelCase to snake_case', () {
        expect(schema.parse('userProfileId'), 'user_profile_id');
      });

      test('should convert SCREAMING_SNAKE_CASE to snake_case', () {
        expect(schema.parse('HELLO_WORLD'), 'hello_world');
      });

      test('should convert kebab-case to snake_case', () {
        expect(schema.parse('hello-world'), 'hello_world');
      });

      test('should convert space-separated to snake_case', () {
        expect(schema.parse('Hello World'), 'hello_world');
      });

      test('should split acronym in XMLHttpRequest', () {
        expect(schema.parse('XMLHttpRequest'), 'xml_http_request');
      });

      test('should keep digits as segment', () {
        expect(schema.parse('version2Alpha'), 'version_2_alpha');
      });

      test('should drop invalid characters', () {
        expect(schema.parse('hello@world!foo'), 'hello_world_foo');
      });

      test('should return empty string for empty input', () {
        expect(schema.parse(''), '');
      });
    });

    group('toScreamingSnakeCase', () {
      final schema = VString().toScreamingSnakeCase();

      test('should convert camelCase to SCREAMING_SNAKE_CASE', () {
        expect(schema.parse('helloWorld'), 'HELLO_WORLD');
      });

      test('should convert PascalCase to SCREAMING_SNAKE_CASE', () {
        expect(schema.parse('HelloWorld'), 'HELLO_WORLD');
      });

      test('should convert snake_case to SCREAMING_SNAKE_CASE', () {
        expect(schema.parse('hello_world'), 'HELLO_WORLD');
      });

      test('should convert kebab-case to SCREAMING_SNAKE_CASE', () {
        expect(schema.parse('hello-world'), 'HELLO_WORLD');
      });

      test('should split acronym in XMLHttpRequest', () {
        expect(schema.parse('XMLHttpRequest'), 'XML_HTTP_REQUEST');
      });

      test('should convert space-separated', () {
        expect(schema.parse('hello world'), 'HELLO_WORLD');
      });

      test('should drop invalid characters', () {
        expect(schema.parse('hello@world!'), 'HELLO_WORLD');
      });

      test('should return empty string for empty input', () {
        expect(schema.parse(''), '');
      });
    });

    group('toSlug', () {
      final schema = VString().toSlug();

      test('should convert sentence to slug', () {
        expect(schema.parse('My Blog Post'), 'my-blog-post');
      });

      test('should drop punctuation', () {
        expect(schema.parse('My Blog Post!'), 'my-blog-post');
      });

      test('should convert PascalCase to slug', () {
        expect(schema.parse('HelloWorld'), 'hello-world');
      });

      test('should convert camelCase to slug', () {
        expect(schema.parse('helloWorld'), 'hello-world');
      });

      test('should convert snake_case to slug', () {
        expect(schema.parse('hello_world'), 'hello-world');
      });

      test('should keep digits', () {
        expect(schema.parse('helloWorld_2024'), 'hello-world-2024');
      });

      test('should collapse consecutive separators', () {
        expect(schema.parse('Hello---World'), 'hello-world');
      });

      test('should collapse extra whitespace', () {
        expect(schema.parse('  foo   bar  baz  '), 'foo-bar-baz');
      });

      test('should split acronym in XMLHttpRequest', () {
        expect(schema.parse('XMLHttpRequest'), 'xml-http-request');
      });

      test('should drop invalid characters', () {
        expect(schema.parse('foo@bar.com'), 'foo-bar-com');
      });

      test('should return empty string for empty input', () {
        expect(schema.parse(''), '');
      });
    });

    group('case transforms + validation', () {
      test('toCamelCase should run before equals validator', () {
        final schema = VString().toCamelCase().equals('helloWorld');
        expect(schema.validate('hello_world'), isTrue);
      });

      test('toSlug should run before slug validator', () {
        final schema = VString().toSlug().slug();
        expect(schema.validate('Hello World!'), isTrue);
      });
    });

    group('pre-processing + validation', () {
      test('trim then min should validate after trimming', () {
        final schema = VString().trim().min(3);
        expect(schema.validate('  ab  '), isFalse);
      });

      test('trim then min should pass after trimming valid string', () {
        final schema = VString().trim().min(3);
        expect(schema.validate('  abc  '), isTrue);
      });

      test('toLowerCase then equals should match lowercased', () {
        final schema = VString().toLowerCase().equals('hello');
        expect(schema.validate('HELLO'), isTrue);
      });

      test('toUpperCase then equals should match uppercased', () {
        final schema = VString().toUpperCase().equals('HELLO');
        expect(schema.validate('hello'), isTrue);
      });

      test('trim then toLowerCase should chain transforms', () {
        final schema = VString().trim().toLowerCase();
        expect(schema.parse('  HELLO  '), 'hello');
      });

      test('trim should run before validation regardless of order', () {
        final trimFirst = VString().trim().email();

        final trimLast = VString().email().trim();

        expect(trimFirst.validate('  user@mail.com  '), isTrue);
        expect(trimLast.validate('  user@mail.com  '), isTrue);
      });

      test('toLowerCase should run before validation regardless of order', () {
        final lowerFirst = VString().toLowerCase().equals('hello');

        final lowerLast = VString().equals('hello').toLowerCase();

        expect(lowerFirst.validate('HELLO'), isTrue);
        expect(lowerLast.validate('HELLO'), isTrue);
      });

      test('toUpperCase should run before validation regardless of order', () {
        final upperFirst = VString().toUpperCase().equals('HELLO');

        final upperLast = VString().equals('HELLO').toUpperCase();

        expect(upperFirst.validate('hello'), isTrue);
        expect(upperLast.validate('hello'), isTrue);
      });
    });

    group('method chaining', () {
      test('should combine min and max', () {
        final schema = VString().min(3).max(5);
        expect(schema.validate('abcd'), isTrue);
        expect(schema.validate('ab'), isFalse);
        expect(schema.validate('abcdef'), isFalse);
      });

      test('should collect multiple errors', () {
        final schema = VString().min(5).contains('x');
        final errors = schema.errors('ab');
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'string.too_small');
        expect(errors[1].code, 'contains');
      });

      test('should chain startsWith and endsWith', () {
        final schema = VString().startsWith('hello').endsWith('world');
        expect(schema.validate('hello world'), isTrue);
        expect(schema.validate('hello'), isFalse);
        expect(schema.validate('world'), isFalse);
      });

      test('should combine email and max length', () {
        final schema = VString().email().max(20);
        expect(schema.validate('a@b.com'), isTrue);
        expect(
          schema.validate('verylongemailaddress@example.com'),
          isFalse,
        );
      });
    });

    group('base class features', () {
      test('nullable should allow null', () {
        final schema = VString().min(3).nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should allow null', () {
        final schema = VString().min(3).nullable();
        expect(schema.parse(null), isNull);
      });

      test('defaultValue should return default when null', () {
        final schema = VString().defaultValue('fallback');
        expect(schema.parse(null), 'fallback');
      });

      test('refine should add custom validation', () {
        final schema = VString().refine(
          (v) => v.contains('@'),
          message: 'Needs @',
          code: 'needs_at',
        );
        expect(schema.validate('hello@world'), isTrue);
        expect(schema.validate('hello'), isFalse);
      });
    });

    group('notEmpty', () {
      final schema = VString().notEmpty();

      test('should pass for non-empty string', () {
        expect(schema.validate('hello'), isTrue);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should pass for whitespace-only string', () {
        expect(schema.validate('  '), isTrue);
      });

      test('should return correct error code', () {
        final errs = schema.errors('');
        expect(errs!.first.code, 'not_empty');
      });
    });

    group('array', () {
      test('should create array of strings', () {
        final schema = VString().email().array();
        expect(schema.validate(['a@b.com']), isTrue);
        expect(schema.validate(['bad']), isFalse);
      });
    });
  });
}

class _FakePhonePattern extends PhonePattern {
  const _FakePhonePattern();

  @override
  String get code => 'invalid_phone_fake';

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith('LOCAL:') ? null : {};
}
