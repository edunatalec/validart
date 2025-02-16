import 'package:keeper/keeper.dart';
import 'package:test/test.dart';

void main() {
  final Keeper k = Keeper();

  group('required', () {
    test('should validate required correctly', () {
      final validator = k.string();

      expect(validator.validate('any'), true);
      expect(validator.validate('123'), true);
      expect(validator.validate('------'), true);
      expect(validator.validate(null), false);
      expect(validator.validate(''), false);
    });
  });

  group('email', () {
    test('should validate email correctly', () {
      final validator = k.string().email();

      expect(validator.validate('email'), false);
      expect(validator.validate('email@gmail.com'), true);
      expect(validator.validate('test@domain.com'), true);
      expect(validator.validate('invalid@domain'), false);
    });
  });

  group('uuid', () {
    test('should validate UUID v4 correctly (default)', () {
      final validator = k.string().uuid();

      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), true);
      expect(validator.validate('550e8400-e29b-31d4-a716-446655440000'), false);
      expect(validator.validate('550e8400-e29b-41d4-a716-44665544'), false);
      expect(
        validator.validate('550e8400-e29b-41d4-a716-4466554400000'),
        false,
      );
      expect(validator.validate('invalid-uuid'), false);
      expect(validator.validate(null), false);
      expect(validator.validate(''), false);
    });

    test('should validate UUID v1 correctly', () {
      final validator = k.string().uuid(version: UUIDVersion.v1);

      expect(validator.validate('550e8400-e29b-11d4-a716-446655440000'), true);
      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('9073926b-929f-31c2-abc9-fad77ae3e8eb'), false);
    });

    test('should validate UUID v3 correctly', () {
      final validator = k.string().uuid(version: UUIDVersion.v3);

      expect(validator.validate('550e8400-e29b-31d4-a716-446655440000'), true);
      expect(validator.validate('9073926b-929f-31c2-abc9-fad77ae3e8eb'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), false);
    });

    test('should validate UUID v5 correctly', () {
      final validator = k.string().uuid(version: UUIDVersion.v5);

      expect(validator.validate('550e8400-e29b-51d4-a716-446655440000'), true);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), true);
      expect(validator.validate('550e8400-e29b-41d4-a716-446655440000'), false);
      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), false);
    });

    test('should validate multiple UUID versions', () {
      final validator = k.string().any([
        k.string().uuid(version: UUIDVersion.v1),
        k.string().uuid(version: UUIDVersion.v4),
      ]);

      expect(validator.validate('8793b364-ec9e-11ef-b36b-de390fc56918'), true);
      expect(validator.validate('e8ffc3c2-52cb-4056-b67c-776e78cfb836'), true);
      expect(validator.validate('cfbff0d1-9375-5685-968c-48ce8b15ae17'), false);
    });
  });

  group('url', () {
    test('should validate URL correctly', () {
      final validator = k.string().url();

      expect(validator.validate('https://google.com'), true);
      expect(validator.validate('http://example.com'), true);
      expect(validator.validate('www.example.com'), true);
      expect(validator.validate('example.com'), true);
      expect(validator.validate('invalid-url'), false);
      expect(validator.validate('https://'), false);
      expect(validator.validate('http://'), false);
      expect(validator.validate('https://.com'), false);
      expect(validator.validate('http://.com'), false);
    });
  });

  group('cpf', () {
    test('should validate CPF correctly', () {
      final validator = k.string().cpf();

      expect(validator.validate('123.456.789-09'), true);
      expect(validator.validate('12345678909'), true);
      expect(validator.validate('000.000.000-00'), false);
      expect(validator.validate('invalid-cpf'), false);
    });
  });

  group('cnpj', () {
    test('should validate CNPJ correctly', () {
      final validator = k.string().cnpj();

      expect(validator.validate('12.345.678/0001-95'), true);
      expect(validator.validate('12345678000195'), true);
      expect(validator.validate('00.000.000/0000-00'), false);
      expect(validator.validate('invalid-cnpj'), false);
    });
  });

  group('cep', () {
    test('should validate CEP correctly', () {
      final validator = k.string().cep();

      expect(validator.validate('01001-000'), true);
      expect(validator.validate('01001000'), true);
      expect(validator.validate('00000-000'), false);
      expect(validator.validate('invalid-cep'), false);
    });
  });

  group('min length', () {
    test('should validate min length', () {
      final validator = k.string().min(5);

      expect(validator.validate('1234'), false);
      expect(validator.validate('12345'), true);
    });
  });

  group('max length', () {
    test('should validate max length', () {
      final validator = k.string().max(10);

      expect(validator.validate('12345678901'), false);
      expect(validator.validate('12345'), true);
    });
  });

  group('phone', () {
    test('should validate Brazilian phone array correctly', () {
      final validator = k.string().phone(
        PhoneType.brazil,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      final arrayValidator = validator.array();

      expect(arrayValidator.validate(['11 98765-4321']), true);
      expect(arrayValidator.validate(['11 98765-4321', '11 98765-4322']), true);

      expect(arrayValidator.validate(['98765-4321']), false);
      expect(arrayValidator.validate(['11 98765-4321', '98765-4321']), false);
    });

    test('should validate Brazilian phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.brazil,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('11 98765-4321'), true);
      expect(validator.validate('(11) 98765-4321'), true);
      expect(validator.validate('(11)98765-4321'), false);

      expect(validator.validate('98765-4321'), false);
      expect(validator.validate('9876-5432'), false);
      expect(validator.validate(' 9876-5432'), false);
    });

    test('should validate USA phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.usa,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('123-456-7890'), true);
      expect(validator.validate('(123) 456-7890'), true);
      expect(validator.validate('123 456-7890'), true);

      expect(validator.validate('456-7890'), false);
      expect(validator.validate(' 456-7890'), false);
      expect(validator.validate('12-3456-7890'), false);
    });

    test('should validate Argentina phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.argentina,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('11 1234-5678'), true);
      expect(validator.validate('(11) 1234-5678'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 1234-5678'), false);
      expect(validator.validate('123 456-7890'), false);
    });

    test('should validate Germany phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.germany,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('030 123456'), true);
      expect(validator.validate('(030) 123456'), true);

      expect(validator.validate('123456'), false);
      expect(validator.validate(' 123456'), false);
      expect(validator.validate('030-123-4567'), false);
    });

    test('should validate China phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.china,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('021 1234 5678'), true);
      expect(validator.validate('010 9876 5432'), true);

      expect(validator.validate('1234 5678'), false);
      expect(validator.validate(' 123 4567 8901'), false);
      expect(validator.validate('021-123-4567'), false);
    });

    test('should validate Japan phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.japan,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('03-1234-5678'), true);
      expect(validator.validate('06-9876-5432'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 03 1234 5678'), false);
      expect(validator.validate('03-12-3456-78'), false);
    });

    test('should validate international phone numbers correctly', () {
      final validator = k.string().phone(
        PhoneType.international,
        areaCode: AreaCodeFormat.required,
        countryCode: CountryCodeFormat.none,
      );

      expect(validator.validate('123 456 789'), true);
      expect(validator.validate('01234 567 890'), true);

      expect(validator.validate('1234-5678'), false);
      expect(validator.validate(' 123-456-789'), false);
      expect(validator.validate('12 34 56 78 90 12'), false);
    });

    test('should validate Brazilian and USA phone numbers correctly', () {
      final validator = k.string().any([
        k.string().phone(
          PhoneType.brazil,
          areaCode: AreaCodeFormat.required,
          countryCode: CountryCodeFormat.none,
        ),
        k.string().phone(
          PhoneType.usa,
          areaCode: AreaCodeFormat.required,
          countryCode: CountryCodeFormat.none,
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
        final validator = k.string().phone(
          PhoneType.brazil,
          countryCode: CountryCodeFormat.required,
          areaCode: AreaCodeFormat.required,
        );

        expect(validator.validate('+55 11 98765-4321'), true);
        expect(validator.validate('+55 (11) 98765-4321'), true);

        expect(validator.validate('11 98765-4321'), false);
        expect(validator.validate('(11) 98765-4321'), false);
      },
    );

    test(
      'should validate Brazilian phone numbers with optional country code',
      () {
        final validator = k.string().phone(
          PhoneType.brazil,
          countryCode: CountryCodeFormat.optional,
          areaCode: AreaCodeFormat.required,
        );

        expect(validator.validate('+55 11 98765-4321'), true);
        expect(validator.validate('11 98765-4321'), true);
        expect(validator.validate('98765-4321'), false);
      },
    );

    test('should validate Brazilian phone numbers without area code', () {
      final validator = k.string().phone(
        PhoneType.brazil,
        areaCode: AreaCodeFormat.none,
        countryCode: CountryCodeFormat.none,
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
        final validator = k.string().phone(
          PhoneType.brazil,
          countryCode: CountryCodeFormat.required,
          areaCode: AreaCodeFormat.none,
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
        final validator = k.string().phone(
          PhoneType.brazil,
          countryCode: CountryCodeFormat.optional,
          areaCode: AreaCodeFormat.none,
        );

        expect(validator.validate('+55 98765-4321'), true);
        expect(validator.validate('98765-4321'), true);
        expect(validator.validate('11 98765-4321'), false);
        expect(validator.validate('(11) 98765-4321'), false);
      },
    );
  });

  group('time', () {
    test('should validate time correctly', () {
      final validator = k.string().time();

      expect(validator.validate('12:30'), true);
      expect(validator.validate('25:00'), false);
      expect(validator.validate('23:59:00'), true);
      expect(validator.validate('23:59:60'), false);
      expect(validator.validate('invalid-time'), false);
    });
  });

  group('ip', () {
    test('should validate IP addresses', () {
      final validator = k.string().ip();

      expect(validator.validate('192.168.0.1'), true);
      expect(validator.validate('255.255.255.255'), true);
      expect(validator.validate('999.999.999.999'), false);
      expect(validator.validate('invalid-ip'), false);
    });
  });

  group('date', () {
    test('should validate date format', () {
      final validator = k.string().date();

      expect(validator.validate('2025-02-10'), true);
      expect(validator.validate('2025-20-12'), true);
      expect(validator.validate('01/12/2025'), true);
      expect(validator.validate('12/20/2025'), true);
      expect(validator.validate('invalid-date'), false);
    });
  });

  group('contains', () {
    test('should validate contains', () {
      final validator = k.string().contains('hello');

      expect(validator.validate('hello world'), true);
      expect(validator.validate('world'), false);
    });
  });

  group('equals', () {
    test('should validate equals', () {
      final validator = k.string().equals('password123');

      expect(validator.validate('password123'), true);
      expect(validator.validate('Password123'), false);
    });
  });

  group('startsWith', () {
    test('should validate starts with', () {
      final validator = k.string().startsWidth('Hello');

      expect(validator.validate('Hello World'), true);
      expect(validator.validate('World Hello'), false);
    });
  });

  group('endsWith', () {
    test('should validate ends with', () {
      final validator = k.string().endsWith('World');

      expect(validator.validate('Hello World'), true);
      expect(validator.validate('World Hello'), false);
    });
  });

  group('pattern', () {
    test('should validate pattern', () {
      final validator = k.string().pattern(r'^\d{3}-\d{3}-\d{4}$');

      expect(validator.validate('123-456-7890'), true);
      expect(validator.validate('1234567890'), false);
    });
  });

  group('refine', () {
    test('should validate custom refine function', () {
      final validator = k.string().refine((data) => data!.contains('z'));

      expect(validator.validate('z example'), true);
      expect(validator.validate('example'), false);
    });
  });

  group('nullable', () {
    test('should validate nullable', () {
      final validator = k.string().nullable();

      expect(validator.validate(null), true);
      expect(validator.validate('hello'), true);
    });
  });

  group('every', () {
    test('should pass only if all validators pass', () {
      final validator = k.string().every([
        k.string().min(5),
        k.string().max(10),
        k.string().contains('test'),
      ]);

      expect(validator.validate('test123'), true);
      expect(validator.validate('test12'), true);
      expect(validator.validate('short'), false);
      expect(validator.validate('this is a long test'), false);
      expect(validator.validate('randomword'), false);
    });
  });

  group('any', () {
    test('should pass if at least one validator passes', () {
      final validator = k.string().any([
        k.string().equals('hello'),
        k.string().equals('world'),
      ]);

      expect(validator.validate('hello'), true);
      expect(validator.validate('world'), true);
      expect(validator.validate('hello world'), false);
      expect(validator.validate('random text'), false);
    });

    test('should pass if at least one validation condition is met', () {
      final validator = k.string().any([
        k.string().min(5),
        k.string().contains('keeper'),
      ]);

      expect(validator.validate('short'), true);
      expect(validator.validate('keeper'), true);
      expect(validator.validate('tiny'), false);
    });
  });
}
