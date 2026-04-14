import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VMap', () {
    group('basic validation', () {
      test('should pass for valid map', () {
        final schema = VMap({
          'name': VString()..min(1),
          'age': VInt()..min(0),
        });
        expect(schema.validate({'name': 'Alice', 'age': 30}), isTrue);
      });

      test('should fail when a field is invalid', () {
        final schema = VMap({
          'name': VString()..min(3),
          'age': VInt()..min(0),
        });
        expect(schema.validate({'name': 'Al', 'age': 30}), isFalse);
      });

      test('should fail when required field is missing', () {
        final schema = VMap({
          'name': VString()..min(1),
          'age': VInt(),
        });
        expect(schema.validate({'name': 'Alice'}), isFalse);
      });

      test('should return parsed map via parse', () {
        final schema = VMap({
          'name': VString(),
        });
        final result = schema.parse({'name': 'Alice'});
        expect(result, {'name': 'Alice'});
      });
    });

    group('field-level errors', () {
      test('should include field name in error path', () {
        final schema = VMap({
          'name': VString()..min(3),
        });
        final errors = schema.errors({'name': 'Al'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'too_small');
        expect(errors.first.path, ['name']);
      });

      test('should return required error with path for missing field', () {
        final schema = VMap({
          'name': VString(),
          'email': VString()..email(),
        });
        final errors = schema.errors({'name': 'Alice'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'required');
        expect(errors.first.path, ['email']);
      });

      test('should return multiple field errors', () {
        final schema = VMap({
          'name': VString()..min(3),
          'age': VInt()..min(18),
        });
        final errors = schema.errors({'name': 'Al', 'age': 5});
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].path, ['name']);
        expect(errors[1].path, ['age']);
      });
    });

    group('nested maps', () {
      test('should validate nested map', () {
        final schema = VMap({
          'address': VMap({
            'zip': VString()..min(5),
          }),
        });
        expect(
          schema.validate({
            'address': {'zip': '12345'},
          }),
          isTrue,
        );
      });

      test('should produce nested error paths', () {
        final schema = VMap({
          'address': VMap({
            'zip': VString()..min(5),
          }),
        });
        final errors = schema.errors({
          'address': {'zip': '123'},
        });
        expect(errors, isNotNull);
        expect(errors!.first.path, ['address', 'zip']);
      });

      test('should produce deeply nested error paths', () {
        final schema = VMap({
          'user': VMap({
            'profile': VMap({
              'bio': VString()..min(10),
            }),
          }),
        });
        final errors = schema.errors({
          'user': {
            'profile': {'bio': 'short'},
          },
        });
        expect(errors, isNotNull);
        expect(errors!.first.path, ['user', 'profile', 'bio']);
      });
    });

    group('pick', () {
      test('should return new VMap with only picked keys', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
          'email': VString()..email(),
        });
        final picked = schema.pick(['name', 'email']);
        expect(picked.validate({'name': 'Alice', 'email': 'a@b.com'}), isTrue);
      });

      test('picked schema should not require omitted fields', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
        });
        final picked = schema.pick(['name']);
        expect(picked.validate({'name': 'Alice'}), isTrue);
      });

      test('should ignore non-existent keys', () {
        final schema = VMap({
          'name': VString(),
        });
        final picked = schema.pick(['name', 'nonexistent']);
        expect(picked.schema.keys, contains('name'));
        expect(picked.schema.keys, isNot(contains('nonexistent')));
      });
    });

    group('omit', () {
      test('should return new VMap without omitted keys', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
          'email': VString()..email(),
        });
        final omitted = schema.omit(['age']);
        expect(
          omitted.validate({'name': 'Alice', 'email': 'a@b.com'}),
          isTrue,
        );
      });

      test('omitted schema should not validate removed fields', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
        });
        final omitted = schema.omit(['age']);
        expect(omitted.validate({'name': 'Alice'}), isTrue);
      });
    });

    group('extend', () {
      test('should add new fields to schema', () {
        final schema = VMap({'name': VString()});
        final extended = schema.extend({'age': VInt()});
        expect(extended.validate({'name': 'Alice', 'age': 30}), isTrue);
      });

      test('extended schema should require new fields', () {
        final schema = VMap({'name': VString()});
        final extended = schema.extend({'age': VInt()});
        expect(extended.validate({'name': 'Alice'}), isFalse);
      });
    });

    group('merge', () {
      test('should merge two VMap schemas', () {
        final schema1 = VMap({'name': VString()});
        final schema2 = VMap({'age': VInt()});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Alice', 'age': 30}), isTrue);
      });

      test('merged schema should require fields from both', () {
        final schema1 = VMap({'name': VString()});
        final schema2 = VMap({'age': VInt()});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Alice'}), isFalse);
      });

      test('merge should override duplicate keys with other schema', () {
        final schema1 = VMap({'name': VString()..min(1)});
        final schema2 = VMap({'name': VString()..min(5)});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Al'}), isFalse);
      });
    });

    group('partial', () {
      test('should make all fields optional', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
        });
        final partial = schema.partial();
        expect(partial.validate(<String, dynamic>{}), isTrue);
      });

      test('partial should still validate provided fields', () {
        final schema = VMap({
          'name': VString()..min(3),
          'age': VInt()..min(0),
        });
        final partial = schema.partial();
        expect(partial.validate({'name': 'Al'}), isFalse);
      });

      test('partial should accept missing fields', () {
        final schema = VMap({
          'name': VString(),
          'age': VInt(),
        });
        final partial = schema.partial();
        expect(partial.validate({'name': 'Alice'}), isTrue);
      });
    });

    group('strict', () {
      test('should reject unknown keys', () {
        final schema = VMap({'name': VString()})..strict();
        expect(
          schema.validate({'name': 'Alice', 'extra': 'value'}),
          isFalse,
        );
      });

      test('should return unrecognized_key error', () {
        final schema = VMap({'name': VString()})..strict();
        final errors = schema.errors({'name': 'Alice', 'extra': 'value'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'unrecognized_key');
        expect(errors.first.path, ['extra']);
      });

      test('should pass when no unknown keys', () {
        final schema = VMap({'name': VString()})..strict();
        expect(schema.validate({'name': 'Alice'}), isTrue);
      });

      test('should report multiple unknown keys', () {
        final schema = VMap({'name': VString()})..strict();
        final errors = schema.errors({
          'name': 'Alice',
          'foo': 1,
          'bar': 2,
        });
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'unrecognized_key');
        expect(errors[1].code, 'unrecognized_key');
      });
    });

    group('passthrough', () {
      test('should pass through unknown keys', () {
        final schema = VMap({'name': VString()})..passthrough();
        final result = schema.parse({'name': 'Alice', 'extra': 'value'});
        expect(result!['name'], 'Alice');
        expect(result['extra'], 'value');
      });

      test('should still validate known fields', () {
        final schema = VMap({'name': VString()..min(3)})..passthrough();
        expect(
          schema.validate({'name': 'Al', 'extra': 'value'}),
          isFalse,
        );
      });

      test('should include unknown keys in parsed output', () {
        final schema = VMap({'name': VString()})..passthrough();
        final result = schema.parse({
          'name': 'Alice',
          'age': 30,
          'active': true,
        });
        expect(result!.keys, containsAll(['name', 'age', 'active']));
      });
    });

    group('refineField', () {
      test('should validate cross-field constraint', () {
        final schema = VMap({
          'password': VString()..min(6),
          'confirm': VString()..min(6),
        })
          ..refineField(
            (data) => data['password'] == data['confirm'],
            path: 'confirm',
            message: 'Passwords must match',
          );
        expect(
          schema.validate({
            'password': 'secret123',
            'confirm': 'secret123',
          }),
          isTrue,
        );
      });

      test('should fail cross-field constraint', () {
        final schema = VMap({
          'password': VString()..min(6),
          'confirm': VString()..min(6),
        })
          ..refineField(
            (data) => data['password'] == data['confirm'],
            path: 'confirm',
            message: 'Passwords must match',
          );
        expect(
          schema.validate({
            'password': 'secret123',
            'confirm': 'different',
          }),
          isFalse,
        );
      });

      test('should return custom error for failed cross-field', () {
        final schema = VMap({
          'password': VString()..min(6),
          'confirm': VString()..min(6),
        })
          ..refineField(
            (data) => data['password'] == data['confirm'],
            path: 'confirm',
            message: 'Passwords must match',
          );
        final errors = schema.errors({
          'password': 'secret123',
          'confirm': 'different',
        });
        expect(errors, isNotNull);
        expect(errors!.first.code, 'custom');
        expect(errors.first.message, 'Passwords must match');
      });
    });

    group('null handling', () {
      test('should fail for null by default', () {
        final schema = VMap({'name': VString()});
        expect(schema.validate(null), isFalse);
      });

      test('should return required error for null', () {
        final schema = VMap({'name': VString()});
        final errors = schema.errors(null);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'required');
      });

      test('nullable should allow null', () {
        final schema = VMap({'name': VString()})..nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should parse null to null', () {
        final schema = VMap({'name': VString()})..nullable();
        expect(schema.parse(null), isNull);
      });

      test('optional should allow null', () {
        final schema = VMap({'name': VString()})..optional();
        expect(schema.validate(null), isTrue);
      });
    });

    group('type checking', () {
      test('should fail for non-map input', () {
        final schema = VMap({'name': VString()});
        expect(schema.validate('not a map'), isFalse);
      });

      test('should return invalid_type error for non-map input', () {
        final schema = VMap({'name': VString()});
        final errors = schema.errors('not a map');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'invalid_type');
      });

      test('should fail for list input', () {
        final schema = VMap({'name': VString()});
        expect(schema.validate([1, 2, 3]), isFalse);
      });
    });
  });
}
