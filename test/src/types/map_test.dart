import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';
import 'package:validart/src/validators/string/postal_code_pattern.dart';

enum _Role { admin, user, guest }

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VMap', () {
    group('basic validation', () {
      test('should pass for valid map', () {
        final schema = VMap({
          'name': VString().min(1),
          'date.age': VInt().min(0),
        });
        expect(schema.validate({'name': 'Alice', 'date.age': 30}), isTrue);
      });

      test('should fail when a field is invalid', () {
        final schema = VMap({
          'name': VString().min(3),
          'date.age': VInt().min(0),
        });
        expect(schema.validate({'name': 'Al', 'date.age': 30}), isFalse);
      });

      test('should fail when required field is missing', () {
        final schema = VMap({
          'name': VString().min(1),
          'date.age': VInt(),
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
          'name': VString().min(3),
        });
        final errors = schema.errors({'name': 'Al'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'string.too_small');
        expect(errors.first.path, ['name']);
      });

      test('should return required error with path for missing field', () {
        final schema = VMap({
          'name': VString(),
          'email': VString().email(),
        });
        final errors = schema.errors({'name': 'Alice'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'string.required');
        expect(errors.first.path, ['email']);
      });

      test('should return multiple field errors', () {
        final schema = VMap({
          'name': VString().min(3),
          'date.age': VInt().min(18),
        });
        final errors = schema.errors({'name': 'Al', 'date.age': 5});
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].path, ['name']);
        expect(errors[1].path, ['date.age']);
      });
    });

    group('nested maps', () {
      test('should validate nested map', () {
        final schema = VMap({
          'address': VMap({
            'zip': VString().min(5),
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
            'zip': VString().min(5),
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
              'bio': VString().min(10),
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
          'date.age': VInt(),
          'email': VString().email(),
        });
        final picked = schema.pick(['name', 'email']);
        expect(picked.validate({'name': 'Alice', 'email': 'a@b.com'}), isTrue);
      });

      test('picked schema should not require omitted fields', () {
        final schema = VMap({
          'name': VString(),
          'date.age': VInt(),
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
          'date.age': VInt(),
          'email': VString().email(),
        });
        final omitted = schema.omit(['date.age']);
        expect(
          omitted.validate({'name': 'Alice', 'email': 'a@b.com'}),
          isTrue,
        );
      });

      test('omitted schema should not validate removed fields', () {
        final schema = VMap({
          'name': VString(),
          'date.age': VInt(),
        });
        final omitted = schema.omit(['date.age']);
        expect(omitted.validate({'name': 'Alice'}), isTrue);
      });
    });

    group('extend', () {
      test('should add new fields to schema', () {
        final schema = VMap({'name': VString()});
        final extended = schema.extend({'date.age': VInt()});
        expect(extended.validate({'name': 'Alice', 'date.age': 30}), isTrue);
      });

      test('extended schema should require new fields', () {
        final schema = VMap({'name': VString()});
        final extended = schema.extend({'date.age': VInt()});
        expect(extended.validate({'name': 'Alice'}), isFalse);
      });

      test('extend should preserve equalFields from base', () {
        final base = VMap({
          'password': VString(),
          'confirm': VString(),
        }).equalFields('password', 'confirm');

        final extended = base.extend({'email': VString()});

        expect(
          extended.validate({
            'password': 'a',
            'confirm': 'b',
            'email': 'x@y.com',
          }),
          isFalse,
        );
      });

      test('extend should preserve strict flag from base', () {
        final base = VMap({'name': VString()}).strict();
        final extended = base.extend({'date.age': VInt()});

        expect(
          extended.validate({'name': 'Alice', 'date.age': 30, 'extra': true}),
          isFalse,
        );
      });

      test('extend should preserve when rules from base', () {
        final base = VMap({
          'type': VString(),
          'cnpj': VString().nullable(),
        }).when('type', equals: 'company', then: {
          'cnpj': VString().min(14),
        });

        final extended = base.extend({'email': VString()});

        expect(
          extended.validate({
            'type': 'company',
            'cnpj': 'short',
            'email': 'x@y.com',
          }),
          isFalse,
        );
      });
    });

    group('merge', () {
      test('should merge two VMap schemas', () {
        final schema1 = VMap({'name': VString()});
        final schema2 = VMap({'date.age': VInt()});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Alice', 'date.age': 30}), isTrue);
      });

      test('merged schema should require fields from both', () {
        final schema1 = VMap({'name': VString()});
        final schema2 = VMap({'date.age': VInt()});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Alice'}), isFalse);
      });

      test('merge should override duplicate keys with other schema', () {
        final schema1 = VMap({'name': VString().min(1)});
        final schema2 = VMap({'name': VString().min(5)});
        final merged = schema1.merge(schema2);
        expect(merged.validate({'name': 'Al'}), isFalse);
      });

      test('merge should preserve equalFields from either side', () {
        final a = VMap({
          'password': VString(),
          'confirm': VString(),
        }).equalFields('password', 'confirm');
        final b = VMap({'email': VString()});

        final merged = a.merge(b);

        expect(
          merged.validate({
            'password': 'a',
            'confirm': 'b',
            'email': 'x@y.com',
          }),
          isFalse,
        );
      });

      test('merge should concatenate when rules from both sides', () {
        final a = VMap({
          'type': VString(),
          'cnpj': VString().nullable(),
        }).when('type', equals: 'company', then: {
          'cnpj': VString().min(14),
        });

        final b = VMap({
          'role': VString(),
          'permissions': VString().nullable(),
        }).when('role', equals: 'admin', then: {
          'permissions': VString().min(1),
        });

        final merged = a.merge(b);

        expect(
          merged.validate({
            'type': 'company',
            'cnpj': 'short',
            'role': 'user',
            'permissions': null,
          }),
          isFalse,
        );

        expect(
          merged.validate({
            'type': 'individual',
            'cnpj': null,
            'role': 'admin',
            'permissions': null,
          }),
          isFalse,
        );
      });
    });

    group('partial', () {
      test('should make all fields optional', () {
        final schema = VMap({
          'name': VString(),
          'date.age': VInt(),
        });
        final partial = schema.partial();
        expect(partial.validate(<String, dynamic>{}), isTrue);
      });

      test('partial should still validate provided fields', () {
        final schema = VMap({
          'name': VString().min(3),
          'date.age': VInt().min(0),
        });
        final partial = schema.partial();
        expect(partial.validate({'name': 'Al'}), isFalse);
      });

      test('partial should accept missing fields', () {
        final schema = VMap({
          'name': VString(),
          'date.age': VInt(),
        });
        final partial = schema.partial();
        expect(partial.validate({'name': 'Alice'}), isTrue);
      });

      test('partial should not mutate the original schema', () {
        final base = VMap({'name': VString(), 'date.age': VInt()});

        base.partial();

        expect(base.validate({'name': null, 'date.age': 10}), isFalse);
        expect(base.validate({'name': 'Alice', 'date.age': null}), isFalse);
      });

      test('partial(except:) keeps listed keys with original validator', () {
        final schema = VMap({
          'id': VString().uuid(),
          'name': VString().min(1),
          'email': VString().email(),
        });

        final partial = schema.partial(
          except: const ['id'],
        );

        expect(
          partial.validate({'id': '123e4567-e89b-12d3-a456-426614174000'}),
          isTrue,
        );
        expect(partial.validate(<String, dynamic>{'name': 'Alice'}), isFalse);
        expect(
          partial.validate({
            'id': '123e4567-e89b-12d3-a456-426614174000',
            'name': null,
            'email': null,
          }),
          isTrue,
        );
      });

      test('partial(except:) preserves the original validator on kept keys',
          () {
        final schema = VMap({
          'id': VString().uuid(),
          'name': VString().min(1),
        });

        final partial = schema.partial(except: const ['id']);

        expect(partial.validate({'id': 'not-a-uuid'}), isFalse);
      });

      test('partial(except: const []) is equivalent to partial()', () {
        final schema = VMap({
          'name': VString().min(1),
          'age': VInt().min(0),
        });

        final partialAll = schema.partial();
        final partialEmpty = schema.partial(except: const []);

        final probe = <String, dynamic>{'name': null, 'age': null};

        expect(partialAll.validate(probe), isTrue);
        expect(partialEmpty.validate(probe), isTrue);
      });

      test('partial(except:) does not mutate the source schema', () {
        final base = VMap({
          'id': VString().uuid(),
          'name': VString().min(1),
        });

        base.partial(except: const ['id']);

        expect(base.validate({'id': null, 'name': 'Alice'}), isFalse);
      });

      test('partial(except:) preserves entity-level rules from the base', () {
        final base = VMap({
          'email': VString().email(),
          'password': VString(),
          'confirm': VString(),
        }).equalFields('password', 'confirm');

        final partial = base.partial(except: const ['email']);

        expect(
          partial.validate({
            'email': 'a@b.com',
            'password': 'pwd',
            'confirm': 'pwd',
          }),
          isTrue,
        );
        expect(
          partial.validate({
            'email': 'a@b.com',
            'password': 'pwd',
            'confirm': 'mismatch',
          }),
          isFalse,
          reason: 'equalFields rule must survive partial(except:)',
        );
      });

      test('partial(except:) asserts on undeclared keys (debug)', () {
        final schema = VMap({'name': VString()});

        expect(
          () => schema.partial(except: const ['unknown']),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('strict', () {
      test('should reject unknown keys', () {
        final schema = VMap({'name': VString()}).strict();
        expect(
          schema.validate({'name': 'Alice', 'extra': 'value'}),
          isFalse,
        );
      });

      test('should return unrecognized_key error', () {
        final schema = VMap({'name': VString()}).strict();
        final errors = schema.errors({'name': 'Alice', 'extra': 'value'});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'map.unrecognized_key');
        expect(errors.first.path, ['extra']);
      });

      test('should pass when no unknown keys', () {
        final schema = VMap({'name': VString()}).strict();
        expect(schema.validate({'name': 'Alice'}), isTrue);
      });

      test('should report multiple unknown keys', () {
        final schema = VMap({'name': VString()}).strict();
        final errors = schema.errors({
          'name': 'Alice',
          'foo': 1,
          'bar': 2,
        });
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].code, 'map.unrecognized_key');
        expect(errors[1].code, 'map.unrecognized_key');
      });
    });

    group('passthrough', () {
      test('should pass through unknown keys', () {
        final schema = VMap({'name': VString()}).passthrough();
        final result = schema.parse({'name': 'Alice', 'extra': 'value'});
        expect(result!['name'], 'Alice');
        expect(result['extra'], 'value');
      });

      test('should still validate known fields', () {
        final schema = VMap({'name': VString().min(3)}).passthrough();
        expect(
          schema.validate({'name': 'Al', 'extra': 'value'}),
          isFalse,
        );
      });

      test('should include unknown keys in parsed output', () {
        final schema = VMap({'name': VString()}).passthrough();
        final result = schema.parse({
          'name': 'Alice',
          'date.age': 30,
          'active': true,
        });
        expect(result!.keys, containsAll(['name', 'date.age', 'active']));
      });
    });

    group('refineField', () {
      test('should validate cross-field constraint', () {
        final schema = VMap({
          'password': VString().min(6),
          'confirm': VString().min(6),
        }).refineField(
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
          'password': VString().min(6),
          'confirm': VString().min(6),
        }).refineField(
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
          'password': VString().min(6),
          'confirm': VString().min(6),
        }).refineField(
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

      test('should attach error to the specified path', () {
        final schema = VMap({
          'password': VString().min(6),
          'confirm': VString().min(6),
        }).refineField(
          (data) => data['password'] == data['confirm'],
          path: 'confirm',
          message: 'Passwords must match',
        );

        final errors = schema.errors({
          'password': 'secret123',
          'confirm': 'different',
        });

        expect(errors!.first.path, ['confirm']);
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
        expect(errors!.first.code, 'map.required');
      });

      test('nullable should allow null', () {
        final schema = VMap({'name': VString()}).nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should parse null to null', () {
        final schema = VMap({'name': VString()}).nullable();
        expect(schema.parse(null), isNull);
      });

      test('nullable should allow null', () {
        final schema = VMap({'name': VString()}).nullable();
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
        expect(errors!.first.code, 'map.invalid_type');
      });

      test('should fail for list input', () {
        final schema = VMap({'name': VString()});
        expect(schema.validate([1, 2, 3]), isFalse);
      });
    });

    group('array', () {
      test('should create array of maps', () {
        final schema = VMap({'name': VString().min(1)}).array();
        expect(
          schema.validate([
            {'name': 'Alice'},
            {'name': 'Bob'},
          ]),
          isTrue,
        );
      });

      test('should fail for invalid map in array', () {
        final schema = VMap({'name': VString().min(1)}).array();
        expect(
          schema.validate([
            {'name': 'Alice'},
            {'name': ''},
          ]),
          isFalse,
        );
      });

      test('should include index in error path', () {
        final schema = VMap({'name': VString().min(3)}).array();
        final errs = schema.errors([
          {'name': 'Al'},
        ]);
        expect(errs!.first.path, [0, 'name']);
      });
    });

    group('equalFields', () {
      test('should pass when fields match', () {
        final schema = VMap({
          'password': VString(),
          'confirm': VString(),
        }).equalFields('confirm', 'password');

        expect(
          schema.validate({'password': 'abc', 'confirm': 'abc'}),
          isTrue,
        );
      });

      test('should fail when fields differ', () {
        final schema = VMap({
          'password': VString(),
          'confirm': VString(),
        }).equalFields('confirm', 'password');

        expect(
          schema.validate({'password': 'abc', 'confirm': 'xyz'}),
          isFalse,
        );
      });

      test('should use custom message', () {
        final schema = VMap({
          'password': VString(),
          'confirm': VString(),
        }).equalFields('confirm', 'password', message: 'Must match');

        final errs = schema.errors({'password': 'a', 'confirm': 'b'});
        expect(errs!.first.message, 'Must match');
      });
    });

    group('when', () {
      test('should apply validation when condition matches', () {
        final schema = VMap({
          'type': VString(),
          'value': VString().nullable(),
        }).when('type', equals: 'special', then: {
          'value': VString().min(5),
        });

        expect(
          schema.validate({'type': 'special', 'value': 'hello'}),
          isTrue,
        );
        expect(
          schema.validate({'type': 'special', 'value': 'hi'}),
          isFalse,
        );
      });

      test('should skip validation when condition does not match', () {
        final schema = VMap({
          'type': VString(),
          'value': VString().nullable(),
        }).when('type', equals: 'special', then: {
          'value': VString().min(5),
        });

        expect(
          schema.validate({'type': 'normal', 'value': 'hi'}),
          isTrue,
        );
      });

      test('should fire when equals: null and the field reads as null', () {
        // Mirrors VObject's `equals: null fires when extractor returns null`.
        // A missing key in a Dart map reads as null, so the rule fires
        // for both explicit-null and missing-key inputs.
        final schema = V.map({
          'kind': V.string().nullable(),
          'fallback': V.string().nullable(),
        }).when('kind', equals: null, then: {
          'fallback': V.string().min(3),
        });

        expect(
          schema.validate({'kind': null, 'fallback': 'ok!'}),
          isTrue,
        );
        expect(
          schema.validate({'kind': null, 'fallback': null}),
          isFalse,
          reason: 'kind == null → fallback now required',
        );
        expect(
          schema.validate({'kind': 'explicit', 'fallback': null}),
          isTrue,
          reason: 'kind != null → rule does not fire',
        );
        expect(
          schema.validate({'fallback': null}),
          isFalse,
          reason: 'missing kind reads as null → rule fires',
        );
      });

      test('should support multiple when rules', () {
        final schema = VMap({
          'role': VString(),
          'level': VInt().nullable(),
          'dept': VString().nullable(),
        }).when('role', equals: 'admin', then: {
          'level': VInt().min(5),
        }).when('role', equals: 'manager', then: {
          'dept': VString().min(1),
        });

        expect(schema.validate({'role': 'admin', 'level': 10}), isTrue);
        expect(schema.validate({'role': 'admin', 'level': 1}), isFalse);
        expect(schema.validate({'role': 'manager', 'dept': 'HR'}), isTrue);
        expect(schema.validate({'role': 'user'}), isTrue);
      });
    });

    group('deeply nested maps', () {
      test('should produce 3-level nested error paths', () {
        final schema = VMap({
          'level1': VMap({
            'level2': VMap({
              'level3': VString().min(5),
            }),
          }),
        });

        final errs = schema.errors({
          'level1': {
            'level2': {'level3': 'hi'},
          },
        });
        expect(errs!.first.path, ['level1', 'level2', 'level3']);
      });
    });

    group('kitchen sink (all types combined)', () {
      final schema = V.map({
        'name': V.string().min(1),
        'date.age': V.int().between(0, 150),
        'height': V.double().positive(),
        'active': V.bool().isTrue(),
        'joined': V.date().before(DateTime(2030)),
        'tags': V.string().min(2).array().min(1).unique(),
        'address': V.map({
          'zip': V.string().postalCode(patterns: [const UsZipPattern()]),
          'country': V.literal('US'),
        }),
        'role': V.enm(_Role.values),
        'id': V.union([V.string().uuid(), V.int().min(1)]),
      }).refineFieldRaw(
        // Raw rule — runs at step 4 of the container pipeline, before any
        // field's own preprocess / validators / transforms apply.
        (data) => data['name'] != 'forbidden',
        path: 'name',
        message: 'Name "forbidden" is reserved',
      );

      final good = {
        'name': 'Alice',
        'date.age': 30,
        'height': 1.65,
        'active': true,
        'joined': DateTime(2024, 1, 15),
        'tags': ['dev', 'ops'],
        'address': {'zip': '94103', 'country': 'US'},
        'role': _Role.admin,
        'id': 42,
      };

      test('accepts a valid full-shape map', () {
        expect(schema.validate(good), isTrue);
      });

      test('accepts UUID in the union id field', () {
        final withUuid = {
          ...good,
          'id': '550e8400-e29b-41d4-a716-446655440000',
        };
        expect(schema.validate(withUuid), isTrue);
      });

      test('reports path-precise errors for every failing field', () {
        final bad = {
          'name': '',
          'date.age': 200,
          'height': -1.0,
          'active': false,
          'joined': DateTime(2040),
          'tags': <String>[],
          'address': {'zip': 'invalid', 'country': 'BR'},
          'role': 'not-an-enum',
          'id': 'not-a-uuid',
        };

        final errors = schema.errors(bad);
        expect(errors, isNotNull);

        final paths = errors!.map((e) => e.path.first).toSet();
        expect(
          paths,
          containsAll(<Object>[
            'name',
            'date.age',
            'height',
            'active',
            'joined',
            'tags',
            'address',
            'role',
            'id',
          ]),
        );
      });

      test('nested map error keeps the nested path', () {
        final bad = {
          ...good,
          'address': {'zip': 'nope', 'country': 'US'},
        };
        final errors = schema.errors(bad);
        expect(errors!.first.path, ['address', 'zip']);
      });

      test('rejects missing required field', () {
        final missing = {...good}..remove('name');
        expect(schema.validate(missing), isFalse);
      });

      test('refineFieldRaw fires alongside per-field validation', () {
        // The raw rule on `name` runs at step 4 of the pipeline. With the
        // forbidden value in place, the raw rule fires; per-field
        // validators on the same input keep running.
        final blocked = {...good, 'name': 'forbidden'};
        final errors = schema.errors(blocked);
        expect(errors, isNotNull);
        expect(
          errors!.any(
            (e) =>
                e.path.length == 1 &&
                e.path.first == 'name' &&
                e.message.contains('forbidden'),
          ),
          isTrue,
          reason: 'kitchen sink schema must surface refineFieldRaw error under '
              'the [name] path alongside any field-level errors',
        );
      });
    });

    group('when advanced combinations', () {
      test('when toggles enum-valued field validation', () {
        final schema = V.map({
          'type': V.enm(_Role.values),
          'perks': V.string().array().nullable(),
        }).when('type', equals: _Role.admin, then: {
          'perks': V.string().array().min(1),
        });

        expect(
          schema.validate({
            'type': _Role.admin,
            'perks': ['pagerduty']
          }),
          isTrue,
        );
        expect(
          schema.validate({'type': _Role.admin, 'perks': <String>[]}),
          isFalse,
        );
        expect(
          schema.validate({'type': _Role.user}),
          isTrue,
        );
      });

      test('when field is itself a union schema', () {
        final schema = V.map({
          'kind': V.literal('premium'),
          'payment': V.union([
            V.string().min(5),
            V.int().min(1),
          ]).nullable(),
        }).when('kind', equals: 'premium', then: {
          'payment': V.union([V.string().min(5), V.int().min(1)]),
        });

        expect(
          schema.validate({'kind': 'premium', 'payment': 'credit-card'}),
          isTrue,
        );
        expect(schema.validate({'kind': 'premium', 'payment': 5}), isTrue);
        expect(
          schema.validate({'kind': 'premium', 'payment': null}),
          isFalse,
        );
      });

      test('when combined with strict still rejects unknown keys', () {
        final schema = V.map({
          'type': V.string(),
          'data': V.string().nullable(),
        }).when('type', equals: 'x', then: {
          'data': V.string().min(3),
        }).strict();

        expect(
          schema.validate({'type': 'x', 'data': 'foo', 'extra': 1}),
          isFalse,
        );
        expect(schema.validate({'type': 'x', 'data': 'foo'}), isTrue);
      });

      test('when combined with passthrough keeps extras', () {
        final schema = V.map({
          'type': V.string(),
          'data': V.string().nullable(),
        }).when('type', equals: 'x', then: {
          'data': V.string().min(3),
        }).passthrough();

        final result = schema.parse({
          'type': 'x',
          'data': 'foo',
          'extra': 'keep me',
        });
        expect(result, {'type': 'x', 'data': 'foo', 'extra': 'keep me'});
      });
    });

    group('whenMatches', () {
      test('predicate reads multiple fields and gates extra validators', () {
        final schema = V.map({
          'role': V.string(),
          'level': V.int(),
          'audit_token': V.string().nullable(),
        }).whenMatches(
          (m) => m['role'] == 'admin' && (m['level'] as int) > 5,
          dependsOn: const {'role', 'level'},
          then: {'audit_token': V.string().min(1)},
        );

        expect(
          schema.validate({
            'role': 'admin',
            'level': 10,
            'audit_token': 'tok',
          }),
          isTrue,
        );
        expect(
          schema.validate({'role': 'admin', 'level': 10, 'audit_token': null}),
          isFalse,
          reason: 'predicate matches → audit_token must be non-empty string',
        );
        expect(
          schema.validate({'role': 'admin', 'level': 3}),
          isTrue,
          reason:
              'level not > 5 → predicate false → audit_token stays nullable',
        );
        expect(
          schema.validate({'role': 'user', 'level': 99}),
          isTrue,
          reason: 'role not admin → predicate false',
        );
      });

      test('predicate supports non-equality operators (oneOf, gt)', () {
        final schema = V.map({
          'country': V.string(),
          'doc': V.string().nullable(),
        }).whenMatches(
          (m) => const {'BR', 'AR', 'CL'}.contains(m['country']),
          dependsOn: const {'country'},
          then: {'doc': V.string().min(8)},
        );

        expect(schema.validate({'country': 'BR', 'doc': '12345678'}), isTrue);
        expect(schema.validate({'country': 'AR', 'doc': 'short'}), isFalse);
        expect(schema.validate({'country': 'US', 'doc': null}), isTrue);
      });

      test('error path includes the then field name', () {
        final schema = V.map({
          'flag': V.bool(),
          'extra': V.string().nullable(),
        }).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'extra': V.string().min(3)},
        );

        final errors = schema.errors({'flag': true, 'extra': 'no'});
        expect(errors, isNotNull);
        expect(errors!.first.path, ['extra']);
      });

      test('multiple whenMatches rules fire independently', () {
        final schema = V.map({
          'a': V.int(),
          'b': V.int(),
          'note_a': V.string().nullable(),
          'note_b': V.string().nullable(),
        }).whenMatches(
          (m) => (m['a'] as int) > 10,
          dependsOn: const {'a'},
          then: {'note_a': V.string().min(1)},
        ).whenMatches(
          (m) => (m['b'] as int) < 0,
          dependsOn: const {'b'},
          then: {'note_b': V.string().min(1)},
        );

        expect(
          schema.validate({'a': 20, 'b': -1, 'note_a': 'x', 'note_b': 'y'}),
          isTrue,
        );
        expect(
          schema.validate({'a': 20, 'b': 5, 'note_a': null}),
          isFalse,
          reason: 'first rule fires → note_a required',
        );
        expect(
          schema.validate({'a': 5, 'b': -1, 'note_b': null}),
          isFalse,
          reason: 'second rule fires → note_b required',
        );
        expect(schema.validate({'a': 5, 'b': 5}), isTrue);
      });

      test('refine.dependsOn accepts keys injected via whenMatches.then', () {
        final schema = V.map({
          'mode': V.string(),
        }).whenMatches(
          (m) => m['mode'] == 'audit',
          dependsOn: const {'mode'},
          then: {'audit_token': V.string()},
        ).refine(
          (m) => (m['audit_token'] as String?)?.isNotEmpty ?? true,
          code: 'empty_token',
          dependsOn: const {'audit_token'},
        );

        expect(
          schema.validate({'mode': 'audit', 'audit_token': 'tok'}),
          isTrue,
        );
        expect(
          schema.validate({'mode': 'normal'}),
          isTrue,
        );
      });

      test('combined with strict() rejects then-only keys not in base schema',
          () {
        // Mirrors `when combined with strict still rejects unknown keys` —
        // strict scans against `_schema.containsKey`, not `_knownKeys`.
        final schema = V.map({
          'flag': V.bool(),
        }).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'note': V.string().min(1)},
        ).strict();

        expect(
          schema.validate({'flag': true, 'note': 'hi'}),
          isFalse,
          reason: 'strict rejects "note" because it is not in the base schema',
        );
        expect(schema.validate({'flag': false}), isTrue);
      });

      test('predicate reading null (missing or explicit) fires correctly', () {
        // Missing key reads as null in Dart maps; predicate must treat
        // null as a first-class value. Useful for "if discriminator is
        // not provided, require the fallback field" patterns.
        final schema = V.map({
          'kind': V.string().nullable(),
          'fallback': V.string().nullable(),
        }).whenMatches(
          (m) => m['kind'] == null,
          dependsOn: const {'kind'},
          then: {'fallback': V.string().min(3)},
        );

        expect(
          schema.validate({'kind': 'explicit', 'fallback': null}),
          isTrue,
          reason: 'predicate false (kind non-null) → fallback stays nullable',
        );
        expect(
          schema.validate({'kind': null, 'fallback': 'ok!'}),
          isTrue,
          reason: 'explicit null kind → predicate true → fallback >= 3',
        );
        expect(
          schema.validate({'kind': null, 'fallback': null}),
          isFalse,
          reason: 'explicit null kind → fallback now required',
        );
        expect(
          schema.validate({'fallback': null}),
          isFalse,
          reason: 'missing kind reads as null → predicate true → fail',
        );
      });

      test('combined with passthrough() keeps extras', () {
        final schema = V.map({
          'flag': V.bool(),
          'note': V.string().nullable(),
        }).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'note': V.string().min(1)},
        ).passthrough();

        final result = schema.parse({
          'flag': true,
          'note': 'hi',
          'extra': 42,
        });
        expect(result, {'flag': true, 'note': 'hi', 'extra': 42});
      });

      test('hasAsync becomes true when then contains an async validator', () {
        final asyncSchema = V.map({
          'flag': V.bool(),
        }).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'token': V.string().refineAsync((s) async => s.isNotEmpty)},
        );

        expect(asyncSchema.hasAsync, isTrue);
      });

      test('safeParseAsync runs sync whenMatches when container is async',
          () async {
        final schema = V
            .map({
              'role': V.string(),
              'level': V.int(),
            })
            .refineAsync((m) async => true)
            .whenMatches(
              (m) => m['role'] == 'admin' && (m['level'] as int) > 5,
              dependsOn: const {'role', 'level'},
              then: {'token': V.string().min(3)},
            );

        expect(
          await schema.validateAsync({
            'role': 'admin',
            'level': 10,
            'token': 'abc',
          }),
          isTrue,
        );
        expect(
          await schema.validateAsync({
            'role': 'admin',
            'level': 10,
            'token': 'no',
          }),
          isFalse,
        );
      });

      test('async validator inside then runs through safeParseAsync', () async {
        final schema = V.map({
          'flag': V.bool(),
        }).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {
            'token': V
                .string()
                .refineAsync((s) async => s == 'expected', code: 'bad_token'),
          },
        );

        expect(schema.hasAsync, isTrue);
        expect(
          await schema.validateAsync({'flag': true, 'token': 'expected'}),
          isTrue,
        );
        expect(
          await schema.validateAsync({'flag': true, 'token': 'wrong'}),
          isFalse,
        );
      });
    });

    group('preprocess propagation (regression)', () {
      test('sync preprocess runs before validation', () {
        var ran = 0;
        final schema = V.map({'name': V.string()}).preprocess((v) {
          ran++;

          return v;
        });

        schema.validate({'name': 'Jo'});
        expect(ran, 1);
      });

      test('preprocess can transform the input before field validation', () {
        final schema = V.map({'name': V.string().min(3)}).preprocess((v) {
          if (v is Map<String, dynamic>) {
            return {...v, 'name': (v['name'] as String?)?.trim()};
          }

          return v;
        });

        expect(schema.validate({'name': '  Jo  '}), isFalse);
        expect(schema.validate({'name': '  Alice  '}), isTrue);
      });

      test('async preprocess runs before validation in safeParseAsync',
          () async {
        var syncRan = 0;
        var asyncRan = 0;
        final schema = V.map({'name': V.string()}).preprocess((v) {
          syncRan++;

          return v;
        }).preprocessAsync((v) async {
          asyncRan++;

          return v;
        });

        await schema.validateAsync({'name': 'Jo'});
        expect(syncRan, 1);
        expect(asyncRan, 1);
      });
    });

    group('whenRules getter', () {
      test('returns a snapshot of registered conditional rules', () {
        final schema = V.map({
          'role': V.string(),
          'admin_token': V.string(),
        }).when('role',
            equals: 'admin', then: {'admin_token': V.string().min(1)});

        expect(schema.whenRules, hasLength(1));
        expect(schema.whenRules.first.field, 'role');
        expect(schema.whenRules.first.equals, 'admin');
        expect(schema.whenRules.first.then.containsKey('admin_token'), isTrue);
      });
    });

    group('whenMatchesRules getter', () {
      test('returns a snapshot of registered predicate rules', () {
        final schema = V.map({
          'role': V.string(),
          'level': V.int(),
        }).whenMatches(
          (m) => m['role'] == 'admin',
          dependsOn: const {'role'},
          then: {'level': V.int().min(5)},
        );

        expect(schema.whenMatchesRules, hasLength(1));
        expect(schema.whenMatchesRules.first.dependsOn, {'role'});
        expect(
          schema.whenMatchesRules.first.then.containsKey('level'),
          isTrue,
        );
        expect(
          schema.whenMatchesRules.first.condition({'role': 'admin'}),
          isTrue,
        );
        expect(
          schema.whenMatchesRules.first.condition({'role': 'user'}),
          isFalse,
        );
      });
    });

    group('state propagation (regression)', () {
      test('extend propagates defaultValue from base to extended schema', () {
        final base = V.map({'name': V.string()}).defaultValue(
          const {'name': 'fallback', 'age': 0},
        );

        final extended = base.extend({'age': V.int()});

        expect(
          extended.parse(null),
          {'name': 'fallback', 'age': 0},
          reason: 'extended schema should inherit the base defaultValue',
        );
      });

      test('extend preserves whenMatches rules from base', () {
        final base = V.map({'flag': V.bool()}).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'note': V.string().min(1)},
        );

        final extended = base.extend({'note': V.string().nullable()});

        expect(
          extended.validate({'flag': true, 'note': 'hi'}),
          isTrue,
        );
        expect(
          extended.validate({'flag': true, 'note': ''}),
          isFalse,
          reason: 'whenMatches must still gate "note" after extend',
        );
        expect(extended.whenMatchesRules, hasLength(1));
      });

      test('merge concatenates whenMatches rules from both sides', () {
        final a = V.map({'flag': V.bool()}).whenMatches(
          (m) => m['flag'] == true,
          dependsOn: const {'flag'},
          then: {'note': V.string().min(1)},
        );
        final b = V.map({'count': V.int()}).whenMatches(
          (m) => (m['count'] as int) > 5,
          dependsOn: const {'count'},
          then: {'note': V.string().min(2)},
        );

        final merged = a.merge(b);
        expect(merged.whenMatchesRules, hasLength(2));
      });
    });

    group('assertion errors on schema construction', () {
      test('when() with a field not declared in the schema throws', () {
        final schema = V.map({'name': V.string()});

        expect(
          () => schema.when('missing', equals: 'x', then: const {}),
          throwsA(isA<AssertionError>()),
        );
      });

      test('refineField() with a path not declared in the schema throws', () {
        final schema = V.map({'name': V.string()});

        expect(
          () => schema.refineField((m) => true, path: 'missing'),
          throwsA(isA<AssertionError>()),
        );
      });

      test('whenMatches() with unknown dependsOn key throws', () {
        final schema = V.map({'flag': V.bool()});

        expect(
          () => schema.whenMatches(
            (m) => true,
            dependsOn: const {'missing'},
            then: const {},
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('whenMatches() accepts then keys not in base schema', () {
        // Mirrors when(): then can introduce new keys (they enter
        // _knownKeys via the rule).
        final schema = V.map({'flag': V.bool()});

        expect(
          () => schema.whenMatches(
            (m) => true,
            dependsOn: const {'flag'},
            then: {'fresh': V.string()},
          ),
          returnsNormally,
        );
      });
    });

    group('async safeParse behavior', () {
      test('safeParseAsync rejects non-Map input with invalid_type', () async {
        final schema =
            V.map({'name': V.string()}).refineAsync((m) async => m.isNotEmpty);

        final errors = await schema.errorsAsync('not a map');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'map.invalid_type');
      });

      test('safeParseAsync runs sync when() rule when container is async',
          () async {
        final schema = V
            .map({
              'role': V.string(),
              'admin_token': V.string().min(1),
            })
            .refineAsync((m) async => true)
            .when('role',
                equals: 'admin', then: {'admin_token': V.string().min(5)});

        expect(
          await schema.validateAsync({'role': 'admin', 'admin_token': 'abcde'}),
          isTrue,
        );
        expect(
          await schema.validateAsync({'role': 'admin', 'admin_token': 'no'}),
          isFalse,
          reason: 'sync when() rule must still gate the field in async path',
        );
      });

      test('safeParseAsync surfaces failing when() rule with field path',
          () async {
        final schema = V
            .map({
              'role': V.string(),
              'admin_token': V.string(),
            })
            .refineAsync((m) async => true)
            .when('role',
                equals: 'admin', then: {'admin_token': V.string().min(5)});

        final errors =
            await schema.errorsAsync({'role': 'admin', 'admin_token': 'no'});

        expect(errors, isNotNull);
        expect(errors!.first.path, ['admin_token']);
      });
    });
  });
}
