import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('notEmpty', () {
    test('should pass for non-empty string', () {
      final schema = VString().notEmpty();
      expect(schema.validate('hello'), isTrue);
    });

    test('should fail for empty string', () {
      final schema = VString().notEmpty();
      expect(schema.validate(''), isFalse);
    });

    test('should return correct error code', () {
      final schema = VString().notEmpty();
      final errs = schema.errors('');
      expect(errs!.first.code, VStringCode.notEmpty);
    });

    test('should use custom message', () {
      final schema = VString().notEmpty(message: 'Cannot be empty');
      final errs = schema.errors('');
      expect(errs!.first.message, 'Cannot be empty');
    });

    test('should use locale message', () {
      V.setLocale(const VLocale({'not_empty': 'Não pode ser vazio'}));
      final schema = VString().notEmpty();
      final errs = schema.errors('');
      expect(errs!.first.message, 'Não pode ser vazio');
    });
  });

  group('VFailure.toMap', () {
    test('should convert errors to map with first error per field', () {
      final schema = V.map({
        'name': V.string().min(3),
        'email': V.string().email(),
      });
      final result = schema.safeParse({'name': 'Al', 'email': 'bad'});
      expect(result, isA<VFailure>());
      final map = (result as VFailure).toMap();
      expect(map['name'], isNotNull);
      expect(map['email'], isNotNull);
    });

    test('should use pathString as key', () {
      final schema = V.map({
        'address': V.map({
          'zip': V.string().min(5),
        }),
      });
      final result = schema.safeParse({
        'address': {'zip': '12'}
      });
      final map = (result as VFailure).toMap();
      expect(map['address.zip'], isNotNull);
    });

    test('should keep only first error per field', () {
      final schema = V.map({
        'name': V.string().min(5).alpha(),
      });
      final result = schema.safeParse({'name': '12'});
      final map = (result as VFailure).toMap();
      expect(map.length, 1);
      expect(map.containsKey('name'), isTrue);
    });

    test('should return empty map for errors without path', () {
      final schema = VString().email();
      final result = schema.safeParse('bad');
      final map = (result as VFailure).toMap();
      expect(map, isEmpty);
    });
  });

  group('VMap.array', () {
    test('should validate array of maps', () {
      final schema = V.map({
        'name': V.string().min(1),
        'email': V.string().email(),
      }).array();
      expect(
        schema.validate([
          {'name': 'Alice', 'email': 'a@b.com'},
          {'name': 'Bob', 'email': 'b@c.com'},
        ]),
        isTrue,
      );
    });

    test('should fail for invalid element in array', () {
      final schema = V.map({
        'name': V.string().min(1),
      }).array();
      expect(
        schema.validate([
          {'name': 'Alice'},
          {'name': ''},
        ]),
        isFalse,
      );
    });

    test('should include index in error path', () {
      final schema = V.map({
        'name': V.string().min(3),
      }).array();
      final errs = schema.errors([
        {'name': 'Alice'},
        {'name': 'Al'},
      ]);
      expect(errs!.first.path, [1, 'name']);
    });
  });

  group('equalFields', () {
    test('should pass when fields are equal', () {
      final schema = V.map({
        'password': V.string().min(8),
        'confirm': V.string(),
      }).equalFields('confirm', 'password');

      expect(
        schema.validate({
          'password': '12345678',
          'confirm': '12345678',
        }),
        isTrue,
      );
    });

    test('should fail when fields are not equal', () {
      final schema = V.map({
        'password': V.string().min(8),
        'confirm': V.string(),
      }).equalFields('confirm', 'password');

      expect(
        schema.validate({
          'password': '12345678',
          'confirm': 'different',
        }),
        isFalse,
      );
    });

    test('should return correct error code', () {
      final schema = V.map({
        'password': V.string(),
        'confirm': V.string(),
      }).equalFields('confirm', 'password');

      final errs = schema.errors({
        'password': 'abc',
        'confirm': 'xyz',
      });
      expect(errs!.first.code, VMapCode.fieldsNotEqual);
    });

    test('should use locale message with params', () {
      V.setLocale(const VLocale({
        'fields_not_equal': '{field} deve ser igual a {other}',
      }));
      final schema = V.map({
        'password': V.string(),
        'confirm': V.string(),
      }).equalFields('confirm', 'password');

      final errs = schema.errors({
        'password': 'abc',
        'confirm': 'xyz',
      });
      expect(errs!.first.message, 'confirm deve ser igual a password');
    });

    test('should use custom message override', () {
      final schema = V.map({
        'password': V.string(),
        'confirm': V.string(),
      }).equalFields('confirm', 'password', message: 'Passwords must match');

      final errs = schema.errors({
        'password': 'abc',
        'confirm': 'xyz',
      });
      expect(errs!.first.message, 'Passwords must match');
    });
  });

  group('transform<O>', () {
    test('should transform string to int', () {
      final schema = V.string().transform<int>((s) => s.length);
      expect(schema.parse('hello'), 5);
    });

    test('should validate before transforming', () {
      final schema =
          (V.string().email()).transform<String>((s) => s.toUpperCase());
      expect(schema.validate('bad'), isFalse);
      expect(schema.parse('a@b.com'), 'A@B.COM');
    });

    test('should propagate errors from inner schema', () {
      final schema = (V.string().min(5)).transform<int>((s) => s.length);
      final errs = schema.errors('hi');
      expect(errs!.first.code, VStringCode.tooSmall);
    });

    test('should return null for null when inner is nullable', () {
      final schema = (V.string().nullable()).transform<int>((s) => s.length);
      expect(schema.parse(null), isNull);
    });
  });

  group('preprocess', () {
    test('should transform value before type check', () {
      final schema = V.string().preprocess((v) => v?.toString() ?? '');
      expect(schema.parse(42), '42');
    });

    test('should preprocess before validation', () {
      final schema =
          V.string().preprocess((v) => (v as String?)?.trim() ?? '').min(3);
      expect(schema.validate('  hello  '), isTrue);
      expect(schema.validate('  hi  '), isFalse);
    });

    test('should handle null in preprocessor', () {
      final schema = V.string().preprocess((v) => v ?? 'default').min(1);
      expect(schema.parse(null), 'default');
    });
  });

  group('when (conditional validation)', () {
    test('should validate conditionally when condition matches', () {
      final schema = V.map({
        'type': V.string(),
        'cnpj': V.string().nullable(),
      }).when('type', equals: 'company', then: {
        'cnpj': V.string().min(14),
      });

      expect(
        schema.validate({'type': 'company', 'cnpj': '12345678901234'}),
        isTrue,
      );
      expect(
        schema.validate({'type': 'company', 'cnpj': '123'}),
        isFalse,
      );
    });

    test('should skip validation when condition does not match', () {
      final schema = V.map({
        'type': V.string(),
        'cnpj': V.string().nullable(),
      }).when('type', equals: 'company', then: {
        'cnpj': V.string().min(14),
      });

      expect(
        schema.validate({'type': 'person', 'cnpj': '123'}),
        isTrue,
      );
    });

    test('should support multiple when rules', () {
      final schema = V.map({
        'type': V.string(),
        'cnpj': V.string().nullable(),
        'cpf': V.string().nullable(),
      }).when('type', equals: 'company', then: {
        'cnpj': V.string().min(14),
      }).when('type', equals: 'person', then: {
        'cpf': V.string().min(11),
      });

      expect(
        schema.validate({
          'type': 'company',
          'cnpj': '12345678901234',
        }),
        isTrue,
      );
      expect(
        schema.validate({
          'type': 'person',
          'cpf': '12345678901',
        }),
        isTrue,
      );
    });

    test('should include field path in errors', () {
      final schema = V.map({
        'type': V.string(),
        'cnpj': V.string().nullable(),
      }).when('type', equals: 'company', then: {
        'cnpj': V.string().min(14),
      });

      final errs = schema.errors({'type': 'company', 'cnpj': '123'});
      expect(errs!.first.path, ['cnpj']);
    });
  });

  group('VFailure.toMap edge cases', () {
    test('should handle nested error paths', () {
      final schema = V.map({
        'user': V.map({
          'email': V.string().email(),
        }),
      });

      final result = schema.safeParse({
        'user': {'email': 'bad'},
      });
      final map = (result as VFailure).toMap();
      expect(map['user.email'], isNotNull);
    });

    test('should handle array index paths', () {
      final schema = V.array(V.string().email());
      final result = schema.safeParse(['good@email.com', 'bad']);
      final map = (result as VFailure).toMap();
      expect(map['[1]'], isNotNull);
    });

    test('should keep first error when field has multiple', () {
      final schema = V.map({
        'x': V.string().min(10).email(),
      });

      final result = schema.safeParse({'x': 'ab'});
      final map = (result as VFailure).toMap();
      expect(map.length, 1);
    });
  });

  group('transform chaining', () {
    test('should chain multiple transforms', () {
      final schema = V
          .string()
          .transform<int>((s) => s.length)
          .transform<String>((n) => 'len:$n');
      expect(schema.parse('hello'), 'len:5');
    });
  });

  group('VLocale interpolation edge cases', () {
    test('should assert when params are missing', () {
      V.setLocale(
        const VLocale({'test_code': 'Hello {name}, your {missing}'}),
      );
      expect(
        () => V.t('test_code', {'name': 'World'}),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should handle empty params', () {
      V.setLocale(const VLocale({'test_code': 'Simple message'}));
      expect(V.t('test_code'), 'Simple message');
    });
  });

  group('factory-level message override (required error)', () {
    test('VString required error uses custom message', () {
      final schema = V.string(message: 'Name is required');
      final errs = schema.errors(null);
      expect(errs!.first.code, 'string.required');
      expect(errs.first.message, 'Name is required');
    });

    test('VBool required error uses custom message', () {
      final schema = V.bool(message: 'You must accept the terms');
      final errs = schema.errors(null);
      expect(errs!.first.message, 'You must accept the terms');
    });

    test('VInt required error uses custom message', () {
      final schema = V.int(message: 'Age is required');
      expect(schema.errors(null)!.first.message, 'Age is required');
    });

    test('VDouble required error uses custom message', () {
      final schema = V.double(message: 'Height needed');
      expect(schema.errors(null)!.first.message, 'Height needed');
    });

    test('VDate required error uses custom message', () {
      final schema = V.date(message: 'Birthday needed');
      expect(schema.errors(null)!.first.message, 'Birthday needed');
    });

    test('VMap required error uses custom message', () {
      final schema = V.map(
        {'name': V.string()},
        message: 'Payload missing',
      );
      expect(schema.errors(null)!.first.message, 'Payload missing');
    });

    test('VArray required error uses custom message', () {
      final schema = V.array(V.string(), message: 'List is required');
      expect(schema.errors(null)!.first.message, 'List is required');
    });

    test('VObject required error uses custom message', () {
      final schema = V.object<_Dummy>(message: 'Entity needed');
      expect(schema.errors(null)!.first.message, 'Entity needed');
    });

    test('custom message overrides locale global', () {
      V.setLocale(const VLocale({'required': 'Globally required'}));
      final schema = V.string(message: 'Name specifically required');
      expect(
        schema.errors(null)!.first.message,
        'Name specifically required',
      );
    });

    test('without message, locale is still used', () {
      V.setLocale(const VLocale({'required': 'Campo obrigatório'}));
      final schema = V.string();
      expect(schema.errors(null)!.first.message, 'Campo obrigatório');
    });

    test('message only applies to null input, not other errors', () {
      final schema = V.string(message: 'X').min(3, message: (_) => 'Too short');
      // null → custom required message
      expect(schema.errors(null)!.first.message, 'X');
      // 'ab' → min error, not required
      expect(schema.errors('ab')!.first.message, 'Too short');
    });

    test('does not apply when nullable() is set', () {
      final schema = V.string(message: 'X').nullable();
      expect(schema.validate(null), isTrue);
    });

    test('does not apply when defaultValue is set and input is null', () {
      final schema = V.string(message: 'X').defaultValue('fallback');
      expect(schema.parse(null), 'fallback');
    });
  });
}

class _Dummy {
  const _Dummy();
}
