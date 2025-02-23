import 'package:validart/validart.dart';
import 'package:test/test.dart';

void main() {
  final Validart v = Validart();

  group('required', () {
    test('should validate required correctly', () {
      final validator = v.string();

      expect(validator.validate('any'), true);
      expect(validator.validate('123'), true);
      expect(validator.validate('------'), true);
      expect(validator.validate(null), false);
      expect(validator.validate(''), false);
    });
  });

  group('email', () {
    test('should validate email correctly', () {
      final validator = v.string().email();

      expect(validator.validate('email'), false);
      expect(validator.validate('email@gmail.com'), true);
      expect(validator.validate('test@domain.com'), true);
      expect(validator.validate('invalid@domain'), false);
      expect(validator.validate(null), false);
      expect(validator.getErrorMessage(null), 'Required');
    });
  });

  group('uuid', () {
    test('should validate UUID v4 correctly (default)', () {
      final validator = v.string().uuid();

      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), true);
      expect(validator.validate('550e8400-e29b-31d4-a716-446655440000'), false);
      expect(validator.validate('550e8400-e29b-41d4-a716-44665544'), false);
      expect(
        validator.validate('550e8400-e29b-41d4-a716-4466554400000'),
        false,
      );
      expect(validator.validate('invalid-uuid'), false);
      expect(validator.validate(''), false);
      expect(validator.validate(null), false);
    });

    test('should validate UUID v1 correctly', () {
      final validator = v.string().uuid(version: UUIDVersion.v1);

      expect(validator.validate('550e8400-e29b-11d4-a716-446655440000'), true);
      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('9073926b-929f-31c2-abc9-fad77ae3e8eb'), false);
    });

    test('should validate UUID v3 correctly', () {
      final validator = v.string().uuid(version: UUIDVersion.v3);

      expect(validator.validate('550e8400-e29b-31d4-a716-446655440000'), true);
      expect(validator.validate('9073926b-929f-31c2-abc9-fad77ae3e8eb'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), false);
    });

    test('should validate UUID v5 correctly', () {
      final validator = v.string().uuid(version: UUIDVersion.v5);

      expect(validator.validate('550e8400-e29b-51d4-a716-446655440000'), true);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), false);
    });

    test('should validate multiple UUID versions', () {
      final validator = v.string().any([
        v.string().uuid(version: UUIDVersion.v1),
        v.string().uuid(version: UUIDVersion.v4),
      ]);

      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), true);
      expect(validator.validate('e8ffc3c2-52cb-4056-b67c-776e78cfb836'), true);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), false);
    });
  });

  group('url', () {
    test('should validate URL correctly', () {
      final validator = v.string().url();

      expect(validator.validate('https://google.com'), true);
      expect(validator.validate('http://example.com'), true);
      expect(validator.validate('www.example.com'), true);
      expect(validator.validate('example.com'), true);
      expect(validator.validate('invalid-url'), false);
      expect(validator.validate('https://'), false);
      expect(validator.validate('http://'), false);
      expect(validator.validate('https://.com'), false);
      expect(validator.validate('http://.com'), false);
      expect(validator.validate(null), false);
    });
  });

  group('cpf', () {
    test('should validate CPF correctly (unformatted)', () {
      final validator = v.string().cpf();

      expect(validator.validate('123.456.789-09'), true);
      expect(validator.validate('12345678909'), true);
      expect(validator.validate('000.000.000-00'), false);
      expect(validator.validate('invalid-cpf'), false);
      expect(validator.validate(null), false);
    });

    test('should validate CPF correctly (formatted)', () {
      final validator = v.string().cpf(mode: ValidationMode.formatted);

      expect(validator.validate('123.456.789-09'), true);

      expect(validator.validate('12345678909'), false);
      expect(validator.validate('000.000.000-00'), false);
      expect(validator.validate('invalid-cpf'), false);
      expect(validator.validate(null), false);
    });
  });

  group('cnpj', () {
    test('should validate CNPJ correctly (unformatted)', () {
      final validator = v.string().cnpj();

      expect(validator.validate('12.345.678/0001-95'), true);
      expect(validator.validate('12345678000195'), true);
      expect(validator.validate('00.000.000/0000-00'), false);
      expect(validator.validate('00000000000000'), false);
      expect(validator.validate('invalid-cnpj'), false);
      expect(validator.validate(null), false);
    });

    test('should validate CNPJ correctly (formatted)', () {
      final validator = v.string().cnpj(mode: ValidationMode.formatted);

      expect(validator.validate('12.345.678/0001-95'), true);
      expect(validator.validate('12345678000195'), false);
      expect(validator.validate('00.000.000/0000-00'), false);
      expect(validator.validate('00000000000000'), false);
      expect(validator.validate('invalid-cnpj'), false);
      expect(validator.validate(null), false);
    });
  });

  group('cep', () {
    test('should validate CEP correctly (unformatted)', () {
      final validator = v.string().cep();

      expect(validator.validate('01001-000'), true);
      expect(validator.validate('01001000'), true);
      expect(validator.validate('00000-000'), false);
      expect(validator.validate('00000000'), false);
      expect(validator.validate('invalid-cep'), false);
      expect(validator.validate(null), false);
    });

    test('should validate CEP correctly (formatted)', () {
      final validator = v.string().cep(mode: ValidationMode.formatted);

      expect(validator.validate('01001-000'), true);
      expect(validator.validate('01001000'), false);
      expect(validator.validate('00000-000'), false);
      expect(validator.validate('00000000'), false);
      expect(validator.validate('invalid-cep'), false);
      expect(validator.validate(null), false);
    });
  });

  group('min length', () {
    test('should validate min length', () {
      final validator = v.string().min(5);

      expect(validator.validate('12345'), true);
      expect(validator.validate('1234'), false);
      expect(validator.validate(null), false);
    });
  });

  group('max length', () {
    test('should validate max length', () {
      final validator = v.string().max(10);

      expect(validator.validate('12345'), true);
      expect(validator.validate('12345678901'), false);
      expect(validator.validate(null), false);
    });
  });

  group('phone', () {
    test('should validate Brazilian phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.brazil,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('11 98765-4321'), true);
      expect(validator.validate('(11) 98765-4321'), true);

      expect(validator.validate('(11)98765-4321'), false);
      expect(validator.validate('11987654321'), false);
      expect(validator.validate('98765-4321'), false);
      expect(validator.validate('9876-5432'), false);
      expect(validator.validate(' 9876-5432'), false);
      expect(validator.validate(null), false);
    });

    test('should validate USA phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.usa,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('123-456-7890'), true);
      expect(validator.validate('(123) 456-7890'), true);
      expect(validator.validate('123 456-7890'), true);

      expect(validator.validate('456-7890'), false);
      expect(validator.validate(' 456-7890'), false);
      expect(validator.validate('12-3456-7890'), false);
    });

    test('should validate Argentina phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.argentina,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('11 1234-5678'), true);
      expect(validator.validate('(11) 1234-5678'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 1234-5678'), false);
      expect(validator.validate('123 456-7890'), false);
    });

    test('should validate Germany phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.germany,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('030 123456'), true);
      expect(validator.validate('(030) 123456'), true);

      expect(validator.validate('123456'), false);
      expect(validator.validate(' 123456'), false);
      expect(validator.validate('030-123-4567'), false);
    });

    test('should validate China phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.china,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('021 1234 5678'), true);
      expect(validator.validate('010 9876 5432'), true);

      expect(validator.validate('1234 5678'), false);
      expect(validator.validate(' 123 4567 8901'), false);
      expect(validator.validate('021-123-4567'), false);
    });

    test('should validate Japan phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.japan,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('03-1234-5678'), true);
      expect(validator.validate('06-9876-5432'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 03 1234 5678'), false);
      expect(validator.validate('03-12-3456-78'), false);
    });

    test('should validate international phone numbers correctly', () {
      final validator = v.string().phone(
            PhoneType.international,
            areaCode: AreaCodeFormat.required,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('123 456 789'), true);
      expect(validator.validate('01234 567 890'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 123-456-789'), false);
      expect(validator.validate('12 34 56 78 90 12'), false);
    });

    test('should validate Brazilian and USA phone numbers correctly', () {
      final validator = v.string().any([
        v.string().phone(
              PhoneType.brazil,
              areaCode: AreaCodeFormat.required,
              countryCode: CountryCodeFormat.none,
              mode: ValidationMode.formatted,
            ),
        v.string().phone(
              PhoneType.usa,
              areaCode: AreaCodeFormat.required,
              countryCode: CountryCodeFormat.none,
              mode: ValidationMode.formatted,
            ),
      ]);

      expect(validator.validate('11 98765-4321'), true);
      expect(validator.validate('(11) 98765-4321'), true);
      expect(validator.validate('(11)98765-4321'), false);

      expect(validator.validate('98765-4321'), false);
      expect(validator.validate('9876-5432'), false);
      expect(validator.validate(' 9876-5432'), false);

      expect(validator.validate('123-456-7890'), true);
      expect(validator.validate('(123) 456-7890'), true);
      expect(validator.validate('123 456-7890'), true);

      expect(validator.validate('456-7890'), false);
      expect(validator.validate(' 456-7890'), false);
      expect(validator.validate('12-3456-7890'), false);
    });

    test(
      'should validate Brazilian phone numbers with country code required',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.required,
              areaCode: AreaCodeFormat.required,
              mode: ValidationMode.formatted,
            );

        expect(validator.validate('+55 11 98765-4321'), true);
        expect(validator.validate('+55 (11) 98765-4321'), true);

        expect(validator.validate('11 98765-4321'), false);
        expect(validator.validate('(11) 98765-4321'), false);
      },
    );

    test(
      'should validate Brazilian phone numbers with country code required (unformatted)',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.required,
              areaCode: AreaCodeFormat.required,
            );

        expect(validator.validate('5511987654321'), true);

        expect(validator.validate('551198765432'), false);
        expect(validator.validate('11987654321'), false);
        expect(validator.validate('1198765432'), false);
      },
    );

    test(
      'should validate Brazilian phone numbers with optional country code',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.optional,
              areaCode: AreaCodeFormat.required,
              mode: ValidationMode.formatted,
            );

        expect(validator.validate('+55 11 98765-4321'), true);
        expect(validator.validate('11 98765-4321'), true);
        expect(validator.validate('98765-4321'), false);
      },
    );

    test('should validate Brazilian phone numbers without area code', () {
      final validator = v.string().phone(
            PhoneType.brazil,
            areaCode: AreaCodeFormat.none,
            countryCode: CountryCodeFormat.none,
            mode: ValidationMode.formatted,
          );

      expect(validator.validate('98765-4321'), true);
      expect(validator.validate('9876-5432'), false);

      expect(validator.validate('11 98765-4321'), false);
      expect(validator.validate('(11) 98765-4321'), false);
      expect(validator.validate('+55 11 98765-4321'), false);
    });

    test(
      'should validate Brazilian phone numbers with country code required and no area code',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.required,
              areaCode: AreaCodeFormat.none,
              mode: ValidationMode.formatted,
            );

        expect(validator.validate('+55 98765-4321'), true);

        expect(validator.validate('98765-4321'), false);
        expect(validator.validate('11 98765-4321'), false);
        expect(validator.validate('+55 11 98765-4321'), false);
      },
    );

    test(
      'should validate Brazilian phone numbers with country code optional and no area code',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.optional,
              areaCode: AreaCodeFormat.none,
              mode: ValidationMode.formatted,
            );

        expect(validator.validate('+55 98765-4321'), true);
        expect(validator.validate('98765-4321'), true);
        expect(validator.validate('11 98765-4321'), false);
        expect(validator.validate('(11) 98765-4321'), false);
      },
    );

    test(
      'should validate Brazilian phone numbers with country code optional and area code optional',
      () {
        final validator = v.string().phone(
              PhoneType.brazil,
              countryCode: CountryCodeFormat.optional,
              areaCode: AreaCodeFormat.optional,
              mode: ValidationMode.formatted,
            );

        expect(validator.validate('98765-4321'), true);
        expect(validator.validate('+55 98765-4321'), true);
        expect(validator.validate('98765-4321'), true);
        expect(validator.validate('11 98765-4321'), true);
        expect(validator.validate('(11) 98765-4321'), true);
        expect(validator.validate('8765-4321'), false);
        expect(validator.validate(''), false);
        expect(validator.validate(null), false);
      },
    );
  });

  group('time', () {
    test('should validate time correctly', () {
      final validator = v.string().time();

      expect(validator.validate('12:30'), true);
      expect(validator.validate('25:00'), false);
      expect(validator.validate('23:59:00'), true);
      expect(validator.validate('23:59:60'), false);
      expect(validator.validate('invalid-time'), false);
      expect(validator.validate(null), false);
    });
  });

  group('integer', () {
    test('should validate integer correctly', () {
      final validator = v.string().integer();

      expect(validator.validate('123'), true);
      expect(validator.validate('-456'), true);
      expect(validator.validate('0'), true);
      expect(validator.validate('3.14'), false);
      expect(validator.validate('abc'), false);
      expect(validator.validate('12a3'), false);
      expect(validator.validate(''), false);
      expect(validator.validate(null), false);
    });

    test('should return correct error message for integer validation', () {
      final validator = v.string().integer();

      expect(validator.getErrorMessage('123'), null);
      expect(validator.getErrorMessage('-456'), null);
      expect(validator.getErrorMessage('3.14'), 'Invalid integer value');
      expect(validator.getErrorMessage('abc'), 'Invalid integer value');
      expect(validator.getErrorMessage('12a3'), 'Invalid integer value');
      expect(validator.getErrorMessage(''), 'Required');
      expect(validator.getErrorMessage(null), 'Required');
    });
  });

  group('double', () {
    test('should validate double correctly', () {
      final validator = v.string().double();

      expect(validator.validate('123.45'), true);
      expect(validator.validate('-987.6'), true);
      expect(validator.validate('0.0'), true);
      expect(validator.validate('100'), true);
      expect(validator.validate('abc'), false);
      expect(validator.validate('12a3.4'), false);
      expect(validator.validate(''), false);
      expect(validator.validate(null), false);
    });

    test('should return correct error message for double validation', () {
      final validator = v.string().double();

      expect(validator.getErrorMessage('123.45'), null);
      expect(validator.getErrorMessage('-987.6'), null);
      expect(validator.getErrorMessage('100'), null);
      expect(validator.getErrorMessage('abc'), 'Invalid double value');
      expect(validator.getErrorMessage('12a3.4'), 'Invalid double value');
      expect(validator.getErrorMessage(''), 'Required');
      expect(validator.getErrorMessage(null), 'Required');
    });
  });

  group('ip', () {
    test('should validate IP addresses', () {
      final validator = v.string().ip();

      expect(validator.validate('192.168.0.1'), true);
      expect(validator.validate('255.255.255.255'), true);
      expect(validator.validate('999.999.999.999'), false);
      expect(validator.validate('invalid-ip'), false);
      expect(validator.validate(null), false);
    });
  });

  group('date', () {
    test('should validate date format', () {
      final validator = v.string().date();

      expect(validator.validate('2025-02-10'), true);
      expect(validator.validate('2025-20-12'), true);
      expect(validator.validate('01/12/2025'), true);
      expect(validator.validate('12/20/2025'), true);
      expect(validator.validate('invalid-date'), false);
      expect(validator.validate(null), false);
    });
  });

  group('contains', () {
    test('should validate contains (case-sensitive)', () {
      final validator = v.string().contains('hello');

      expect(validator.validate('hello world'), true);
      expect(validator.validate('HellO'), false);
      expect(validator.validate('world'), false);
      expect(validator.validate(null), false);
    });

    test('should validate contains (case-insensitive)', () {
      final validator = v
          .string()
          .contains('HellO', caseSensitivity: CaseSensitivity.insensitive);

      expect(validator.validate('hElLo woRld'), true);
      expect(validator.validate('world'), false);
      expect(validator.validate(null), false);
      expect(validator.validate(null), false);
    });
  });

  group('equals', () {
    test('should validate equals (case-sensitive)', () {
      final validator = v.string().equals('password123');

      expect(validator.validate('password123'), true);
      expect(validator.validate('Password123'), false);
      expect(validator.validate(null), false);
    });

    test('should validate equals (case-insensitive)', () {
      final validator = v
          .string()
          .equals('HellO', caseSensitivity: CaseSensitivity.insensitive);

      expect(validator.validate('hello'), true);
      expect(validator.validate('HELLO'), true);
      expect(validator.validate('world'), false);
      expect(validator.validate(null), false);
    });
  });

  group('startsWith', () {
    test('should validate starts with (case-sensitive)', () {
      final validator = v.string().startsWith('Hello');

      expect(validator.validate('Hello World'), true);
      expect(validator.validate('World Hello'), false);
      expect(validator.validate('hello world'), false);
      expect(validator.validate(null), false);
    });

    test('should validate starts with (case-insensitive)', () {
      final validator = v
          .string()
          .startsWith('Hello', caseSensitivity: CaseSensitivity.insensitive);

      expect(validator.validate('hello world'), true);
      expect(validator.validate('HELLO WORLD'), true);
      expect(validator.validate('world hello'), false);
      expect(validator.validate(null), false);
    });
  });

  group('endsWith', () {
    test('should validate ends with (case-sensitive)', () {
      final validator = v.string().endsWith('World');

      expect(validator.validate('Hello World'), true);
      expect(validator.validate('World Hello'), false);
      expect(validator.validate('hello world'), false);
      expect(validator.validate(null), false);
    });

    test('should validate ends with (case-insensitive)', () {
      final validator = v
          .string()
          .endsWith('World', caseSensitivity: CaseSensitivity.insensitive);

      expect(validator.validate('hello world'), true);
      expect(validator.validate('HELLO WORLD'), true);
      expect(validator.validate('WORLD hello'), false);
      expect(validator.validate(null), false);
    });
  });

  group('pattern', () {
    test('should validate pattern', () {
      final validator = v.string().pattern(r'^\d{3}-\d{3}-\d{4}$');

      expect(validator.validate('123-456-7890'), true);
      expect(validator.validate('1234567890'), false);
      expect(validator.validate(null), false);
    });
  });

  group('jwt', () {
    test('should validate JWT correctly', () {
      final validator = v.string().jwt();

      expect(
        validator.validate(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvbiIsImlhdCI6MTUxNjIzOTAyMn0.'
          'SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c',
        ),
        true,
      );
      expect(
        validator.validate(
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.'
          'eyJ1c2VySWQiOiIxMjM0NTYiLCJpYXQiOjE2MTYyMzkwMjJ9.'
          '4tNnZm3DxBr2_3XZNzN1Hy6HUg1iPmdHg37EoYB_n-Y',
        ),
        true,
      );
      expect(
        validator.validate(
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvbiIsImlhdCI6MTUxNjIzOTAyMn0',
        ),
        false,
      );
      expect(validator.validate('invalid-jwt'), false);
      expect(validator.validate(null), false);
    });
  });

  group('slug', () {
    test('should validate slug correctly', () {
      final validator = v.string().slug();

      expect(validator.validate('valid-slug'), true);
      expect(validator.validate('another-valid-slug'), true);
      expect(validator.validate('invalid slug with spaces'), false);
      expect(validator.validate('invalid_slug_with_underscores'), false);
      expect(validator.validate('invalid--double-dash'), false);
      expect(validator.validate('-invalid-leading-dash'), false);
      expect(validator.validate('invalid-trailing-dash-'), false);
      expect(validator.validate(''), false);
      expect(validator.validate(null), false);
    });
  });

  group('alpha', () {
    test('should validate alphabetic strings correctly', () {
      final validator = v.string().alpha();

      expect(validator.validate('HelloWorld'), true);
      expect(validator.validate('OnlyLetters'), true);
      expect(validator.validate('Hello123'), false);
      expect(validator.validate('Hello!'), false);
      expect(validator.validate(' '), false);
      expect(validator.validate(null), false);
    });
  });

  group('alphanumeric', () {
    test('should validate alphanumeric strings correctly', () {
      final validator = v.string().alphanumeric();

      expect(validator.validate('Hello123'), true);
      expect(validator.validate('A1B2C3'), true);
      expect(validator.validate('12345'), true);
      expect(validator.validate('Hello!'), false);
      expect(validator.validate(' '), false);
      expect(validator.validate(null), false);
    });
  });

  group('card', () {
    test('should validate card numbers correctly', () {
      final validator = v.string().card();

      expect(validator.validate('4111111111111111'), true); // Visa
      expect(validator.validate('4111-1111-1111-1111'), true);
      expect(validator.validate('5500000000000004'), true); // MasterCard
      expect(validator.validate('340000000000009'), true); // American Express
      expect(validator.validate('6011000000000004'), true); // Discover
      expect(validator.validate('1234567890123456'), false); // Invalid
      expect(validator.validate(null), false);
    });
  });

  group('password', () {
    test('should validate password complexity', () {
      final validator = v.string().password();

      expect(validator.validate('StrongP@ss123'), true);
      expect(
        validator.validate('WeakPass'),
        false,
      );
      expect(validator.validate('short1!'), false);
      expect(validator.validate('NoNumbers!'), false);
      expect(validator.validate('12345678'), false);
      expect(validator.validate('Stron gP@ss123'), false);
      expect(validator.validate(null), false);
    });
  });

  group('refine', () {
    test('should validate custom refine function', () {
      final validator = v.string().refine((data) => data.contains('z'));

      expect(validator.validate('z example'), true);
      expect(validator.validate('example'), false);
      expect(validator.validate(null), false);
    });
  });

  group('nullable', () {
    test('should validate nullable', () {
      final validator = v.string().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate('hello'), true);
    });
  });

  group('optional', () {
    test('should validate optional', () {
      final validator = v.string().optional();

      expect(validator.validate('hello'), true);
      expect(validator.validate(''), true);
      expect(validator.validate(null), false);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = v.string().every([
        v.string().min(5),
        v.string().max(10),
        v.string().contains('test'),
      ]);

      expect(validator.validate('test123'), true);
      expect(validator.validate('test12'), true);
      expect(validator.validate('short'), false);
      expect(validator.validate('this is a long test'), false);
      expect(validator.validate('randomword'), false);
      expect(validator.validate(null), false);
    });

    test('should return the default message', () {
      final validator = v.string().every([
        v.string().min(5),
        v.string().max(10),
        v.string().contains('test'),
      ]);

      expect(validator.getErrorMessage('test123'), null);
      expect(validator.getErrorMessage('test12'), null);
      expect(validator.getErrorMessage('short'), 'Invalid value');
      expect(validator.getErrorMessage('this is a long test'), 'Invalid value');
      expect(validator.getErrorMessage('randomword'), 'Invalid value');
      expect(validator.getErrorMessage(null), 'Required');
    });

    test('should return the new message', () {
      final validator = v.string(message: 'New required message').every([
        v.string().min(5),
        v.string().max(10),
        v.string().contains('test'),
      ], message: 'New message');

      expect(validator.getErrorMessage('test123'), null);
      expect(validator.getErrorMessage('test12'), null);
      expect(validator.getErrorMessage('short'), 'New message');
      expect(validator.getErrorMessage('this is a long test'), 'New message');
      expect(validator.getErrorMessage('randomword'), 'New message');
      expect(validator.getErrorMessage(null), 'New required message');
    });
  });

  group('any', () {
    test('should pass if at least one validator passes', () {
      final validator = v.string().any([
        v.string().equals('hello'),
        v.string().equals('world'),
      ]);

      expect(validator.validate('hello'), true);
      expect(validator.validate('world'), true);
      expect(validator.validate('hello world'), false);
      expect(validator.validate('random text'), false);
      expect(validator.validate(null), false);
    });

    test('return the default message', () {
      final validator = v.string().any([
        v.string().equals('hello'),
        v.string().equals('world'),
      ]);

      expect(validator.getErrorMessage('hello'), null);
      expect(validator.getErrorMessage('world'), null);
      expect(validator.getErrorMessage('hello world'), 'Invalid value');
      expect(validator.getErrorMessage('random text'), 'Invalid value');
      expect(validator.getErrorMessage(null), 'Required');
    });

    test('return the default message', () {
      final validator = v.string(message: 'New required message').any([
        v.string().equals('hello'),
        v.string().equals('world'),
      ], message: 'New message');

      expect(validator.getErrorMessage('hello'), null);
      expect(validator.getErrorMessage('world'), null);
      expect(validator.getErrorMessage('hello world'), 'New message');
      expect(validator.getErrorMessage('random text'), 'New message');
      expect(validator.getErrorMessage(null), 'New required message');
    });
  });
}
