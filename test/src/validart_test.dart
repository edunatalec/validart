import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('V entry point', () {
    test('should create string schema', () {
      final schema = V.string();
      expect(schema, isA<VString>());
      expect(schema.validate('hello'), isTrue);
    });

    test('should create int schema', () {
      final schema = V.int();
      expect(schema, isA<VInt>());
      expect(schema.validate(42), isTrue);
    });

    test('should create double schema', () {
      final schema = V.double();
      expect(schema, isA<VDouble>());
      expect(schema.validate(3.14), isTrue);
    });

    test('should create bool schema', () {
      final schema = V.bool();
      expect(schema, isA<VBool>());
      expect(schema.validate(true), isTrue);
    });

    test('should create date schema', () {
      final schema = V.date();
      expect(schema, isA<VDate>());
      expect(schema.validate(DateTime.now()), isTrue);
    });

    test('should create map schema', () {
      final schema = V.map({
        'name': V.string().min(1),
        'age': V.int().min(0),
      });
      expect(schema, isA<VMap>());
      expect(schema.validate({'name': 'Alice', 'age': 25}), isTrue);
    });

    test('should create object schema', () {
      final schema = V.object<_TestUser>();
      expect(schema, isA<VObject<_TestUser>>());
      expect(schema.validate(_TestUser('Alice')), isTrue);
    });

    test('should create array schema', () {
      final schema = V.array(V.string().email());
      expect(schema, isA<VArray<String>>());
      expect(schema.validate(['a@b.com']), isTrue);
    });

    test('should use custom messages via V.setLocale', () {
      V.setLocale(const VLocale({
        'invalid_email': 'Email inválido',
      }));
      final schema = V.string().email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Email inválido');
    });
  });

  group('VCoerce', () {
    group('int', () {
      test('should coerce string to int', () {
        final schema = V.coerce.int();
        expect(schema.parse('42'), 42);
      });

      test('should coerce double to int', () {
        final schema = V.coerce.int();
        expect(schema.parse(3.9), 3);
      });

      test('should coerce bool to int', () {
        final schema = V.coerce.int();
        expect(schema.parse(true), 1);
        expect(schema.parse(false), 0);
      });

      test('should pass int through', () {
        final schema = V.coerce.int();
        expect(schema.parse(42), 42);
      });

      test('should fail for non-coercible value', () {
        final schema = V.coerce.int();
        expect(schema.validate([1, 2, 3]), isFalse);
      });
    });

    group('double', () {
      test('should coerce string to double', () {
        final schema = V.coerce.double();
        expect(schema.parse('3.14'), 3.14);
      });

      test('should coerce int to double', () {
        final schema = V.coerce.double();
        expect(schema.parse(42), 42.0);
      });

      test('should coerce bool to double', () {
        final schema = V.coerce.double();
        expect(schema.parse(true), 1.0);
      });
    });

    group('string', () {
      test('should coerce int to string', () {
        final schema = V.coerce.string();
        expect(schema.parse(42), '42');
      });

      test('should coerce bool to string', () {
        final schema = V.coerce.string();
        expect(schema.parse(true), 'true');
      });
    });

    group('bool', () {
      test('should coerce string to bool', () {
        final schema = V.coerce.bool();
        expect(schema.parse('true'), isTrue);
        expect(schema.parse('false'), isFalse);
      });

      test('should coerce int to bool', () {
        final schema = V.coerce.bool();
        expect(schema.parse(1), isTrue);
        expect(schema.parse(0), isFalse);
      });
    });

    group('date', () {
      test('should coerce string to DateTime', () {
        final schema = V.coerce.date();
        final result = schema.parse('2024-01-15');
        expect(result, isA<DateTime>());
        expect(result!.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
      });

      test('should pass DateTime through', () {
        final schema = V.coerce.date();
        final now = DateTime.now();
        expect(schema.parse(now), now);
      });

      test('should fail for invalid date string', () {
        final schema = V.coerce.date();
        expect(schema.validate('not-a-date'), isFalse);
      });
    });
  });
}

class _TestUser {
  final String name;
  _TestUser(this.name);
}
