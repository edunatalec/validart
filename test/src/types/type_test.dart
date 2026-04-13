import 'package:test/test.dart';
import 'package:validart/src/error.dart';
import 'package:validart/src/result.dart';
import 'package:validart/src/types/type.dart';

class TestStringType extends VType<String> {}

void main() {
  group('VType base', () {
    group('parse', () {
      test('should return value when valid', () {
        final schema = TestStringType();
        expect(schema.parse('hello'), 'hello');
      });

      test('should throw VException when null', () {
        final schema = TestStringType();
        expect(() => schema.parse(null), throwsA(isA<VException>()));
      });

      test('should throw VException when wrong type', () {
        final schema = TestStringType();
        expect(() => schema.parse(123), throwsA(isA<VException>()));
      });
    });

    group('safeParse', () {
      test('should return VSuccess when valid', () {
        final schema = TestStringType();
        final result = schema.safeParse('hello');
        expect(result, isA<VSuccess<String?>>());
        expect((result as VSuccess<String?>).value, 'hello');
      });

      test('should return VFailure with required error when null', () {
        final schema = TestStringType();
        final result = schema.safeParse(null);
        expect(result, isA<VFailure<String?>>());

        final errors = (result as VFailure<String?>).errors;
        expect(errors.length, 1);
        expect(errors.first.code, 'required');
      });

      test('should return VFailure with invalid_type when wrong type', () {
        final schema = TestStringType();
        final result = schema.safeParse(123);
        expect(result, isA<VFailure<String?>>());

        final errors = (result as VFailure<String?>).errors;
        expect(errors.length, 1);
        expect(errors.first.code, 'invalid_type');
      });
    });

    group('validate', () {
      test('should return true when valid', () {
        final schema = TestStringType();
        expect(schema.validate('hello'), isTrue);
      });

      test('should return false when null', () {
        final schema = TestStringType();
        expect(schema.validate(null), isFalse);
      });

      test('should return false when wrong type', () {
        final schema = TestStringType();
        expect(schema.validate(42), isFalse);
      });
    });

    group('errors', () {
      test('should return null when valid', () {
        final schema = TestStringType();
        expect(schema.errors('hello'), isNull);
      });

      test('should return error list when invalid', () {
        final schema = TestStringType();
        final errs = schema.errors(null);
        expect(errs, isNotNull);
        expect(errs!.length, 1);
        expect(errs.first.code, 'required');
      });
    });

    group('optional', () {
      test('should allow null when optional', () {
        final schema = TestStringType()..optional();
        expect(schema.validate(null), isTrue);
      });

      test('should still validate type when optional', () {
        final schema = TestStringType()..optional();
        expect(schema.validate('hello'), isTrue);
      });
    });

    group('nullable', () {
      test('should allow null when nullable', () {
        final schema = TestStringType()..nullable();
        expect(schema.validate(null), isTrue);
        expect(schema.parse(null), isNull);
      });

      test('should still validate type when nullable', () {
        final schema = TestStringType()..nullable();
        expect(schema.validate('hello'), isTrue);
      });
    });

    group('defaultValue', () {
      test('should use default when value is null', () {
        final schema = TestStringType()..defaultValue('fallback');
        expect(schema.parse(null), 'fallback');
      });

      test('should not use default when value is provided', () {
        final schema = TestStringType()..defaultValue('fallback');
        expect(schema.parse('hello'), 'hello');
      });
    });

    group('refine', () {
      test('should pass when refine returns true', () {
        final schema = TestStringType()
          ..refine((v) => v.length >= 3, message: 'Too short');
        expect(schema.validate('hello'), isTrue);
      });

      test('should fail when refine returns false', () {
        final schema = TestStringType()
          ..refine((v) => v.length >= 3, message: 'Too short');
        expect(schema.validate('hi'), isFalse);

        final errs = schema.errors('hi');
        expect(errs!.first.message, 'Too short');
        expect(errs.first.code, 'custom');
      });

      test('should use custom code', () {
        final schema = TestStringType()
          ..refine((v) => v.isNotEmpty,
              code: 'not_empty', message: 'Cannot be empty');
        final errs = schema.errors('');
        expect(errs!.first.code, 'not_empty');
      });

      test('should collect multiple refine errors', () {
        final schema = TestStringType()
          ..refine((v) => v.length >= 3, message: 'Too short')
          ..refine((v) => v.contains('@'), message: 'Must contain @');
        final errs = schema.errors('hi');
        expect(errs!.length, 2);
      });
    });
  });

  group('VResult', () {
    test('VSuccess isValid should be true', () {
      const result = VSuccess<String>('test');
      expect(result.isValid, isTrue);
      expect(result.isNotValid, isFalse);
      expect(result.value, 'test');
    });

    test('VFailure isValid should be false', () {
      const result = VFailure<String>([
        VError(code: 'test', message: 'test error'),
      ]);
      expect(result.isValid, isFalse);
      expect(result.isNotValid, isTrue);
      expect(result.errors.length, 1);
    });

    test('should work with pattern matching', () {
      const VResult<String> result = VSuccess('hello');
      final value = switch (result) {
        VSuccess(:final value) => value,
        VFailure() => 'error',
      };
      expect(value, 'hello');
    });
  });

  group('VError', () {
    test('pathString should format correctly', () {
      expect(
        const VError(code: 'test', message: 'msg', path: ['address', 'zip'])
            .pathString,
        'address.zip',
      );
      expect(
        const VError(code: 'test', message: 'msg', path: ['items', 2, 'name'])
            .pathString,
        'items[2].name',
      );
      expect(
        const VError(code: 'test', message: 'msg', path: [0]).pathString,
        '[0]',
      );
      expect(
        const VError(code: 'test', message: 'msg').pathString,
        '',
      );
    });

    test('equality should work', () {
      const a = VError(code: 'test', message: 'msg', path: ['a']);
      const b = VError(code: 'test', message: 'msg', path: ['a']);
      const c = VError(code: 'test', message: 'msg', path: ['b']);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString should include path when present', () {
      const error =
          VError(code: 'required', message: 'Required', path: ['name']);
      expect(error.toString(), contains('name'));
      expect(error.toString(), contains('required'));
    });

    test('toString should work without path', () {
      const error = VError(code: 'required', message: 'Required');
      expect(error.toString(), 'VError(required: Required)');
    });
  });

  group('VException', () {
    test('toString should list all errors', () {
      const ex = VException([
        VError(code: 'a', message: 'error a'),
        VError(code: 'b', message: 'error b'),
      ]);
      expect(ex.toString(), contains('error a'));
      expect(ex.toString(), contains('error b'));
    });
  });
}
