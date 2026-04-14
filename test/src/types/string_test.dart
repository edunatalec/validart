import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VString', () {
    group('min', () {
      test('should pass when string length >= min', () {
        final schema = VString()..min(3);
        expect(schema.validate('abc'), isTrue);
      });

      test('should pass when string length > min', () {
        final schema = VString()..min(3);
        expect(schema.validate('abcd'), isTrue);
      });

      test('should fail when string length < min', () {
        final schema = VString()..min(3);
        expect(schema.validate('ab'), isFalse);
      });

      test('should fail when string is empty', () {
        final schema = VString()..min(1);
        expect(schema.validate(''), isFalse);
      });

      test('should return error code too_small', () {
        final schema = VString()..min(3);
        final errors = schema.errors('ab');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'too_small');
      });

      test('should support custom message', () {
        final schema = VString()..min(3, message: (len) => 'At least $len');
        final errors = schema.errors('ab');
        expect(errors!.first.message, 'At least 3');
      });
    });

    group('max', () {
      test('should pass when string length <= max', () {
        final schema = VString()..max(5);
        expect(schema.validate('hello'), isTrue);
      });

      test('should pass when string length < max', () {
        final schema = VString()..max(5);
        expect(schema.validate('hi'), isTrue);
      });

      test('should fail when string length > max', () {
        final schema = VString()..max(5);
        expect(schema.validate('toolong'), isFalse);
      });

      test('should return error code too_big', () {
        final schema = VString()..max(3);
        final errors = schema.errors('abcd');
        expect(errors!.first.code, 'too_big');
      });

      test('should support custom message', () {
        final schema = VString()..max(3, message: (len) => 'Max $len');
        final errors = schema.errors('abcd');
        expect(errors!.first.message, 'Max 3');
      });
    });

    group('length', () {
      test('should pass when string has exact length', () {
        final schema = VString()..length(4);
        expect(schema.validate('abcd'), isTrue);
      });

      test('should fail when string is shorter', () {
        final schema = VString()..length(4);
        expect(schema.validate('abc'), isFalse);
      });

      test('should fail when string is longer', () {
        final schema = VString()..length(4);
        expect(schema.validate('abcde'), isFalse);
      });

      test('should return error code length', () {
        final schema = VString()..length(4);
        final errors = schema.errors('ab');
        expect(errors!.first.code, 'length');
      });

      test('should support custom message', () {
        final schema = VString()..length(4, message: (len) => 'Need $len');
        final errors = schema.errors('ab');
        expect(errors!.first.message, 'Need 4');
      });
    });

    group('email', () {
      test('should pass for valid email', () {
        final schema = VString()..email();
        expect(schema.validate('user@example.com'), isTrue);
      });

      test('should pass for email with plus tag', () {
        final schema = VString()..email();
        expect(schema.validate('user+tag@example.com'), isTrue);
      });

      test('should fail for missing @', () {
        final schema = VString()..email();
        expect(schema.validate('userexample.com'), isFalse);
      });

      test('should fail for missing domain', () {
        final schema = VString()..email();
        expect(schema.validate('user@'), isFalse);
      });

      test('should fail for double dots', () {
        final schema = VString()..email();
        expect(schema.validate('user..name@example.com'), isFalse);
      });

      test('should return error code invalid_email', () {
        final schema = VString()..email();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_email');
      });

      test('should support custom message', () {
        final schema = VString()..email(message: 'Bad email');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad email');
      });
    });

    group('url', () {
      test('should pass for valid http url', () {
        final schema = VString()..url();
        expect(schema.validate('http://example.com'), isTrue);
      });

      test('should pass for valid https url', () {
        final schema = VString()..url();
        expect(schema.validate('https://example.com/path?q=1'), isTrue);
      });

      test('should fail for missing protocol', () {
        final schema = VString()..url();
        expect(schema.validate('example.com'), isFalse);
      });

      test('should fail for empty string', () {
        final schema = VString()..url();
        expect(schema.validate(''), isFalse);
      });

      test('should return error code invalid_url', () {
        final schema = VString()..url();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_url');
      });

      test('should support custom message', () {
        final schema = VString()..url(message: 'Bad url');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad url');
      });
    });

    group('uuid', () {
      test('should pass for valid uuid v4', () {
        final schema = VString()..uuid();
        expect(schema.validate('550e8400-e29b-41d4-a716-446655440000'), isTrue);
      });

      test('should fail for invalid uuid', () {
        final schema = VString()..uuid();
        expect(schema.validate('not-a-uuid'), isFalse);
      });

      test('should fail for uuid missing dashes', () {
        final schema = VString()..uuid();
        expect(schema.validate('550e8400e29b41d4a716446655440000'), isFalse);
      });

      test('should return error code invalid_uuid', () {
        final schema = VString()..uuid();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_uuid');
      });

      test('should support custom message', () {
        final schema = VString()..uuid(message: 'Bad uuid');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad uuid');
      });
    });

    group('ip', () {
      test('should pass for valid IPv4', () {
        final schema = VString()..ip();
        expect(schema.validate('192.168.1.1'), isTrue);
      });

      test('should pass for valid IPv6', () {
        final schema = VString()..ip();
        expect(
          schema.validate('2001:0db8:85a3:0000:0000:8a2e:0370:7334'),
          isTrue,
        );
      });

      test('should fail for invalid IP', () {
        final schema = VString()..ip();
        expect(schema.validate('999.999.999.999'), isFalse);
      });

      test('should fail for random string', () {
        final schema = VString()..ip();
        expect(schema.validate('not-an-ip'), isFalse);
      });

      test('should return error code invalid_ip', () {
        final schema = VString()..ip();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_ip');
      });

      test('should support custom message', () {
        final schema = VString()..ip(message: 'Bad ip');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad ip');
      });
    });

    group('pattern', () {
      test('should pass when value matches regex', () {
        final schema = VString()..pattern(r'^\d{3}$');
        expect(schema.validate('123'), isTrue);
      });

      test('should fail when value does not match regex', () {
        final schema = VString()..pattern(r'^\d{3}$');
        expect(schema.validate('abc'), isFalse);
      });

      test('should return error code invalid_format', () {
        final schema = VString()..pattern(r'^\d+$');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'invalid_format');
      });

      test('should support custom message', () {
        final schema = VString()..pattern(r'^\d+$', message: 'Numbers only');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Numbers only');
      });
    });

    group('date', () {
      test('should pass for valid ISO date', () {
        final schema = VString()..date();
        expect(schema.validate('2024-01-15'), isTrue);
      });

      test('should pass for valid date edge cases', () {
        final schema = VString()..date();
        expect(schema.validate('2024-12-31'), isTrue);
      });

      test('should fail for invalid month', () {
        final schema = VString()..date();
        expect(schema.validate('2024-13-01'), isFalse);
      });

      test('should fail for invalid day', () {
        final schema = VString()..date();
        expect(schema.validate('2024-01-32'), isFalse);
      });

      test('should fail for wrong format', () {
        final schema = VString()..date();
        expect(schema.validate('01/15/2024'), isFalse);
      });

      test('should return error code invalid_date', () {
        final schema = VString()..date();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_date');
      });

      test('should support custom message', () {
        final schema = VString()..date(message: 'Bad date');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad date');
      });
    });

    group('time', () {
      test('should pass for HH:MM format', () {
        final schema = VString()..time();
        expect(schema.validate('14:30'), isTrue);
      });

      test('should pass for HH:MM:SS format', () {
        final schema = VString()..time();
        expect(schema.validate('14:30:59'), isTrue);
      });

      test('should pass for midnight', () {
        final schema = VString()..time();
        expect(schema.validate('00:00'), isTrue);
      });

      test('should fail for invalid hour', () {
        final schema = VString()..time();
        expect(schema.validate('25:00'), isFalse);
      });

      test('should fail for invalid minute', () {
        final schema = VString()..time();
        expect(schema.validate('12:60'), isFalse);
      });

      test('should fail for random string', () {
        final schema = VString()..time();
        expect(schema.validate('not-time'), isFalse);
      });

      test('should return error code invalid_time', () {
        final schema = VString()..time();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_time');
      });

      test('should support custom message', () {
        final schema = VString()..time(message: 'Bad time');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad time');
      });
    });

    group('contains', () {
      test('should pass when string contains value', () {
        final schema = VString()..contains('world');
        expect(schema.validate('hello world'), isTrue);
      });

      test('should fail when string does not contain value', () {
        final schema = VString()..contains('world');
        expect(schema.validate('hello'), isFalse);
      });

      test('should return error code contains', () {
        final schema = VString()..contains('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'contains');
      });

      test('should support custom message', () {
        final schema = VString()..contains('x', message: 'Must have x');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must have x');
      });
    });

    group('startsWith', () {
      test('should pass when string starts with prefix', () {
        final schema = VString()..startsWith('hello');
        expect(schema.validate('hello world'), isTrue);
      });

      test('should fail when string does not start with prefix', () {
        final schema = VString()..startsWith('hello');
        expect(schema.validate('world hello'), isFalse);
      });

      test('should return error code starts_with', () {
        final schema = VString()..startsWith('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'starts_with');
      });

      test('should support custom message', () {
        final schema = VString()..startsWith('x', message: 'Must start with x');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must start with x');
      });
    });

    group('endsWith', () {
      test('should pass when string ends with suffix', () {
        final schema = VString()..endsWith('.dart');
        expect(schema.validate('main.dart'), isTrue);
      });

      test('should fail when string does not end with suffix', () {
        final schema = VString()..endsWith('.dart');
        expect(schema.validate('main.js'), isFalse);
      });

      test('should return error code ends_with', () {
        final schema = VString()..endsWith('z');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'ends_with');
      });

      test('should support custom message', () {
        final schema = VString()..endsWith('z', message: 'Must end with z');
        final errors = schema.errors('abc');
        expect(errors!.first.message, 'Must end with z');
      });
    });

    group('equals', () {
      test('should pass when string equals value', () {
        final schema = VString()..equals('exact');
        expect(schema.validate('exact'), isTrue);
      });

      test('should fail when string does not equal value', () {
        final schema = VString()..equals('exact');
        expect(schema.validate('other'), isFalse);
      });

      test('should be case sensitive', () {
        final schema = VString()..equals('Hello');
        expect(schema.validate('hello'), isFalse);
      });

      test('should return error code equals', () {
        final schema = VString()..equals('x');
        final errors = schema.errors('y');
        expect(errors!.first.code, 'equals');
      });

      test('should support custom message', () {
        final schema = VString()..equals('x', message: 'Must be x');
        final errors = schema.errors('y');
        expect(errors!.first.message, 'Must be x');
      });
    });

    group('alpha', () {
      test('should pass for only letters', () {
        final schema = VString()..alpha();
        expect(schema.validate('abcXYZ'), isTrue);
      });

      test('should fail for string with numbers', () {
        final schema = VString()..alpha();
        expect(schema.validate('abc123'), isFalse);
      });

      test('should fail for string with spaces', () {
        final schema = VString()..alpha();
        expect(schema.validate('hello world'), isFalse);
      });

      test('should fail for string with special chars', () {
        final schema = VString()..alpha();
        expect(schema.validate('abc!'), isFalse);
      });

      test('should return error code alpha', () {
        final schema = VString()..alpha();
        final errors = schema.errors('123');
        expect(errors!.first.code, 'alpha');
      });

      test('should support custom message', () {
        final schema = VString()..alpha(message: 'Letters only');
        final errors = schema.errors('123');
        expect(errors!.first.message, 'Letters only');
      });
    });

    group('alphanumeric', () {
      test('should pass for letters and numbers', () {
        final schema = VString()..alphanumeric();
        expect(schema.validate('abc123'), isTrue);
      });

      test('should pass for only letters', () {
        final schema = VString()..alphanumeric();
        expect(schema.validate('abc'), isTrue);
      });

      test('should pass for only numbers', () {
        final schema = VString()..alphanumeric();
        expect(schema.validate('123'), isTrue);
      });

      test('should fail for string with spaces', () {
        final schema = VString()..alphanumeric();
        expect(schema.validate('abc 123'), isFalse);
      });

      test('should fail for string with special chars', () {
        final schema = VString()..alphanumeric();
        expect(schema.validate('abc!@#'), isFalse);
      });

      test('should return error code alphanumeric', () {
        final schema = VString()..alphanumeric();
        final errors = schema.errors('a b');
        expect(errors!.first.code, 'alphanumeric');
      });

      test('should support custom message', () {
        final schema = VString()..alphanumeric(message: 'Alphanumeric only');
        final errors = schema.errors('a b');
        expect(errors!.first.message, 'Alphanumeric only');
      });
    });

    group('slug', () {
      test('should pass for valid slug', () {
        final schema = VString()..slug();
        expect(schema.validate('hello-world'), isTrue);
      });

      test('should pass for single word slug', () {
        final schema = VString()..slug();
        expect(schema.validate('hello'), isTrue);
      });

      test('should pass for slug with numbers', () {
        final schema = VString()..slug();
        expect(schema.validate('post-123'), isTrue);
      });

      test('should fail for uppercase', () {
        final schema = VString()..slug();
        expect(schema.validate('Hello-World'), isFalse);
      });

      test('should fail for spaces', () {
        final schema = VString()..slug();
        expect(schema.validate('hello world'), isFalse);
      });

      test('should fail for leading hyphen', () {
        final schema = VString()..slug();
        expect(schema.validate('-hello'), isFalse);
      });

      test('should fail for trailing hyphen', () {
        final schema = VString()..slug();
        expect(schema.validate('hello-'), isFalse);
      });

      test('should return error code slug', () {
        final schema = VString()..slug();
        final errors = schema.errors('NOT VALID');
        expect(errors!.first.code, 'slug');
      });

      test('should support custom message', () {
        final schema = VString()..slug(message: 'Bad slug');
        final errors = schema.errors('NOT VALID');
        expect(errors!.first.message, 'Bad slug');
      });
    });

    group('password', () {
      test('should pass for strong password', () {
        final schema = VString()..password();
        expect(schema.validate('Abcdef1!'), isTrue);
      });

      test('should fail for too short', () {
        final schema = VString()..password();
        expect(schema.validate('Ab1!'), isFalse);
      });

      test('should fail for no uppercase', () {
        final schema = VString()..password();
        expect(schema.validate('abcdef1!'), isFalse);
      });

      test('should fail for no lowercase', () {
        final schema = VString()..password();
        expect(schema.validate('ABCDEF1!'), isFalse);
      });

      test('should fail for no digit', () {
        final schema = VString()..password();
        expect(schema.validate('Abcdefg!'), isFalse);
      });

      test('should fail for no special character', () {
        final schema = VString()..password();
        expect(schema.validate('Abcdefg1'), isFalse);
      });

      test('should return error code password', () {
        final schema = VString()..password();
        final errors = schema.errors('weak');
        expect(errors!.first.code, 'password');
      });

      test('should support custom message', () {
        final schema = VString()..password(message: 'Too weak');
        final errors = schema.errors('weak');
        expect(errors!.first.message, 'Too weak');
      });
    });

    group('jwt', () {
      test('should pass for valid JWT', () {
        final schema = VString()..jwt();
        expect(
          schema.validate(
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U',
          ),
          isTrue,
        );
      });

      test('should fail for missing part', () {
        final schema = VString()..jwt();
        expect(schema.validate('part1.part2'), isFalse);
      });

      test('should fail for empty string', () {
        final schema = VString()..jwt();
        expect(schema.validate(''), isFalse);
      });

      test('should fail for random string', () {
        final schema = VString()..jwt();
        expect(schema.validate('not-a-jwt'), isFalse);
      });

      test('should return error code jwt', () {
        final schema = VString()..jwt();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'jwt');
      });

      test('should support custom message', () {
        final schema = VString()..jwt(message: 'Bad JWT');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad JWT');
      });
    });

    group('card', () {
      test('should pass for valid card number (Luhn)', () {
        final schema = VString()..card();
        expect(schema.validate('4532015112830366'), isTrue);
      });

      test('should pass for valid card with spaces', () {
        final schema = VString()..card();
        expect(schema.validate('4532 0151 1283 0366'), isTrue);
      });

      test('should fail for invalid card number', () {
        final schema = VString()..card();
        expect(schema.validate('1234567890123456'), isFalse);
      });

      test('should fail for too short number', () {
        final schema = VString()..card();
        expect(schema.validate('123'), isFalse);
      });

      test('should return error code card', () {
        final schema = VString()..card();
        final errors = schema.errors('1234567890123456');
        expect(errors!.first.code, 'card');
      });

      test('should support custom message', () {
        final schema = VString()..card(message: 'Bad card');
        final errors = schema.errors('1234567890123456');
        expect(errors!.first.message, 'Bad card');
      });
    });

    group('phone', () {
      test('should pass for valid E.164 phone', () {
        final schema = VString()..phone();
        expect(schema.validate('+14155552671'), isTrue);
      });

      test('should pass for phone without +', () {
        final schema = VString()..phone();
        expect(schema.validate('14155552671'), isTrue);
      });

      test('should fail for phone starting with 0', () {
        final schema = VString()..phone();
        expect(schema.validate('014155552671'), isFalse);
      });

      test('should fail for letters in phone', () {
        final schema = VString()..phone();
        expect(schema.validate('+1abc5552671'), isFalse);
      });

      test('should fail for empty string', () {
        final schema = VString()..phone();
        expect(schema.validate(''), isFalse);
      });

      test('should return error code invalid_phone', () {
        final schema = VString()..phone();
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'invalid_phone');
      });

      test('should support custom message', () {
        final schema = VString()..phone(message: 'Bad phone');
        final errors = schema.errors('bad');
        expect(errors!.first.message, 'Bad phone');
      });
    });

    group('trim', () {
      test('should trim whitespace from both ends', () {
        final schema = VString()..trim();
        expect(schema.parse('  hello  '), 'hello');
      });

      test('should not modify string without whitespace', () {
        final schema = VString()..trim();
        expect(schema.parse('hello'), 'hello');
      });
    });

    group('toLowerCase', () {
      test('should convert to lowercase', () {
        final schema = VString()..toLowerCase();
        expect(schema.parse('HELLO'), 'hello');
      });

      test('should not modify already lowercase string', () {
        final schema = VString()..toLowerCase();
        expect(schema.parse('hello'), 'hello');
      });
    });

    group('toUpperCase', () {
      test('should convert to uppercase', () {
        final schema = VString()..toUpperCase();
        expect(schema.parse('hello'), 'HELLO');
      });

      test('should not modify already uppercase string', () {
        final schema = VString()..toUpperCase();
        expect(schema.parse('HELLO'), 'HELLO');
      });
    });

    group('transform + validation', () {
      test('trim then min should validate after trimming', () {
        final schema = VString()
          ..trim()
          ..min(3);
        expect(schema.validate('  ab  '), isFalse);
      });

      test('trim then min should pass after trimming valid string', () {
        final schema = VString()
          ..trim()
          ..min(3);
        expect(schema.validate('  abc  '), isTrue);
      });

      test('toLowerCase then equals should match lowercased', () {
        final schema = VString()
          ..toLowerCase()
          ..equals('hello');
        expect(schema.validate('HELLO'), isTrue);
      });

      test('toUpperCase then equals should match uppercased', () {
        final schema = VString()
          ..toUpperCase()
          ..equals('HELLO');
        expect(schema.validate('hello'), isTrue);
      });

      test('trim then toLowerCase should chain transforms', () {
        final schema = VString()
          ..trim()
          ..toLowerCase();
        expect(schema.parse('  HELLO  '), 'hello');
      });
    });

    group('method chaining', () {
      test('should combine min and max', () {
        final schema = VString()
          ..min(3)
          ..max(5);
        expect(schema.validate('abcd'), isTrue);
        expect(schema.validate('ab'), isFalse);
        expect(schema.validate('abcdef'), isFalse);
      });

      test('should collect multiple errors', () {
        final schema = VString()
          ..min(5)
          ..contains('x');
        final errors = schema.errors('ab');
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'too_small');
        expect(errors[1].code, 'contains');
      });

      test('should chain startsWith and endsWith', () {
        final schema = VString()
          ..startsWith('hello')
          ..endsWith('world');
        expect(schema.validate('hello world'), isTrue);
        expect(schema.validate('hello'), isFalse);
        expect(schema.validate('world'), isFalse);
      });

      test('should combine email and max length', () {
        final schema = VString()
          ..email()
          ..max(20);
        expect(schema.validate('a@b.com'), isTrue);
        expect(
          schema.validate('verylongemailaddress@example.com'),
          isFalse,
        );
      });
    });

    group('base class features', () {
      test('optional should allow null', () {
        final schema = VString()
          ..min(3)
          ..optional();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should allow null', () {
        final schema = VString()
          ..min(3)
          ..nullable();
        expect(schema.parse(null), isNull);
      });

      test('defaultValue should return default when null', () {
        final schema = VString()..defaultValue('fallback');
        expect(schema.parse(null), 'fallback');
      });

      test('refine should add custom validation', () {
        final schema = VString()
          ..refine(
            (v) => v.contains('@'),
            message: 'Needs @',
            code: 'needs_at',
          );
        expect(schema.validate('hello@world'), isTrue);
        expect(schema.validate('hello'), isFalse);
      });
    });
  });
}
