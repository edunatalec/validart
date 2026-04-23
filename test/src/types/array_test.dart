import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VArray', () {
    group('basic validation', () {
      test('should pass for valid list of strings', () {
        final schema = VArray<String>(VString());
        expect(schema.validate(['hello', 'world']), isTrue);
      });

      test('should pass for empty list', () {
        final schema = VArray<String>(VString());
        expect(schema.validate([]), isTrue);
      });

      test('should pass for valid list of ints', () {
        final schema = VArray<int>(VInt());
        expect(schema.validate([1, 2, 3]), isTrue);
      });

      test('should return parsed list via parse', () {
        final schema = VArray<String>(VString());
        expect(schema.parse(['a', 'b']), ['a', 'b']);
      });
    });

    group('element validation', () {
      test('should fail when element is invalid', () {
        final schema = VArray<String>(VString().email());
        expect(schema.validate(['not-an-email']), isFalse);
      });

      test('should include index in error path', () {
        final schema = VArray<String>(VString().email());
        final errors = schema.errors(['valid@email.com', 'bad', 'also-bad']);
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'string.email');
        expect(errors[0].path, [1]);
        expect(errors[1].code, 'string.email');
        expect(errors[1].path, [2]);
      });

      test('should validate all elements with min constraint', () {
        final schema = VArray<String>(VString().min(3));
        final errors = schema.errors(['ab', 'abc', 'a']);
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].path, [0]);
        expect(errors[1].path, [2]);
      });

      test('should pass when all elements satisfy schema', () {
        final schema = VArray<String>(VString().email());
        expect(schema.validate(['a@b.com', 'c@d.com']), isTrue);
      });
    });

    group('min', () {
      test('should pass when array length >= min', () {
        final schema = VArray<String>(VString()).min(2);
        expect(schema.validate(['a', 'b']), isTrue);
      });

      test('should pass when array length > min', () {
        final schema = VArray<String>(VString()).min(2);
        expect(schema.validate(['a', 'b', 'c']), isTrue);
      });

      test('should fail when array length < min', () {
        final schema = VArray<String>(VString()).min(3);
        expect(schema.validate(['a']), isFalse);
      });

      test('should return error code array.too_small', () {
        final schema = VArray<String>(VString()).min(2);
        final errors = schema.errors(['a']);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.too_small');
      });

      test('should support custom message', () {
        final schema = VArray<String>(VString())
            .min(2, message: (len) => 'Need $len items');
        final errors = schema.errors(['a']);
        expect(errors!.first.message, 'Need 2 items');
      });
    });

    group('max', () {
      test('should pass when array length <= max', () {
        final schema = VArray<String>(VString()).max(3);
        expect(schema.validate(['a', 'b', 'c']), isTrue);
      });

      test('should pass when array length < max', () {
        final schema = VArray<String>(VString()).max(3);
        expect(schema.validate(['a']), isTrue);
      });

      test('should fail when array length > max', () {
        final schema = VArray<String>(VString()).max(2);
        expect(schema.validate(['a', 'b', 'c']), isFalse);
      });

      test('should return error code array.too_big', () {
        final schema = VArray<String>(VString()).max(1);
        final errors = schema.errors(['a', 'b']);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.too_big');
      });

      test('should support custom message', () {
        final schema =
            VArray<String>(VString()).max(1, message: (len) => 'Max $len');
        final errors = schema.errors(['a', 'b']);
        expect(errors!.first.message, 'Max 1');
      });
    });

    group('array.unique', () {
      final schema = VArray<String>(VString()).unique();

      test('should pass when all elements are unique', () {
        expect(schema.validate(['a', 'b', 'c']), isTrue);
      });

      test('should fail when there are duplicates', () {
        expect(schema.validate(['a', 'b', 'a']), isFalse);
      });

      test('should return error code array.unique', () {
        final errors = schema.errors(['x', 'x']);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.unique');
      });

      test('should support custom message', () {
        final custom = VArray<String>(VString()).unique(message: 'No dupes');
        final errors = custom.errors(['x', 'x']);
        expect(errors!.first.message, 'No dupes');
      });

      test('should pass for empty list', () {
        expect(schema.validate([]), isTrue);
      });
    });

    group('contains', () {
      test('should pass when array contains required values', () {
        final schema = VArray<String>(VString()).contains(['a', 'b']);
        expect(schema.validate(['a', 'b', 'c']), isTrue);
      });

      test('should fail when array is missing required values', () {
        final schema = VArray<String>(VString()).contains(['a', 'b']);
        expect(schema.validate(['a', 'c']), isFalse);
      });

      test('should return error code array.contains_all', () {
        final schema = VArray<String>(VString()).contains(['x']);
        final errors = schema.errors(['a', 'b']);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.contains_all');
      });

      test('should support custom message', () {
        final schema =
            VArray<String>(VString()).contains(['x'], message: 'Must have x');
        final errors = schema.errors(['a']);
        expect(errors!.first.message, 'Must have x');
      });
    });

    group('type checking', () {
      final schema = VArray<String>(VString());

      test('should fail for non-list input', () {
        expect(schema.validate('not a list'), isFalse);
      });

      test('should return invalid_type error for non-list input', () {
        final errors = schema.errors('not a list');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.invalid_type');
      });

      test('should fail for int input', () {
        expect(schema.validate(42), isFalse);
      });

      test('should fail for map input', () {
        expect(schema.validate({'key': 'value'}), isFalse);
      });
    });

    group('null handling', () {
      test('should fail for null by default', () {
        final schema = VArray<String>(VString());
        expect(schema.validate(null), isFalse);
      });

      test('should return required error for null', () {
        final schema = VArray<String>(VString());
        final errors = schema.errors(null);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'array.required');
      });

      test('nullable should allow null', () {
        final schema = VArray<String>(VString()).nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should parse null to null', () {
        final schema = VArray<String>(VString()).nullable();
        expect(schema.parse(null), isNull);
      });

      test('nullable should allow null', () {
        final schema = VArray<String>(VString()).nullable();
        expect(schema.validate(null), isTrue);
      });

      test('defaultValue should return default when null', () {
        final schema = VArray<String>(VString()).defaultValue(['fallback']);
        expect(schema.parse(null), ['fallback']);
      });
    });

    group('method chaining', () {
      test('should chain min and unique', () {
        final schema = VArray<String>(VString()).min(1).unique();
        expect(schema.validate(['a', 'b']), isTrue);
        expect(schema.validate([]), isFalse);
        expect(schema.validate(['a', 'a']), isFalse);
      });

      test('should create array from VString().array()', () {
        final schema = VString().email();
        final arraySchema = schema.array();
        expect(arraySchema.validate(['a@b.com']), isTrue);
        expect(arraySchema.validate(['bad']), isFalse);
      });

      test('should chain array() with min and unique', () {
        final stringSchema = VString().email();
        final schema = stringSchema.array().min(1).unique();
        expect(schema.validate(['a@b.com', 'c@d.com']), isTrue);
        expect(schema.validate([]), isFalse);
      });

      test('should combine min and max', () {
        final schema = VArray<String>(VString()).min(1).max(3);
        expect(schema.validate(['a', 'b']), isTrue);
        expect(schema.validate([]), isFalse);
        expect(schema.validate(['a', 'b', 'c', 'd']), isFalse);
      });

      test('should collect multiple errors', () {
        final schema = VArray<String>(VString()).min(5).unique();
        final errors = schema.errors(['a', 'a']);
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'array.too_small');
        expect(errors[1].code, 'array.unique');
      });
    });

    group('nested arrays', () {
      test('should validate array of arrays', () {
        final schema = VArray<List<String>>(VArray<String>(VString()));
        expect(
          schema.validate([
            ['a', 'b'],
            ['c', 'd'],
          ]),
          isTrue,
        );
      });

      test('should fail for invalid nested element', () {
        final schema = VArray<List<String>>(
          VArray<String>(VString().email()),
        );
        expect(
          schema.validate([
            ['a@b.com'],
            ['bad'],
          ]),
          isFalse,
        );
      });

      test('should include nested index in error path', () {
        final schema = VArray<List<String>>(
          VArray<String>(VString().email()),
        );
        final errors = schema.errors([
          ['a@b.com'],
          ['bad'],
        ]);
        expect(errors, isNotNull);
        expect(errors!.first.path, [1, 0]);
      });
    });

    group('refine', () {
      test('should add custom validation', () {
        final schema = VArray<int>(VInt()).refine(
          (v) => v.fold<int>(0, (a, b) => a + b) <= 10,
          message: 'Sum must be <= 10',
          code: 'max_sum',
        );
        expect(schema.validate([1, 2, 3]), isTrue);
        expect(schema.validate([5, 6]), isFalse);
      });
    });

    group('coerced elements', () {
      final schema = V.coerce.int().array();

      test('should coerce string elements to int', () {
        expect(schema.parse(['1', '2', '3']), [1, 2, 3]);
      });

      test('should coerce mixed types to int', () {
        expect(schema.parse([1, '2', 3.7]), [1, 2, 3]);
      });
    });

    group('nullable element', () {
      test('VArray<String?> with nullable element accepts null entries', () {
        final schema = VArray<String?>(V.string().nullable());
        expect(schema.validate(['ok', null, 'also']), isTrue);
      });
    });
  });
}
