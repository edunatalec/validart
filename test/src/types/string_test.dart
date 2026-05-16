import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/phone_format.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';
import 'package:validart/src/validation_mode.dart';
import 'package:validart/src/validators/string/card_brand_pattern.dart';
import 'package:validart/src/validators/string/license_plate_pattern.dart';
import 'package:validart/src/validators/string/phone_pattern.dart';
import 'package:validart/src/validators/string/postal_code_pattern.dart';
import 'package:validart/src/validators/string/tax_id_pattern.dart';
import 'package:validart/src/validators/string/uuid_validator.dart';

void main() {
  setUp(() {
    V.setLocale(const VLocale());
    V.treatEmptyAsNull(false);
  });

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

      test('should return error code string.too_small', () {
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

      test('should return error code string.too_big', () {
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

      test('should return error code string.length', () {
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

      test('should return error code string.email', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.email');
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

      test('should return error code string.url', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.url');
      });

      test('should support custom message', () {
        final custom = VString().url(message: 'Bad url');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad url');
      });

      test('should reject ftp by default', () {
        expect(schema.validate('ftp://example.com'), isFalse);
      });

      test('should accept ftp when included in schemes', () {
        final ftpSchema = VString().url(schemes: {'http', 'https', 'ftp'});
        expect(ftpSchema.validate('ftp://example.com'), isTrue);
      });

      test('should accept only schemes in the custom set', () {
        final wsOnly = VString().url(schemes: {'ws', 'wss'});
        expect(wsOnly.validate('ws://example.com'), isTrue);
        expect(wsOnly.validate('wss://example.com'), isTrue);
        expect(wsOnly.validate('http://example.com'), isFalse);
      });

      group('schemes: const {} (scheme optional)', () {
        final schema = VString().url(schemes: const {});

        test('accepts bare host', () {
          expect(schema.validate('google.com'), isTrue);
        });

        test('accepts subdomain host', () {
          expect(schema.validate('www.google.com'), isTrue);
          expect(schema.validate('api.v2.example.co.uk'), isTrue);
        });

        test('accepts host with optional port', () {
          expect(schema.validate('example.com:8080'), isTrue);
          expect(schema.validate('localhost:3000'), isTrue);
        });

        test('accepts localhost without TLD', () {
          expect(schema.validate('localhost'), isTrue);
        });

        test('accepts host with path / query / fragment', () {
          expect(schema.validate('google.com/foo'), isTrue);
          expect(schema.validate('google.com?x=1'), isTrue);
          expect(schema.validate('google.com/path#frag'), isTrue);
        });

        test('also accepts when scheme is present', () {
          expect(schema.validate('https://google.com'), isTrue);
          expect(schema.validate('ftp://example.com'), isTrue);
          expect(schema.validate('file://localhost/etc'), isTrue);
        });

        test('rejects malformed input', () {
          expect(schema.validate('just a string'), isFalse);
          expect(schema.validate('no_tld'), isFalse);
          expect(schema.validate('-leading-hyphen.com'), isFalse);
          expect(schema.validate('trailing-.com'), isFalse);
          expect(schema.validate(''), isFalse);
        });
      });

      group('hostOnly: true', () {
        test('default schemes + hostOnly rejects path/query', () {
          final schema = VString().url(hostOnly: true);
          expect(schema.validate('https://example.com'), isTrue);
          expect(schema.validate('https://example.com:8080'), isTrue);
          expect(schema.validate('https://example.com/path'), isFalse);
          expect(schema.validate('https://example.com?x=1'), isFalse);
          expect(schema.validate('https://example.com#frag'), isFalse);
        });

        test('schemes empty + hostOnly accepts only bare host', () {
          final schema = VString().url(schemes: const {}, hostOnly: true);
          expect(schema.validate('google.com'), isTrue);
          expect(schema.validate('www.google.com'), isTrue);
          expect(schema.validate('localhost'), isTrue);
          expect(schema.validate('localhost:8080'), isTrue);
          expect(schema.validate('https://google.com'), isTrue);
          expect(schema.validate('google.com/path'), isFalse);
          expect(schema.validate('google.com?x=1'), isFalse);
        });
      });
    });

    group('domain', () {
      final schema = VString().domain();

      test('passes for bare domain', () {
        expect(schema.validate('google.com'), isTrue);
      });

      test('passes for subdomain', () {
        expect(schema.validate('www.google.com'), isTrue);
        expect(schema.validate('api.v2.example.co.uk'), isTrue);
      });

      test('passes for localhost with and without port', () {
        expect(schema.validate('localhost'), isTrue);
        expect(schema.validate('localhost:8080'), isTrue);
      });

      test('passes for domain with port', () {
        expect(schema.validate('example.com:443'), isTrue);
      });

      test('rejects scheme-prefixed input', () {
        expect(schema.validate('https://google.com'), isFalse);
        expect(schema.validate('http://example.com'), isFalse);
        expect(schema.validate('ftp://example.com'), isFalse);
      });

      test('rejects path / query / fragment', () {
        expect(schema.validate('google.com/foo'), isFalse);
        expect(schema.validate('google.com?x=1'), isFalse);
        expect(schema.validate('google.com#frag'), isFalse);
      });

      test('rejects malformed hosts', () {
        expect(schema.validate('-leading.com'), isFalse);
        expect(schema.validate('trailing-.com'), isFalse);
        expect(schema.validate('no_tld'), isFalse);
        expect(schema.validate('just a string'), isFalse);
        expect(schema.validate(''), isFalse);
      });

      test('default message is "Invalid domain"', () {
        final errors = schema.errors('bad');
        expect(errors, isNotNull);
        expect(errors!.first.message, 'Invalid domain');
      });

      test('supports custom message', () {
        final custom = VString().domain(message: 'Bad domain');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad domain');
      });

      test('emits error code string.domain', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.domain');
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

      test('should return error code string.uuid', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.uuid');
      });

      test('should support custom message', () {
        final custom = VString().uuid(message: 'Bad uuid');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad uuid');
      });
    });

    group('uuid versions', () {
      test('should accept v7', () {
        final schema = VString().uuid();
        expect(
          schema.validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9'),
          isTrue,
        );
      });

      test('should accept v6', () {
        final schema = VString().uuid();
        expect(
          schema.validate('1ec9414c-232a-6b00-b3c8-9e6bdeced846'),
          isTrue,
        );
      });

      test('should filter by UuidVersion.v4', () {
        final schema = VString().uuid(version: UuidVersion.v4);
        expect(
          schema.validate('550e8400-e29b-41d4-a716-446655440000'),
          isTrue,
        );
        expect(
          schema.validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9'),
          isFalse,
        ); // v7 rejected
      });

      test('should filter by UuidVersion.v7', () {
        final schema = VString().uuid(version: UuidVersion.v7);
        expect(
          schema.validate('018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9'),
          isTrue,
        );
        expect(
          schema.validate('550e8400-e29b-41d4-a716-446655440000'),
          isFalse,
        ); // v4 rejected
      });

      test('should reject version 9 string', () {
        final schema = VString().uuid();
        expect(
          schema.validate('018fcb2e-ea3f-9a3d-b91e-8f2e0c9b33d9'),
          isFalse,
        );
      });
    });

    group('string.ulid', () {
      final schema = VString().ulid();

      test('should accept valid ULID', () {
        expect(schema.validate('01ARZ3NDEKTSV4RRFFQ69G5FAV'), isTrue);
      });

      test('should accept lowercase', () {
        expect(schema.validate('01arz3ndektsv4rrffq69g5fav'), isTrue);
      });

      test('should reject wrong length', () {
        expect(schema.validate('01ARZ3NDEK'), isFalse);
      });

      test('should reject excluded chars (I, L, O, U)', () {
        expect(schema.validate('01ARZ3NDEKTSV4RRFFQ69G5FAI'), isFalse);
      });

      test('should reject timestamp overflow (first char > 7)', () {
        expect(schema.validate('81ARZ3NDEKTSV4RRFFQ69G5FAV'), isFalse);
      });
    });

    group('nanoId', () {
      test('should accept default 21-char NanoID', () {
        final schema = VString().nanoId();
        expect(schema.validate('V1StGXR8_Z5jdHi6B-myT'), isTrue);
      });

      test('should reject wrong length for default', () {
        final schema = VString().nanoId();
        expect(schema.validate('short'), isFalse);
      });

      test('should accept custom length', () {
        final schema = VString().nanoId(length: 10);
        expect(schema.validate('V1StGXR8_Z'), isTrue);
      });

      test('should reject non-URL-safe chars', () {
        final schema = VString().nanoId();
        expect(schema.validate('V1St/XR8_Z5jdHi6B+myT'), isFalse);
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

      test('should return error code string.ip', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.ip');
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

      test('should return error code string.format', () {
        final schema = VString().pattern(r'^\d+$');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'string.format');
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

      test('should return error code string.date', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.date');
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

      test('should return error code string.time', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.time');
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

      test('should return error code string.contains', () {
        final schema = VString().contains('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'string.contains');
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

      test('should return error code string.starts_with', () {
        final schema = VString().startsWith('x');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'string.starts_with');
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

      test('should return error code string.ends_with', () {
        final schema = VString().endsWith('z');
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'string.ends_with');
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

      test('should return error code string.equals', () {
        final schema = VString().equals('x');
        final errors = schema.errors('y');
        expect(errors!.first.code, 'string.equals');
      });

      test('should support custom message', () {
        final schema = VString().equals('x', message: 'Must be x');
        final errors = schema.errors('y');
        expect(errors!.first.message, 'Must be x');
      });
    });

    group('string.alpha', () {
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

      test('should return error code string.alpha', () {
        final errors = schema.errors('123');
        expect(errors!.first.code, 'string.alpha');
      });

      test('should support custom message', () {
        final custom = VString().alpha(message: 'Letters only');
        final errors = custom.errors('123');
        expect(errors!.first.message, 'Letters only');
      });
    });

    group('string.alphanumeric', () {
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

      test('should return error code string.alphanumeric', () {
        final errors = schema.errors('a b');
        expect(errors!.first.code, 'string.alphanumeric');
      });

      test('should support custom message', () {
        final custom = VString().alphanumeric(message: 'Alphanumeric only');
        final errors = custom.errors('a b');
        expect(errors!.first.message, 'Alphanumeric only');
      });
    });

    group('string.slug', () {
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

      test('should return error code string.slug', () {
        final errors = schema.errors('NOT VALID');
        expect(errors!.first.code, 'string.slug');
      });

      test('should support custom message', () {
        final custom = VString().slug(message: 'Bad slug');
        final errors = custom.errors('NOT VALID');
        expect(errors!.first.message, 'Bad slug');
      });
    });

    group('string.password', () {
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

      test('should return error code string.password', () {
        final errors = schema.errors('weak');
        expect(errors!.first.code, 'string.password');
      });

      test('should reject underscore with default specialChars', () {
        expect(schema.validate('Abcdefg1_'), isFalse);
      });

      test('should accept underscore when specialChars includes it', () {
        final custom = VString().password(specialChars: r'!@#$%^&*()-_+=<>?');
        expect(custom.validate('Abcdefg1_'), isTrue);
      });

      test('should accept dash with custom specialChars', () {
        final custom = VString().password(specialChars: r'!@#$%^&*()-_+=<>?');
        expect(custom.validate('Abcdefg1-'), isTrue);
      });

      test('should reject chars not in custom specialChars', () {
        final onlyBang = VString().password(specialChars: '!');
        expect(onlyBang.validate('Abcdefg1!'), isTrue);
        expect(onlyBang.validate('Abcdefg1@'), isFalse);
      });

      test('should support custom message', () {
        final custom = VString().password(message: 'Too weak');
        final errors = custom.errors('weak');
        expect(errors!.first.message, 'Too weak');
      });
    });

    group('string.jwt', () {
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

      test('should return error code string.jwt', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.jwt');
      });

      test('should support custom message', () {
        final custom = VString().jwt(message: 'Bad JWT');
        final errors = custom.errors('bad');
        expect(errors!.first.message, 'Bad JWT');
      });
    });

    group('string.card', () {
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

      test('should return error code string.card', () {
        final errors = schema.errors('1234567890123456');
        expect(errors!.first.code, 'string.card');
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

      test('should accept Discover (644-649 prefix range)', () {
        expect(discover.validate('6445000000000000'), isTrue);
      });

      test('should accept Discover (622126-622925 prefix range)', () {
        expect(discover.validate('6221260000000000'), isTrue);
      });

      test('should reject Discover outside known prefix ranges', () {
        expect(discover.validate('6700000000000000'), isFalse);
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

      test('should return error code string.card when brand does not match',
          () {
        final errors = visa.errors('5555555555554444');
        expect(errors!.first.code, 'string.card');
      });

      test('should accept any brand when brands is empty', () {
        final empty = VString().card(brands: []);
        expect(empty.validate('4111111111111111'), isTrue);
        expect(empty.validate('5555555555554444'), isTrue);
      });

      test('should expose human-readable name for each built-in brand', () {
        expect(const VisaBrand().name, 'Visa');
        expect(const MastercardBrand().name, 'Mastercard');
        expect(const AmexBrand().name, 'American Express');
        expect(const DinersBrand().name, 'Diners Club');
        expect(const DiscoverBrand().name, 'Discover');
        expect(const JcbBrand().name, 'JCB');
      });

      group('mode', () {
        test('any (default) accepts digits-only and groups-of-4 with spaces',
            () {
          expect(schema.validate('4532015112830366'), isTrue);
          expect(schema.validate('4532 0151 1283 0366'), isTrue);
          expect(schema.validate('4532-0151-1283-0366'), isTrue);
        });

        test('formatted requires separator-grouped digits', () {
          final formatted = VString().card(mode: ValidationMode.formatted);

          expect(formatted.validate('4532 0151 1283 0366'), isTrue);
          expect(formatted.validate('4532-0151-1283-0366'), isTrue);
          expect(formatted.validate('4532015112830366'), isFalse);
        });

        test('unformatted rejects any non-digit character', () {
          final unformatted = VString().card(mode: ValidationMode.unformatted);

          expect(unformatted.validate('4532015112830366'), isTrue);
          expect(unformatted.validate('4532 0151 1283 0366'), isFalse);
          expect(unformatted.validate('4532-0151-1283-0366'), isFalse);
        });

        test('mode still enforces Luhn and brand checks', () {
          final formattedVisa = VString().card(
            brands: [const VisaBrand()],
            mode: ValidationMode.formatted,
          );

          expect(formattedVisa.validate('4111 1111 1111 1111'), isTrue);
          expect(formattedVisa.validate('4111 1111 1111 1112'), isFalse);
          expect(formattedVisa.validate('5555 5555 5555 4444'), isFalse);
        });
      });
    });

    group('phone', () {
      final schema = VString().phone();
      final fake = VString().phone(patterns: [const _FakePhonePattern()]);

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

      test('should return error code string.phone', () {
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.phone');
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

    group('string.base64', () {
      final schema = VString().base64();

      test('should pass for valid base64 with padding', () {
        expect(schema.validate('SGVsbG8='), isTrue);
      });

      test('should pass for valid base64 without padding needed', () {
        expect(schema.validate('SGVsbG8h'), isTrue);
      });

      test('should fail for invalid chars', () {
        expect(schema.validate('Hello World!'), isFalse);
      });

      test('should fail for wrong length', () {
        expect(schema.validate('abc'), isFalse);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });
    });

    group('hexColor', () {
      final schema = VString().hexColor();

      test('should pass for 6-digit hex', () {
        expect(schema.validate('#FF0000'), isTrue);
      });

      test('should pass for 3-digit hex', () {
        expect(schema.validate('#F00'), isTrue);
      });

      test('should pass for lowercase', () {
        expect(schema.validate('#ff00aa'), isTrue);
      });

      test('should fail without hash', () {
        expect(schema.validate('FF0000'), isFalse);
      });

      test('should fail for invalid hex chars', () {
        expect(schema.validate('#GG0000'), isFalse);
      });

      test('should fail for wrong length', () {
        expect(schema.validate('#FF00'), isFalse);
      });
    });

    group('string.mac', () {
      final schema = VString().mac();

      test('should pass with colon separator', () {
        expect(schema.validate('AA:BB:CC:DD:EE:FF'), isTrue);
      });

      test('should pass with dash separator', () {
        expect(schema.validate('AA-BB-CC-DD-EE-FF'), isTrue);
      });

      test('should pass lowercase', () {
        expect(schema.validate('aa:bb:cc:dd:ee:ff'), isTrue);
      });

      test('should fail without separators', () {
        expect(schema.validate('AABBCCDDEEFF'), isFalse);
      });

      test('should fail with mixed separators', () {
        expect(schema.validate('AA:BB-CC:DD:EE:FF'), isFalse);
      });

      test('should fail for wrong length', () {
        expect(schema.validate('AA:BB:CC'), isFalse);
      });
    });

    group('string.semver', () {
      final schema = VString().semver();

      test('should pass basic version', () {
        expect(schema.validate('1.2.3'), isTrue);
      });

      test('should pass with pre-release', () {
        expect(schema.validate('1.0.0-alpha.1'), isTrue);
      });

      test('should pass with build metadata', () {
        expect(schema.validate('1.0.0+build.123'), isTrue);
      });

      test('should pass with pre-release and build', () {
        expect(schema.validate('1.0.0-rc.1+build.456'), isTrue);
      });

      test('should fail for two segments', () {
        expect(schema.validate('1.2'), isFalse);
      });

      test('should fail for leading zero', () {
        expect(schema.validate('01.2.3'), isFalse);
      });

      test('should fail for "v" prefix', () {
        expect(schema.validate('v1.2.3'), isFalse);
      });
    });

    group('mongoId', () {
      final schema = VString().mongoId();

      test('should pass for valid 24-hex id', () {
        expect(schema.validate('507f1f77bcf86cd799439011'), isTrue);
      });

      test('should pass uppercase hex', () {
        expect(schema.validate('507F1F77BCF86CD799439011'), isTrue);
      });

      test('should fail for wrong length', () {
        expect(schema.validate('507f1f77bcf86cd79943901'), isFalse);
      });

      test('should fail for non-hex chars', () {
        expect(schema.validate('507f1f77bcf86cd79943901Z'), isFalse);
      });
    });

    group('string.iban', () {
      final schema = VString().iban();

      test('should pass for valid GB IBAN', () {
        expect(schema.validate('GB82WEST12345698765432'), isTrue);
      });

      test('should pass with spaces', () {
        expect(schema.validate('GB82 WEST 1234 5698 7654 32'), isTrue);
      });

      test('should pass for valid DE IBAN', () {
        expect(schema.validate('DE89370400440532013000'), isTrue);
      });

      test('should fail for invalid check digit', () {
        expect(schema.validate('GB82WEST12345698765433'), isFalse);
      });

      test('should fail for too short', () {
        expect(schema.validate('GB82'), isFalse);
      });

      test('should fail for random string', () {
        expect(schema.validate('not-an-iban'), isFalse);
      });
    });

    group('string.json', () {
      final schema = VString().json();

      test('should pass for object', () {
        expect(schema.validate('{"a": 1}'), isTrue);
      });

      test('should pass for array', () {
        expect(schema.validate('[1, 2, 3]'), isTrue);
      });

      test('should pass for number', () {
        expect(schema.validate('42'), isTrue);
      });

      test('should pass for quoted string', () {
        expect(schema.validate('"hello"'), isTrue);
      });

      test('should fail for unquoted string', () {
        expect(schema.validate('hello'), isFalse);
      });

      test('should fail for broken syntax', () {
        expect(schema.validate('{"a": }'), isFalse);
      });
    });

    group('integer', () {
      final schema = VString().integer();

      test('should pass for plain digits', () {
        expect(schema.validate('42'), isTrue);
        expect(schema.validate('0'), isTrue);
      });

      test('should pass for negative sign', () {
        expect(schema.validate('-42'), isTrue);
      });

      test('should pass for positive sign', () {
        expect(schema.validate('+42'), isTrue);
      });

      test('should fail for decimal notation', () {
        expect(schema.validate('42.0'), isFalse);
        expect(schema.validate('3.14'), isFalse);
      });

      test('should fail for scientific notation', () {
        expect(schema.validate('42e3'), isFalse);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should fail for whitespace-padded input', () {
        expect(schema.validate(' 42 '), isFalse);
      });

      test('should fail for hex prefix', () {
        expect(schema.validate('0xFF'), isFalse);
      });

      test('should fail for letters', () {
        expect(schema.validate('abc'), isFalse);
        expect(schema.validate('42a'), isFalse);
      });

      test('should return error code string.integer', () {
        final errors = schema.errors('3.14');
        expect(errors!.first.code, 'string.integer');
      });

      test('should support custom message', () {
        final custom = VString().integer(message: 'Not an integer');
        final errors = custom.errors('3.14');
        expect(errors!.first.message, 'Not an integer');
      });
    });

    group('numeric', () {
      final schema = VString().numeric();

      test('should pass for plain integer', () {
        expect(schema.validate('42'), isTrue);
      });

      test('should pass for negative integer', () {
        expect(schema.validate('-42'), isTrue);
      });

      test('should pass for decimal', () {
        expect(schema.validate('3.14'), isTrue);
        expect(schema.validate('-0.5'), isTrue);
      });

      test('should pass for scientific notation', () {
        expect(schema.validate('42e3'), isTrue);
        expect(schema.validate('1E-10'), isTrue);
      });

      test('should fail for empty string', () {
        expect(schema.validate(''), isFalse);
      });

      test('should fail for whitespace-padded input', () {
        expect(schema.validate(' 42 '), isFalse);
      });

      test('should fail for NaN', () {
        expect(schema.validate('NaN'), isFalse);
      });

      test('should fail for Infinity', () {
        expect(schema.validate('Infinity'), isFalse);
        expect(schema.validate('-Infinity'), isFalse);
      });

      test('should fail for letters', () {
        expect(schema.validate('abc'), isFalse);
        expect(schema.validate('42a'), isFalse);
      });

      test('should return error code string.numeric', () {
        final errors = schema.errors('abc');
        expect(errors!.first.code, 'string.numeric');
      });

      test('should support custom message', () {
        final custom = VString().numeric(message: 'Not a number');
        final errors = custom.errors('abc');
        expect(errors!.first.message, 'Not a number');
      });
    });

    group('string.cvv', () {
      final schema = VString().cvv();

      test('should pass for 3 digits', () {
        expect(schema.validate('123'), isTrue);
      });

      test('should pass for 4 digits', () {
        expect(schema.validate('1234'), isTrue);
      });

      test('should fail for 2 digits', () {
        expect(schema.validate('12'), isFalse);
      });

      test('should fail for 5 digits', () {
        expect(schema.validate('12345'), isFalse);
      });

      test('should fail for non-digits', () {
        expect(schema.validate('12a'), isFalse);
      });
    });

    group('postalCode', () {
      test('UsZipPattern accepts 5-digit ZIP', () {
        final schema = VString().postalCode(patterns: [const UsZipPattern()]);
        expect(schema.validate('94103'), isTrue);
      });

      test('UsZipPattern accepts ZIP+4', () {
        final schema = VString().postalCode(patterns: [const UsZipPattern()]);
        expect(schema.validate('94103-1234'), isTrue);
      });

      test('UsZipPattern rejects letters', () {
        final schema = VString().postalCode(patterns: [const UsZipPattern()]);
        expect(schema.validate('ABC12'), isFalse);
      });

      test('CaPostalCodePattern accepts A1A 1A1', () {
        final schema =
            VString().postalCode(patterns: [const CaPostalCodePattern()]);
        expect(schema.validate('K1A 0B1'), isTrue);
      });

      test('CaPostalCodePattern accepts no-space format', () {
        final schema =
            VString().postalCode(patterns: [const CaPostalCodePattern()]);
        expect(schema.validate('K1A0B1'), isTrue);
      });

      test('CaPostalCodePattern rejects invalid leading letter', () {
        final schema =
            VString().postalCode(patterns: [const CaPostalCodePattern()]);
        expect(schema.validate('D1A 0B1'), isFalse);
      });

      test('UkPostcodePattern accepts SW1A 1AA', () {
        final schema =
            VString().postalCode(patterns: [const UkPostcodePattern()]);
        expect(schema.validate('SW1A 1AA'), isTrue);
      });

      test('UkPostcodePattern accepts M1 1AE', () {
        final schema =
            VString().postalCode(patterns: [const UkPostcodePattern()]);
        expect(schema.validate('M1 1AE'), isTrue);
      });

      test('UkPostcodePattern rejects invalid', () {
        final schema =
            VString().postalCode(patterns: [const UkPostcodePattern()]);
        expect(schema.validate('1ABC 2D'), isFalse);
      });

      test('should return error code postal_code', () {
        final schema = VString().postalCode(patterns: [const UsZipPattern()]);
        final errors = schema.errors('bad');
        expect(errors!.first.code, 'string.postal_code');
      });

      group('CaPostalCodePattern mode', () {
        test('any accepts with and without space', () {
          final schema =
              VString().postalCode(patterns: [const CaPostalCodePattern()]);

          expect(schema.validate('K1A 0B1'), isTrue);
          expect(schema.validate('K1A0B1'), isTrue);
        });

        test('formatted requires the space', () {
          final schema = VString().postalCode(
            patterns: [
              const CaPostalCodePattern(mode: ValidationMode.formatted)
            ],
          );

          expect(schema.validate('K1A 0B1'), isTrue);
          expect(schema.validate('K1A0B1'), isFalse);
        });

        test('unformatted rejects the space', () {
          final schema = VString().postalCode(
            patterns: [
              const CaPostalCodePattern(mode: ValidationMode.unformatted)
            ],
          );

          expect(schema.validate('K1A0B1'), isTrue);
          expect(schema.validate('K1A 0B1'), isFalse);
        });
      });

      group('UkPostcodePattern mode', () {
        test('any accepts with and without space', () {
          final schema =
              VString().postalCode(patterns: [const UkPostcodePattern()]);

          expect(schema.validate('SW1A 1AA'), isTrue);
          expect(schema.validate('SW1A1AA'), isTrue);
        });

        test('formatted requires the space between outward and inward', () {
          final schema = VString().postalCode(
            patterns: [const UkPostcodePattern(mode: ValidationMode.formatted)],
          );

          expect(schema.validate('SW1A 1AA'), isTrue);
          expect(schema.validate('SW1A1AA'), isFalse);
        });

        test('unformatted rejects the space', () {
          final schema = VString().postalCode(
            patterns: [
              const UkPostcodePattern(mode: ValidationMode.unformatted)
            ],
          );

          expect(schema.validate('SW1A1AA'), isTrue);
          expect(schema.validate('SW1A 1AA'), isFalse);
        });
      });
    });

    group('taxId', () {
      test('accepts when custom pattern matches', () {
        final schema = VString().taxId(patterns: [const _DummyTaxIdPattern()]);
        expect(schema.validate('TAX:123'), isTrue);
      });

      test('rejects when custom pattern does not match', () {
        final schema = VString().taxId(patterns: [const _DummyTaxIdPattern()]);
        expect(schema.validate('xyz'), isFalse);
      });

      test('returns error code tax_id', () {
        final schema = VString().taxId(patterns: [const _DummyTaxIdPattern()]);
        final errors = schema.errors('xyz');
        expect(errors!.first.code, 'string.tax_id');
      });

      test('UsSsnPattern accepts formatted', () {
        final schema = VString().taxId(patterns: [const UsSsnPattern()]);
        expect(schema.validate('123-45-6789'), isTrue);
      });

      test('UsSsnPattern accepts unformatted', () {
        final schema = VString().taxId(patterns: [const UsSsnPattern()]);
        expect(schema.validate('123456789'), isTrue);
      });

      test('UsSsnPattern rejects letters', () {
        final schema = VString().taxId(patterns: [const UsSsnPattern()]);
        expect(schema.validate('ABC-45-6789'), isFalse);
      });

      test('UkNiNumberPattern accepts valid', () {
        final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);
        expect(schema.validate('AB123456C'), isTrue);
      });

      test('UkNiNumberPattern accepts with spaces', () {
        final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);
        expect(schema.validate('AB 12 34 56 C'), isTrue);
      });

      test('UkNiNumberPattern rejects excluded first char', () {
        final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);
        expect(schema.validate('DB123456C'), isFalse);
      });

      test('UkNiNumberPattern rejects invalid suffix letter', () {
        final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);
        expect(schema.validate('AB123456E'), isFalse);
      });

      test('CaSinPattern accepts valid with Luhn', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('130692544'), isTrue);
      });

      test('CaSinPattern accepts with spaces/dashes', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('130-692-544'), isTrue);
      });

      test('CaSinPattern rejects SIN starting with 0 (per CRA spec)', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('046454286'), isFalse);
      });

      test('CaSinPattern rejects SIN starting with 8 (per CRA spec)', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        // Passes Luhn but starts with 8 — CRA forbids.
        expect(schema.validate('800000006'), isFalse);
      });

      test('CaSinPattern accepts 9 prefix (temporary residents)', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('930692546'), isTrue);
      });

      test('CaSinPattern rejects invalid Luhn', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('046454287'), isFalse);
      });

      test('CaSinPattern rejects wrong length', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('12345'), isFalse);
      });

      group('UsSsnPattern mode', () {
        test('any accepts formatted and unformatted', () {
          final schema = VString().taxId(patterns: [const UsSsnPattern()]);

          expect(schema.validate('123-45-6789'), isTrue);
          expect(schema.validate('123456789'), isTrue);
        });

        test('any rejects mixed (one separator missing)', () {
          final schema = VString().taxId(patterns: [const UsSsnPattern()]);

          expect(schema.validate('123-456789'), isFalse);
          expect(schema.validate('12345-6789'), isFalse);
        });

        test('formatted requires both dashes', () {
          final schema = VString().taxId(
            patterns: [const UsSsnPattern(mode: ValidationMode.formatted)],
          );

          expect(schema.validate('123-45-6789'), isTrue);
          expect(schema.validate('123456789'), isFalse);
          expect(schema.validate('123-456789'), isFalse);
        });

        test('unformatted rejects any dash', () {
          final schema = VString().taxId(
            patterns: [const UsSsnPattern(mode: ValidationMode.unformatted)],
          );

          expect(schema.validate('123456789'), isTrue);
          expect(schema.validate('123-45-6789'), isFalse);
          expect(schema.validate('123-456789'), isFalse);
        });
      });

      group('UkNiNumberPattern mode', () {
        test('any accepts with and without spaces', () {
          final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);

          expect(schema.validate('AB123456C'), isTrue);
          expect(schema.validate('AB 12 34 56 C'), isTrue);
        });

        test('formatted requires canonical spacing', () {
          final schema = VString().taxId(
            patterns: [const UkNiNumberPattern(mode: ValidationMode.formatted)],
          );

          expect(schema.validate('AB 12 34 56 C'), isTrue);
          expect(schema.validate('AB123456C'), isFalse);
          expect(schema.validate('AB 123456 C'), isFalse);
        });

        test('unformatted rejects any whitespace', () {
          final schema = VString().taxId(
            patterns: [
              const UkNiNumberPattern(mode: ValidationMode.unformatted)
            ],
          );

          expect(schema.validate('AB123456C'), isTrue);
          expect(schema.validate('AB 12 34 56 C'), isFalse);
          expect(schema.validate(' AB123456C'), isFalse);
        });
      });

      group('CaSinPattern mode', () {
        test('any accepts plain digits and formatted forms', () {
          final schema = VString().taxId(patterns: [const CaSinPattern()]);

          expect(schema.validate('130692544'), isTrue);
          expect(schema.validate('130-692-544'), isTrue);
          expect(schema.validate('130 692 544'), isTrue);
        });

        test('formatted requires separators in canonical groups', () {
          final schema = VString().taxId(
            patterns: [const CaSinPattern(mode: ValidationMode.formatted)],
          );

          expect(schema.validate('130-692-544'), isTrue);
          expect(schema.validate('130 692 544'), isTrue);
          expect(schema.validate('130692544'), isFalse);
        });

        test('unformatted rejects any separator', () {
          final schema = VString().taxId(
            patterns: [const CaSinPattern(mode: ValidationMode.unformatted)],
          );

          expect(schema.validate('130692544'), isTrue);
          expect(schema.validate('130-692-544'), isFalse);
          expect(schema.validate('130 692 544'), isFalse);
        });

        test('mode does not loosen checksum', () {
          final schema = VString().taxId(
            patterns: [const CaSinPattern(mode: ValidationMode.unformatted)],
          );

          expect(schema.validate('130692545'), isFalse);
        });
      });
    });

    group('licensePlate', () {
      test('accepts when custom pattern matches', () {
        final schema =
            VString().licensePlate(patterns: [const _DummyPlatePattern()]);
        expect(schema.validate('ABC-1234'), isTrue);
      });

      test('rejects when pattern does not match', () {
        final schema =
            VString().licensePlate(patterns: [const _DummyPlatePattern()]);
        expect(schema.validate('nope'), isFalse);
      });

      test('returns error code license_plate', () {
        final schema =
            VString().licensePlate(patterns: [const _DummyPlatePattern()]);
        final errors = schema.errors('nope');
        expect(errors!.first.code, 'string.license_plate');
      });

      test('UkPlatePattern accepts AB12 CDE', () {
        final schema =
            VString().licensePlate(patterns: [const UkPlatePattern()]);
        expect(schema.validate('AB12 CDE'), isTrue);
      });

      test('UkPlatePattern accepts AB12CDE (no space)', () {
        final schema =
            VString().licensePlate(patterns: [const UkPlatePattern()]);
        expect(schema.validate('AB12CDE'), isTrue);
      });

      test('UkPlatePattern accepts lowercase', () {
        final schema =
            VString().licensePlate(patterns: [const UkPlatePattern()]);
        expect(schema.validate('ab12 cde'), isTrue);
      });

      test('UkPlatePattern rejects wrong format', () {
        final schema =
            VString().licensePlate(patterns: [const UkPlatePattern()]);
        expect(schema.validate('123 ABCD'), isFalse);
      });

      group('UkPlatePattern mode', () {
        test('any accepts with and without space', () {
          final schema =
              VString().licensePlate(patterns: [const UkPlatePattern()]);

          expect(schema.validate('AB12 CDE'), isTrue);
          expect(schema.validate('AB12CDE'), isTrue);
        });

        test('formatted requires the space', () {
          final schema = VString().licensePlate(
            patterns: [const UkPlatePattern(mode: ValidationMode.formatted)],
          );

          expect(schema.validate('AB12 CDE'), isTrue);
          expect(schema.validate('AB12CDE'), isFalse);
        });

        test('unformatted rejects the space', () {
          final schema = VString().licensePlate(
            patterns: [const UkPlatePattern(mode: ValidationMode.unformatted)],
          );

          expect(schema.validate('AB12CDE'), isTrue);
          expect(schema.validate('AB12 CDE'), isFalse);
        });
      });
    });

    group('multi-pattern acceptance', () {
      test('phone accepts numbers matched by any of the patterns', () {
        final schema = VString().phone(
          patterns: [
            const E164PhonePattern(countryCode: CountryCodeFormat.required),
            const _FakePhonePattern(),
          ],
        );

        expect(schema.validate('+14155552671'), isTrue);
        expect(schema.validate('LOCAL:123'), isTrue);
        expect(schema.validate('totally bogus'), isFalse);
      });

      test('phone with multiple patterns emits generic string.phone code', () {
        final schema = VString().phone(
          patterns: [
            const E164PhonePattern(),
            const _FakePhonePattern(),
          ],
        );

        final errors = schema.errors('totally bogus');
        expect(errors!.first.code, 'string.phone');
      });

      test('phone with single pattern preserves the pattern\'s code', () {
        final schema = VString().phone(patterns: [const _FakePhonePattern()]);

        final errors = schema.errors('totally bogus');
        expect(errors!.first.code, 'invalid_phone_fake');
      });

      test('postalCode accepts matches from any country pattern', () {
        final schema = VString().postalCode(
          patterns: [
            const UsZipPattern(),
            const CaPostalCodePattern(),
            const UkPostcodePattern(),
          ],
        );

        expect(schema.validate('94103'), isTrue);
        expect(schema.validate('K1A 0B1'), isTrue);
        expect(schema.validate('SW1A 1AA'), isTrue);
        expect(schema.validate('not a zip'), isFalse);
      });

      test('postalCode error renders joined pattern names via {name}', () {
        final schema = VString().postalCode(
          patterns: [const UsZipPattern(), const UkPostcodePattern()],
        );

        final errors = schema.errors('not a zip');
        expect(errors!.first.message, 'Invalid US ZIP / UK Postcode');
      });

      test('taxId accepts any of the given patterns', () {
        final schema = VString().taxId(
          patterns: [const UsSsnPattern(), const UkNiNumberPattern()],
        );

        expect(schema.validate('123-45-6789'), isTrue);
        expect(schema.validate('AB123456C'), isTrue);
        expect(schema.validate('nonsense'), isFalse);
      });

      test('licensePlate accepts any of the given patterns', () {
        final schema = VString().licensePlate(
          patterns: [const UkPlatePattern(), const _DummyPlatePattern()],
        );

        expect(schema.validate('AB12 CDE'), isTrue);
        expect(schema.validate('ABC-1234'), isTrue);
        expect(schema.validate('nope'), isFalse);
      });

      test('empty patterns list throws via assertion', () {
        expect(
          () => VString().postalCode(patterns: const []),
          throwsA(isA<AssertionError>()),
        );
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

    group('case transforms accents', () {
      test('toSlug should strip accents by default', () {
        final schema = VString().toSlug();
        expect(schema.parse('São João'), 'sao-joao');
      });

      test('toSlug should keep accents when keepAccents is true', () {
        final schema = VString().toSlug(keepAccents: true);
        expect(schema.parse('São João'), 'são-joão');
      });

      test('toPascalCase should strip accents by default', () {
        final schema = VString().toPascalCase();
        expect(schema.parse('maçã fresca'), 'MacaFresca');
      });

      test('toPascalCase should keep accents when keepAccents is true', () {
        final schema = VString().toPascalCase(keepAccents: true);
        expect(schema.parse('maçã fresca'), 'MaçãFresca');
      });

      test('toCamelCase should strip accents', () {
        expect(VString().toCamelCase().parse('São Paulo'), 'saoPaulo');
      });

      test('toSnakeCase should strip accents', () {
        expect(VString().toSnakeCase().parse('São Paulo'), 'sao_paulo');
      });

      test('toScreamingSnakeCase should strip accents', () {
        expect(
          VString().toScreamingSnakeCase().parse('São Paulo'),
          'SAO_PAULO',
        );
      });

      test('should handle cedilla and tilde', () {
        expect(VString().toSlug().parse('Coração Ação'), 'coracao-acao');
      });

      test('should handle German sharp s', () {
        expect(VString().toSlug().parse('Straße'), 'strasse');
      });

      test('should handle ñ', () {
        expect(VString().toSlug().parse('Año Nuevo'), 'ano-nuevo');
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
        expect(errors[1].code, 'string.contains');
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

      test('default that violates a downstream validator fails', () {
        final schema = VString().defaultValue('').min(3);

        expect(schema.validate(null), isFalse);
        expect(() => schema.parse(null), throwsA(isA<VException>()));
        expect(schema.errors(null)!.first.code, 'string.too_small');
      });

      test('default that satisfies validators passes', () {
        final schema = VString().defaultValue('hello').min(3);

        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), 'hello');
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
        expect(errs!.first.code, 'string.not_empty');
      });
    });

    group('array', () {
      test('should create array of strings', () {
        final schema = VString().email().array();
        expect(schema.validate(['a@b.com']), isTrue);
        expect(schema.validate(['bad']), isFalse);
      });
    });

    group('case transforms accent edge cases', () {
      test('empty string stays empty', () {
        expect(VString().toSlug().parse(''), '');
      });

      test('only accented chars', () {
        expect(VString().toSlug().parse('áéí'), 'aei');
      });

      test('only invalid chars yields empty', () {
        expect(VString().toSlug().parse('!@#\$%'), '');
        expect(VString().toPascalCase().parse('!@#'), '');
      });

      test('preserves unknown non-Latin chars in keepAccents mode', () {
        expect(
          VString().toSlug(keepAccents: true).parse('Привет'),
          'привет',
        );
      });

      test('non-Latin letters recognized by \\p{L} tokenizer', () {
        expect(VString().toSlug().parse('Привет Мир'), 'привет-мир');
      });

      test('mixed Latin accented + ASCII', () {
        expect(
          VString().toSnakeCase().parse('Café Quente 123'),
          'cafe_quente_123',
        );
      });
    });

    group('uuid version round-trip', () {
      test('every version from v1 to v8 round-trips', () {
        const samples = {
          UuidVersion.v1: 'a1cc3d48-3d8a-11ee-be56-0242ac120002',
          UuidVersion.v2: 'a1cc3d48-3d8a-21ee-be56-0242ac120002',
          UuidVersion.v3: 'a1cc3d48-3d8a-31ee-be56-0242ac120002',
          UuidVersion.v4: '550e8400-e29b-41d4-a716-446655440000',
          UuidVersion.v5: 'a1cc3d48-3d8a-51ee-be56-0242ac120002',
          UuidVersion.v6: '1ec9414c-232a-6b00-b3c8-9e6bdeced846',
          UuidVersion.v7: '018fcb2e-ea3f-7a3d-b91e-8f2e0c9b33d9',
          UuidVersion.v8: 'a1cc3d48-3d8a-81ee-be56-0242ac120002',
        };

        for (final entry in samples.entries) {
          final schema = VString().uuid(version: entry.key);
          expect(
            schema.validate(entry.value),
            isTrue,
            reason: '${entry.key.name} should accept ${entry.value}',
          );
        }
      });

      test('v0 rejected (regex allows 1-8 only)', () {
        final schema = VString().uuid();
        expect(
          schema.validate('550e8400-e29b-01d4-a716-446655440000'),
          isFalse,
        );
      });

      test('v9 rejected', () {
        final schema = VString().uuid();
        expect(
          schema.validate('550e8400-e29b-91d4-a716-446655440000'),
          isFalse,
        );
      });
    });

    group('card edge cases', () {
      test('accepts dashes as mask', () {
        final schema = VString().card();
        expect(schema.validate('4532-0151-1283-0366'), isTrue);
      });

      test('rejects 20-digit number', () {
        final schema = VString().card();
        expect(schema.validate('45320151128303664532'), isFalse);
      });

      test('rejects 12-digit number', () {
        final schema = VString().card();
        expect(schema.validate('453201511283'), isFalse);
      });

      test('empty brands list acts like no filter', () {
        final schema = VString().card(brands: []);
        expect(schema.validate('378282246310005'), isTrue);
      });
    });

    group('postalCode edge cases', () {
      test('UK postcode accepts single-digit area', () {
        final schema =
            VString().postalCode(patterns: [const UkPostcodePattern()]);
        expect(schema.validate('M1 1AA'), isTrue);
      });

      test('US ZIP rejects letters in ZIP+4', () {
        final schema = VString().postalCode(patterns: [const UsZipPattern()]);
        expect(schema.validate('94103-AAAA'), isFalse);
      });

      test('CA postal accepts lowercase', () {
        final schema =
            VString().postalCode(patterns: [const CaPostalCodePattern()]);
        expect(schema.validate('k1a 0b1'), isTrue);
      });
    });

    group('taxId edge cases', () {
      test('CA SIN rejects all-zero (first-digit rule)', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('000000000'), isFalse);
      });

      test('CA SIN handles unicode dashes gracefully (invalid)', () {
        final schema = VString().taxId(patterns: [const CaSinPattern()]);
        expect(schema.validate('046—454—286'), isFalse);
      });

      test('UK NI rejects with suffix outside A-D', () {
        final schema = VString().taxId(patterns: [const UkNiNumberPattern()]);
        expect(schema.validate('AB123456E'), isFalse);
        expect(schema.validate('AB123456F'), isFalse);
      });
    });

    group('iban edge cases', () {
      test('accepts lowercase (case-insensitive)', () {
        final schema = VString().iban();
        expect(schema.validate('gb82west12345698765432'), isTrue);
      });

      test('rejects wrong check digit by 1', () {
        final schema = VString().iban();
        expect(schema.validate('GB82WEST12345698765433'), isFalse);
      });

      test('rejects all-digits string (missing country letters)', () {
        final schema = VString().iban();
        expect(schema.validate('12345678901234567890'), isFalse);
      });
    });

    group('nanoId edge cases', () {
      test('empty string fails default length', () {
        final schema = VString().nanoId();
        expect(schema.validate(''), isFalse);
      });

      test('length=1 requires exactly one char', () {
        final schema = VString().nanoId(length: 1);
        expect(schema.validate('a'), isTrue);
        expect(schema.validate('ab'), isFalse);
      });
    });

    group('ulid edge cases', () {
      test('all 7s in first char (max valid timestamp prefix)', () {
        final schema = VString().ulid();
        expect(schema.validate('7ZZZZZZZZZZZZZZZZZZZZZZZZZ'), isTrue);
      });

      test('lowercase valid', () {
        final schema = VString().ulid();
        expect(schema.validate('01arz3ndektsv4rrffq69g5fav'), isTrue);
      });
    });

    group('date validator edge cases', () {
      test('format with no tokens rejects everything', () {
        final schema = VString().date(format: 'static-string');
        expect(schema.validate('static-string'), isFalse);
        expect(schema.validate('2024-01-15'), isFalse);
      });

      test('format with only YYYY-MM rejects everything (no day group)', () {
        final schema = VString().date(format: 'YYYY-MM');
        expect(schema.validate('2024-01'), isFalse);
      });

      test('leap year Feb 29 accepted with strict format', () {
        final schema = VString().date(format: 'YYYY-MM-DD');
        expect(schema.validate('2024-02-29'), isTrue);
        expect(schema.validate('2023-02-29'), isFalse);
      });
    });

    group('treatEmptyAsNull', () {
      test('without the flag, empty string is a valid string (legacy)', () {
        expect(V.string().validate(''), isTrue);
      });

      test('local true + nullable: "" parses to null', () {
        final schema = V.string().treatEmptyAsNull().nullable();
        expect(schema.parse(''), isNull);
        expect(schema.validate(''), isTrue);
      });

      test('local true without nullable: "" fails as string.required', () {
        final schema = V.string().treatEmptyAsNull();
        final errs = schema.errors('');
        expect(errs, isNotNull);
        expect(errs!.single.code, 'string.required');
      });

      test('local true + defaultValue: "" substitutes the default', () {
        final schema = V.string().treatEmptyAsNull().defaultValue('fallback');
        expect(schema.parse(''), 'fallback');
      });

      test('whitespace-only is preserved (not normalized)', () {
        final schema = V.string().treatEmptyAsNull().nullable();
        expect(schema.parse('   '), '   ');
      });

      test('global true affects new VString instances by default', () {
        V.treatEmptyAsNull(true);
        final schema = V.string().nullable();
        expect(schema.parse(''), isNull);
      });

      test('global true + local false opts out for that schema', () {
        V.treatEmptyAsNull(true);
        final schema = V.string().treatEmptyAsNull(enabled: false).min(1);
        final errs = schema.errors('');
        expect(errs, isNotNull);
        expect(errs!.first.code, 'string.too_small');
      });

      test('local false with global off is a no-op', () {
        final schema = V.string().treatEmptyAsNull(enabled: false);
        expect(schema.validate(''), isTrue);
      });

      test('local true overrides global false', () {
        V.treatEmptyAsNull(false);
        final schema = V.string().treatEmptyAsNull().nullable();
        expect(schema.parse(''), isNull);
      });

      test('normalize runs BEFORE user-registered .preprocess()', () {
        Object? seen = 'unset';
        final schema = V.string().treatEmptyAsNull().nullable().preprocess(
          (v) {
            seen = v;
            return v;
          },
        );

        schema.parse('');
        expect(
          seen,
          isNull,
          reason: 'preprocess sees null (post-normalize), not ""',
        );
      });

      test('async pipeline: "" parses to null without invoking refineAsync',
          () async {
        var refineRan = 0;
        final schema =
            V.string().treatEmptyAsNull().nullable().refineAsync((s) async {
          refineRan++;
          return true;
        });

        expect(await schema.parseAsync(''), isNull);
        expect(refineRan, 0);
      });

      test(
        'non-empty input is untouched whether flag is on or off',
        () {
          V.treatEmptyAsNull(true);
          expect(V.string().min(1).parse('hi'), 'hi');
        },
      );

      test('isEmptyAsNullEnabled reflects the latest setter call', () {
        expect(V.isEmptyAsNullEnabled, isFalse);
        V.treatEmptyAsNull(true);
        expect(V.isEmptyAsNullEnabled, isTrue);
        V.treatEmptyAsNull(false);
        expect(V.isEmptyAsNullEnabled, isFalse);
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

class _DummyTaxIdPattern extends TaxIdPattern {
  const _DummyTaxIdPattern();

  @override
  String get name => 'Dummy Tax ID';

  @override
  bool matches(String value) => value.startsWith('TAX:');
}

class _DummyPlatePattern extends LicensePlatePattern {
  const _DummyPlatePattern();

  @override
  String get name => 'Dummy Plate';

  @override
  bool matches(String value) => RegExp(r'^[A-Z]{3}-\d{4}$').hasMatch(value);
}
