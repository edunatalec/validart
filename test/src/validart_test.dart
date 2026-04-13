import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  group('Validart entry point', () {
    test('should create string schema', () {
      final v = Validart();
      final schema = v.string();
      expect(schema, isA<VString>());
      expect(schema.validate('hello'), isTrue);
    });

    test('should create int schema', () {
      final v = Validart();
      final schema = v.int();
      expect(schema, isA<VInt>());
      expect(schema.validate(42), isTrue);
    });

    test('should create double schema', () {
      final v = Validart();
      final schema = v.double();
      expect(schema, isA<VDouble>());
      expect(schema.validate(3.14), isTrue);
    });

    test('should create bool schema', () {
      final v = Validart();
      final schema = v.bool();
      expect(schema, isA<VBool>());
      expect(schema.validate(true), isTrue);
    });

    test('should create date schema', () {
      final v = Validart();
      final schema = v.date();
      expect(schema, isA<VDate>());
      expect(schema.validate(DateTime.now()), isTrue);
    });

    test('should create map schema', () {
      final v = Validart();
      final schema = v.map({
        'name': v.string()..min(1),
        'age': v.int()..min(0),
      });
      expect(schema, isA<VMap>());
      expect(schema.validate({'name': 'Alice', 'age': 25}), isTrue);
    });

    test('should create object schema', () {
      final v = Validart();
      final schema = v.object<_TestUser>();
      expect(schema, isA<VObject<_TestUser>>());
      expect(schema.validate(_TestUser('Alice')), isTrue);
    });

    test('should create array schema', () {
      final v = Validart();
      final schema = v.array(v.string()..email());
      expect(schema, isA<VArray<String>>());
      expect(schema.validate(['a@b.com']), isTrue);
    });

    test('should use custom messages', () {
      final v = Validart(
        messages: const VMessages(
          string: VStringMessages(email: 'Email inválido'),
        ),
      );
      final schema = v.string()..email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Email inválido');
    });
  });

  group('VCoerce', () {
    late Validart v;

    setUp(() {
      v = Validart();
    });

    group('int', () {
      test('should coerce string to int', () {
        final schema = v.coerce.int();
        expect(schema.parse('42'), 42);
      });

      test('should coerce double to int', () {
        final schema = v.coerce.int();
        expect(schema.parse(3.9), 3);
      });

      test('should coerce bool to int', () {
        final schema = v.coerce.int();
        expect(schema.parse(true), 1);
        expect(schema.parse(false), 0);
      });

      test('should pass int through', () {
        final schema = v.coerce.int();
        expect(schema.parse(42), 42);
      });

      test('should fail for non-coercible value', () {
        final schema = v.coerce.int();
        expect(schema.validate([1, 2, 3]), isFalse);
      });
    });

    group('double', () {
      test('should coerce string to double', () {
        final schema = v.coerce.double();
        expect(schema.parse('3.14'), 3.14);
      });

      test('should coerce int to double', () {
        final schema = v.coerce.double();
        expect(schema.parse(42), 42.0);
      });

      test('should coerce bool to double', () {
        final schema = v.coerce.double();
        expect(schema.parse(true), 1.0);
      });
    });

    group('string', () {
      test('should coerce int to string', () {
        final schema = v.coerce.string();
        expect(schema.parse(42), '42');
      });

      test('should coerce bool to string', () {
        final schema = v.coerce.string();
        expect(schema.parse(true), 'true');
      });
    });

    group('bool', () {
      test('should coerce string to bool', () {
        final schema = v.coerce.bool();
        expect(schema.parse('true'), isTrue);
        expect(schema.parse('false'), isFalse);
      });

      test('should coerce int to bool', () {
        final schema = v.coerce.bool();
        expect(schema.parse(1), isTrue);
        expect(schema.parse(0), isFalse);
      });
    });

    group('date', () {
      test('should coerce string to DateTime', () {
        final schema = v.coerce.date();
        final result = schema.parse('2024-01-15');
        expect(result, isA<DateTime>());
        expect(result!.year, 2024);
        expect(result.month, 1);
        expect(result.day, 15);
      });

      test('should pass DateTime through', () {
        final schema = v.coerce.date();
        final now = DateTime.now();
        expect(schema.parse(now), now);
      });

      test('should fail for invalid date string', () {
        final schema = v.coerce.date();
        expect(schema.validate('not-a-date'), isFalse);
      });
    });
  });
}

class _TestUser {
  final String name;
  _TestUser(this.name);
}
