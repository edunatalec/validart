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
      V.setLocale(const VLocale({'string.not_empty': 'Não pode ser vazio'}));
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
        'map.fields_not_equal': '{field} deve ser igual a {other}',
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

    test(
        'preprocess on the transformed schema runs before the inner (regression)',
        () {
      var ran = 0;
      final schema = V.string().transform<int>((s) => s.length).preprocess((v) {
        ran++;

        return v;
      });

      schema.validate('hello');
      expect(ran, 1);
    });

    test(
        'preprocess on the transformed schema can reshape the input before the '
        'inner validator sees it', () {
      final schema = V.string().transform<int>((s) => s.length).preprocess(
            (v) => v is int ? v.toString() : v,
          );

      expect(schema.parse(42), 2);
      expect(schema.parse('hello'), 5);
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

  group('hasPreprocessors (public)', () {
    test('false on a fresh schema with no preprocessor', () {
      expect(V.string().hasPreprocessors, isFalse);
      expect(V.int().hasPreprocessors, isFalse);
      expect(V.map({'name': V.string()}).hasPreprocessors, isFalse);
    });

    test('true after a sync preprocess() is registered', () {
      final schema = V.string().preprocess((v) => v);
      expect(schema.hasPreprocessors, isTrue);
    });

    test('true after a preprocessAsync() is registered (async-only)', () {
      final schema = V.string().preprocessAsync((v) async => v);
      expect(schema.hasPreprocessors, isTrue);
    });

    test('true when both sync and async preprocessors are registered', () {
      final schema =
          V.string().preprocess((v) => v).preprocessAsync((v) async => v);
      expect(schema.hasPreprocessors, isTrue);
    });

    test('refine() / refineAsync() / validators do NOT flip the flag', () {
      // Only preprocess / preprocessAsync count — pipeline-validation steps
      // and refines are tracked separately. This is the contract consumers
      // (e.g. valiform) rely on to gate the snapshot/preprocess closure.
      expect(V.string().min(3).hasPreprocessors, isFalse);
      expect(V.string().refine((v) => true).hasPreprocessors, isFalse);
      expect(
        V.string().refineAsync((v) async => true).hasPreprocessors,
        isFalse,
      );
    });
  });

  group('runPreprocessors / runPreprocessorsAsync (public)', () {
    test('runs sync preprocessors in registration order', () {
      // Two preprocessors: first appends '-a', second appends '-b'.
      // Order matters — registration order is execution order.
      final schema = V
          .string()
          .preprocess((v) => '${v as String}-a')
          .preprocess((v) => '${v as String}-b');

      expect(schema.runPreprocessors('x'), 'x-a-b');
    });

    test('returns input unchanged when no preprocessors are registered', () {
      final schema = V.string();
      expect(schema.runPreprocessors('hello'), 'hello');
      expect(schema.runPreprocessors(null), null);
      expect(schema.runPreprocessors(42), 42);
    });

    test('does NOT run resolveNull or validators', () {
      // Pipeline has min(3) + defaultValue. runPreprocessors short-circuits
      // before either: a too-short string doesn't fail validation, and a
      // null input stays null (default is NOT substituted).
      final schema =
          V.string().preprocess((v) => v).defaultValue('default-value').min(3);

      expect(schema.runPreprocessors(null), null);
      expect(schema.runPreprocessors('a'), 'a');
      expect(schema.runPreprocessors('hello'), 'hello');
    });

    test('throws VAsyncRequiredException when async preprocessor is present',
        () {
      final schema =
          V.string().preprocessAsync((v) async => (v as String).trim());

      expect(
        () => schema.runPreprocessors('  hi  '),
        throwsA(isA<VAsyncRequiredException>()),
      );
    });

    test('runPreprocessorsAsync runs sync first, then async, in order',
        () async {
      final schema = V
          .string()
          .preprocess((v) => '${v as String}-sync1')
          .preprocessAsync((v) async => '${v as String}-async1')
          .preprocess((v) => '${v as String}-sync2')
          .preprocessAsync((v) async => '${v as String}-async2');

      // Sync chain first (in registration order), then async chain (in
      // registration order). Mirrors how `safeParseAsync` orchestrates
      // the two queues internally.
      expect(
        await schema.runPreprocessorsAsync('x'),
        'x-sync1-sync2-async1-async2',
      );
    });

    test(
      'runPreprocessorsAsync works on schemas with only sync preprocessors',
      () async {
        final schema = V.string().preprocess((v) => (v as String).trim());
        expect(await schema.runPreprocessorsAsync('  hi  '), 'hi');
      },
    );

    test('VMap container preprocessor is exposed via runPreprocessors', () {
      // The whole point of making runPreprocessors public: consumers like
      // valiform need to apply the *container* preprocess in isolation
      // (without running the per-field validators) when bridging the
      // pipeline into per-field UI flow.
      final schema = V.map({
        'name': V.string(),
      }).preprocess((raw) {
        final m = Map<String, dynamic>.from(raw as Map);
        if ((m['name'] as String).length < 3) m['name'] = 'Anonymous';
        return m;
      });

      final result =
          schema.runPreprocessors({'name': 'A'}) as Map<String, dynamic>;
      expect(result['name'], 'Anonymous');
    });

    test('VObject container preprocessor is exposed via runPreprocessors', () {
      final schema = V.object<_DemoUser>().field(
            'name',
            (u) => u.name,
            V.string(),
          );
      // No preprocess registered — runPreprocessors is a passthrough.
      const u = _DemoUser('Alice');
      expect(schema.runPreprocessors(u), u);
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

    test('factory message does NOT override per-validator messages', () {
      final schema = V.string(message: 'X').min(3, message: (_) => 'Too short');
      // null → custom required message
      expect(schema.errors(null)!.first.message, 'X');
      // 'ab' → min error (post-pipeline), validator-level message wins.
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

  group('factory-level invalidTypeMessage override', () {
    test('VString — wrong type input', () {
      expect(
        V.string(invalidTypeMessage: 'X').errors(42)!.first.message,
        'X',
      );
    });

    test('VInt — wrong type input', () {
      expect(
        V.int(invalidTypeMessage: 'X').errors('abc')!.first.message,
        'X',
      );
    });

    test('VDouble — wrong type input', () {
      expect(
        V.double(invalidTypeMessage: 'X').errors(true)!.first.message,
        'X',
      );
    });

    test('VBool — wrong type input', () {
      expect(V.bool(invalidTypeMessage: 'X').errors(0)!.first.message, 'X');
    });

    test('VDate — wrong type input', () {
      expect(
        V.date(invalidTypeMessage: 'X').errors('not a date')!.first.message,
        'X',
      );
    });

    test('VArray — input not a List', () {
      expect(
        V
            .array(V.string(), invalidTypeMessage: 'X')
            .errors('not a list')!
            .first
            .message,
        'X',
      );
    });

    test('VMap — input not a Map', () {
      expect(
        V
            .map({'a': V.string()}, invalidTypeMessage: 'X')
            .errors('not a map')!
            .first
            .message,
        'X',
      );
    });

    test('VObject — input not the entity type', () {
      expect(
        V
            .object<_Dummy>(invalidTypeMessage: 'X')
            .errors('not a dummy')!
            .first
            .message,
        'X',
      );
    });

    test(
      'VEnum / VLiteral are intentionally out of scope',
      () {
        // Pin the boundary: VEnum/VLiteral emit `enum.invalid` /
        // `literal.invalid` (not `invalid_type`). Both factories accept
        // `invalidTypeMessage:` for API uniformity, but the override is
        // a no-op there.
        expect(
          V
              .enm(_DemoColor.values, invalidTypeMessage: 'X')
              .errors('not red')!
              .first
              .code,
          'enum.invalid',
        );
        expect(
          V.literal('admin', invalidTypeMessage: 'X').errors(42)!.first.code,
          'literal.invalid',
        );
      },
    );

    test(
      'still emits invalid_type code (just with a different message)',
      () {
        final err = V.string(invalidTypeMessage: 'X').errors(42)!.first;
        expect(err.code, 'string.invalid_type');
        expect(err.message, 'X');
      },
    );

    test(
      'factory message: alone does NOT cover invalid_type',
      () {
        // Inverse pin — confirms the two parameters are independent.
        // `message:` covers ONLY required (null input). For wrong-type
        // input, the locale template is used unless `invalidTypeMessage:`
        // is set.
        final schema = V.string(message: 'required label');
        expect(schema.errors(null)!.first.message, 'required label');
        expect(
          schema.errors(42)!.first.message,
          isNot('required label'),
          reason: 'message: must NOT bleed into invalid_type — that is '
              "invalidTypeMessage:'s job",
        );
      },
    );

    test(
      'both parameters can coexist on the same schema',
      () {
        final schema = V.string(
          message: 'Email is required',
          invalidTypeMessage: 'Email must be text',
        );
        expect(schema.errors(null)!.first.message, 'Email is required');
        expect(schema.errors(42)!.first.message, 'Email must be text');
      },
    );

    test(
      'validator-level message still wins for post-pipeline errors',
      () {
        // After the type check passes, validator-level messages take
        // over. Factory params ONLY cover pre-pipeline gate errors.
        final schema = V
            .string(message: 'r', invalidTypeMessage: 't')
            .min(3, message: (_) => 'too short');
        expect(schema.errors('ab')!.first.message, 'too short');
      },
    );
  });

  group('refineField stages (post vs pre)', () {
    test(
      'VMap.refineField(stage: pre) sees raw values; default post sees parsed (transforms applied)',
      () {
        // The same callback wired through both stages gives different
        // results when a field has a transform: pre fires on the raw
        // input, post on the post-pipeline value.
        final schema = V
            .map({'email': V.string().toLowerCase()})
            .refineField(
              (data) => data['email'] == 'A@B.COM',
              path: 'email',
              message: 'raw must be A@B.COM',
              stage: RefineStage.pre,
            )
            .refineField(
              (data) => data['email'] == 'A@B.COM',
              path: 'email',
              message: 'parsed must be A@B.COM',
            );

        // Input 'A@B.COM' raw → raw matches; parsed value is 'a@b.com'
        // (lowercased), so the parsed callback fails.
        final errs = schema.errors({'email': 'A@B.COM'});
        expect(errs, isNotNull);
        expect(errs!.any((e) => e.message == 'parsed must be A@B.COM'), isTrue);
        expect(errs.any((e) => e.message == 'raw must be A@B.COM'), isFalse);
      },
    );

    test(
      'VMap.refineField(stage: pre) runs even when an unrelated field fails '
      'its per-field validator (no dependsOn gating)',
      () {
        // refineField post (with implicit dependsOn = {path}) skips when
        // the declared field fails. stage: pre has no per-field pipeline
        // to gate on — it runs unconditionally once the input is a
        // Map<String, dynamic>.
        final schema = V.map({
          'a': V.string().min(5),
          'b': V.string(),
        }).refineField(
          (data) => data['b'] == 'ok',
          path: 'b',
          message: 'b must be ok (raw)',
          stage: RefineStage.pre,
        );

        // 'a' fails (length < 5), but the raw rule still runs and
        // succeeds — its error is absent.
        final errs = schema.errors({'a': 'no', 'b': 'ok'});
        expect(errs, isNotNull);
        expect(errs!.any((e) => e.message == 'b must be ok (raw)'), isFalse);

        // Now flip 'b' to wrong — the raw rule fires alongside the
        // per-field error for 'a'.
        final errs2 = schema.errors({'a': 'no', 'b': 'no'});
        expect(errs2!.any((e) => e.message == 'b must be ok (raw)'), isTrue);
      },
    );

    test(
      'VMap.refineField(stage: pre) error path is [path] — surfaces inline, not in root',
      () {
        final schema = V.map({'name': V.string()}).refineField(
          (data) => false,
          path: 'name',
          message: 'always fails',
          stage: RefineStage.pre,
        );

        final result = schema.safeParse({'name': 'x'});
        expect(result, isA<VFailure>());
        final errs = (result as VFailure).errors;
        expect(errs.first.path, ['name']);
        expect(errs.first.message, 'always fails');
      },
    );

    test('VMap.refineField(stage: pre) asserts that path exists in the schema',
        () {
      expect(
        () => V.map({'name': V.string()}).refineField(
          (data) => true,
          path: 'unknown',
          stage: RefineStage.pre,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test(
      'VObject.refineField(stage: pre) runs once the cast succeeded, even '
      'when a per-field validator fails afterwards',
      () {
        final schema = V
            .object<_RawDemo>()
            .field('value', (d) => d.value, V.string().min(5))
            .refineField(
              (d) => d.flag,
              path: 'value',
              message: 'flag must be true',
              stage: RefineStage.pre,
            );

        // 'value' fails per-field (length < 5); the raw rule still runs
        // because the cast succeeded and there were no field failures
        // to gate it on.
        final errs = schema.errors(const _RawDemo(value: 'no', flag: false));
        expect(errs!.any((e) => e.message == 'flag must be true'), isTrue);
      },
    );

    test('refineField(stage: pre) runs through async pipeline as well',
        () async {
      final schema = V
          .map({'email': V.string().toLowerCase()})
          .refineField(
            (data) => data['email'] == 'A@B.COM',
            path: 'email',
            message: 'raw must be A@B.COM',
            stage: RefineStage.pre,
          )
          .refineAsync(
            (m) async => true,
            dependsOn: const {'email'},
          );

      // Refine async forces async path; the raw rule still runs and
      // sees the original casing.
      final errs = await schema.errorsAsync({'email': 'a@b.com'});
      expect(errs, isNotNull);
      expect(errs!.first.message, 'raw must be A@B.COM');
    });

    test(
      'VMap.refineField(stage: pre) runs BEFORE strict()-mode unknown-key check',
      () {
        // Pipeline order pinned: step 4 (raw) before step 5 (strict).
        // The schema has `.strict()` and the input has an unknown key
        // AND the raw rule fires — both errors must appear.
        final schema = V.map({'name': V.string()}).strict().refineField(
              (data) => data['name'] != 'forbidden',
              path: 'name',
              message: 'name forbidden',
              stage: RefineStage.pre,
            );

        final errs = schema.errors({'name': 'forbidden', 'extra': true});
        expect(errs, isNotNull);

        // Raw rule fired (under the `name` path)…
        expect(
          errs!.any(
              (e) => e.path.first == 'name' && e.message == 'name forbidden'),
          isTrue,
          reason: 'refineFieldRaw must run regardless of strict() rejections',
        );
        // …AND strict-mode unknown-key error fired.
        expect(
          errs.any((e) => e.code == VMapCode.unrecognizedKey),
          isTrue,
        );
      },
    );

    test(
      'VMap.refineField(stage: pre) runs BEFORE per-field iteration (sees raw values)',
      () {
        // Pipeline order pinned: step 4 (raw) before step 6 (per-field
        // iteration). The field has a `.toLowerCase()` pre-transform; the
        // raw callback must see the ORIGINAL casing.
        final schema = V.map({'tag': V.string().toLowerCase()}).refineField(
          (data) => data['tag'] == data['tag'].toString().toUpperCase(),
          path: 'tag',
          message: 'tag must be uppercase (raw)',
          stage: RefineStage.pre,
        );

        // 'HELLO' raw → all uppercase → raw rule passes.
        // After the per-field pipeline runs, `.toLowerCase()` reshapes it
        // to 'hello' — but the raw rule already returned `true`.
        expect(schema.errors({'tag': 'HELLO'}), isNull);

        // 'hello' raw → not uppercase → raw rule fails.
        final errs = schema.errors({'tag': 'hello'});
        expect(errs, isNotNull);
        expect(errs!.first.message, 'tag must be uppercase (raw)');
      },
    );

    test(
      'VMap.refineField(stage: pre) works alongside .passthrough()',
      () {
        // Passthrough copies unrecognized keys to the parsed output (step
        // 8); refineField(stage: pre) runs at step 4. Both must coexist
        // without either swallowing the other's effect.
        final schema = V.map({'name': V.string()}).passthrough().refineField(
              (data) => data['name'] != 'forbidden',
              path: 'name',
              message: 'name forbidden',
              stage: RefineStage.pre,
            );

        // Valid name + extra key → no error, extra is in parsed output.
        final ok = schema.parse({'name': 'Alice', 'extra': 42});
        expect(ok!['extra'], 42);

        // Forbidden name + extra key → raw rule fires; the extra key
        // never makes it to the parsed output because validation failed.
        final errs = schema.errors({'name': 'forbidden', 'extra': 42});
        expect(errs!.first.message, 'name forbidden');
      },
    );

    test(
      'VObject.refineField(stage: pre) asserts that path exists in the schema',
      () {
        // VMap.refineField(stage: pre) is asserted above; pin the same
        // behavior on VObject so the parity is enforced by the suite.
        expect(
          () => V
              .object<_RawDemo>()
              .field('value', (d) => d.value, V.string())
              .refineField(
                (d) => true,
                path: 'unknown',
                stage: RefineStage.pre,
              ),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  group('VFailure.toMapFirst / toMapAll', () {
    test('toMapFirst returns one error per field (the first registered)', () {
      // Two violations on `pwd`; toMapFirst keeps only the first.
      final schema = V.map({'pwd': V.string().min(8).alpha()});
      final result = schema.safeParse({'pwd': '1'});
      if (result case VFailure() && final f) {
        final map = f.toMapFirst();
        expect(map.length, 1);
        expect(map['pwd'], isNotNull);
      }
    });

    test('toMap is an alias for toMapFirst (backwards compatibility)', () {
      final schema = V.map({'pwd': V.string().min(8)});
      final result = schema.safeParse({'pwd': 'a'});
      if (result case VFailure() && final f) {
        expect(f.toMap(), f.toMapFirst());
      }
    });

    test('toMapAll preserves every error per field in registration order', () {
      final schema = V.map({'pwd': V.string().min(8).alpha()});
      final result = schema.safeParse({'pwd': '1'});
      if (result case VFailure() && final f) {
        final all = f.toMapAll();
        expect(all['pwd'], isNotNull);
        expect(all['pwd']!.length, 2);
        // First was .min(8), second was .alpha() — order matches the
        // chain, since validators run in registration order.
        expect(all['pwd']![0], contains('8'));
      }
    });

    test('toMapAll excludes root-level errors (path: [])', () {
      // refine() with empty path emits a root error — must NOT appear
      // in toMapAll, only in rootMessages.
      final schema = V.map({'name': V.string().min(1)}).refine((m) => false,
          message: 'root rule');
      final result = schema.safeParse({'name': 'x'});
      if (result case VFailure() && final f) {
        expect(
            f.toMapAll().values.expand((v) => v), isNot(contains('root rule')));
        expect(f.rootMessages(), contains('root rule'));
      }
    });

    test('toMapAll returns empty map when there are only root-level errors',
        () {
      final schema = V.string().email();
      final result = schema.safeParse('bad');
      if (result case VFailure() && final f) {
        expect(f.toMapAll(), isEmpty);
        expect(f.rootMessages(), isNotEmpty);
      }
    });
  });

  group('refine — dependsOn: const {} opt-in (always run)', () {
    test(
      'VMap.refine with dependsOn: const {} runs even when a field failed',
      () {
        // Without an opt-in, refine without dependsOn would skip
        // conservatively. Pass an explicit EMPTY set to declare
        // "depends on nothing" → never skip.
        var ran = 0;
        final schema = V.map({
          'name': V.string().min(3),
        }).refine(
          (m) {
            ran++;
            // Defensive: 'name' may be absent if the field failed.
            return m['name'] != null;
          },
          dependsOn: const {},
        );

        schema.errors({'name': 'Al'});
        expect(
          ran,
          1,
          reason: 'dependsOn: const {} must opt out of conservative skip',
        );
      },
    );

    test(
      'VMap.refine WITHOUT dependsOn DOES skip when a field failed',
      () {
        // Pin the contrast — confirms the opt-in is meaningful.
        var ran = 0;
        final schema = V.map({
          'name': V.string().min(3),
        }).refine((m) {
          ran++;
          return true;
        });

        schema.errors({'name': 'Al'});
        expect(
          ran,
          0,
          reason: 'no dependsOn = conservative skip when any field fails',
        );
      },
    );

    test(
      'VObject.refine with dependsOn: const {} also opts out',
      () {
        // Mirror the VMap behaviour on VObject for parity.
        var ran = 0;
        final schema = V
            .object<_DependsOnDemo>()
            .field('a', (d) => d.a, V.string().min(3))
            .field('b', (d) => d.b, V.string())
            .refine(
          (d) {
            ran++;
            return true;
          },
          dependsOn: const {},
        );

        // 'a' fails .min(3); refine still runs.
        schema.errors(const _DependsOnDemo(a: 'x', b: 'ok'));
        expect(ran, 1);
      },
    );
  });

  group('refineField — dependsOn override', () {
    test(
      'VMap.refineField with explicit extra dependsOn unions with {path} and '
      'aggregates with unrelated fields',
      () {
        // The check on `email` ALSO depends on `domain` having passed
        // its own validation. dependsOn: {domain} → effective {email, domain}.
        //   - if `domain` failed, the check is skipped (cast safety).
        //   - if `name` (unrelated) failed, the check still runs.
        final schema = V.map({
          'email': V.string().email(),
          'domain': V.string().min(1),
          'name': V.string().min(3),
        }).refineField(
          (data) =>
              (data['email'] as String).endsWith(data['domain'] as String),
          path: 'email',
          dependsOn: const {'domain'},
          message: 'email must match domain',
        );

        // Both deps pass; the unrelated `name` fails. Refine still runs
        // and emits its error alongside the field error.
        final errs = schema.errors({
          'email': 'a@example.com',
          'domain': 'wrong.com',
          'name': 'Al',
        });
        expect(errs, isNotNull);
        expect(
          errs!.any((e) => e.message == 'email must match domain'),
          isTrue,
        );
        expect(errs.any((e) => e.path.first == 'name'), isTrue);
      },
    );

    test(
      'VMap.refineField with extra dependsOn skips when the extra dep fails',
      () {
        // Pins the union: dependsOn: {domain} actually carries domain into
        // the skip set (besides {path}).
        var ran = 0;
        final schema = V.map({
          'email': V.string().email(),
          'domain': V.string().min(1),
        }).refineField(
          (data) {
            ran++;
            return true;
          },
          path: 'email',
          dependsOn: const {'domain'},
        );

        // domain fails its own validation → refine must skip.
        schema.errors({
          'email': 'a@example.com',
          'domain': '', // fails min(1)
        });
        expect(ran, 0);
      },
    );

    test(
      'VMap.refineField with empty dependsOn throws AssertionError at '
      'construction',
      () {
        expect(
          () => V.map({'name': V.string().min(3)}).refineField(
            (data) => true,
            path: 'name',
            dependsOn: const {},
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'VObject.refineField with empty dependsOn throws AssertionError at '
      'construction (parity with VMap)',
      () {
        expect(
          () => V
              .object<_RawDemo>()
              .field('value', (d) => d.value, V.string().min(5))
              .field('flag', (d) => d.flag, V.bool())
              .refineField(
            (d) => true,
            path: 'value',
            dependsOn: const {},
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'VMap.refineField with default dependsOn DOES skip when its own field '
      'fails',
      () {
        // Pin the contrast: without override, refineField skips when
        // the field at `path` failed (its own implicit `{path}` dep).
        var ran = 0;
        final schema = V.map({
          'name': V.string().min(3),
        }).refineField(
          (data) {
            ran++;
            return true;
          },
          path: 'name',
        );

        schema.errors({'name': 'Al'});
        expect(
          ran,
          0,
          reason: 'default dependsOn: {path} must skip when path failed',
        );
      },
    );

    test(
      'VMap.refineField asserts dependsOn keys exist in the schema',
      () {
        expect(
          () => V.map({'name': V.string()}).refineField(
            (data) => true,
            path: 'name',
            dependsOn: const {'unknown'},
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    test(
      'VObject.refineField with explicit dependsOn behaves identically',
      () {
        final schema = V
            .object<_DependsOnDemo>()
            .field('a', (d) => d.a, V.string().min(1))
            .field('b', (d) => d.b, V.string().min(1))
            .refineField(
              (d) => d.a == d.b,
              path: 'a',
              dependsOn: const {'b'},
              message: 'a and b must be equal',
            );

        // Both deps pass, refine fails → error under [a].
        final errs = schema.errors(const _DependsOnDemo(a: 'x', b: 'y'));
        expect(errs!.first.message, 'a and b must be equal');
        expect(errs.first.path, ['a']);
      },
    );

    test(
      'VObject.refineField unions {path} into dependsOn — skips when path '
      'itself failed even though only an extra dep was declared',
      () {
        var ran = 0;
        final schema = V
            .object<_DependsOnDemo>()
            .field('a', (d) => d.a, V.string().min(3))
            .field('b', (d) => d.b, V.string().min(1))
            .refineField(
          (d) {
            ran++;
            return true;
          },
          path: 'a',
          dependsOn: const {'b'},
        );

        // 'a' fails min(3) — path is in the effective dep set → skip.
        schema.errors(const _DependsOnDemo(a: 'x', b: 'ok'));
        expect(ran, 0);
      },
    );
  });

  group('addRaw (public low-level API)', () {
    test('addRaw on a primitive schema is a semantic no-op', () {
      // The doc on `addRaw` claims raw steps never run outside container
      // types. Pin it: a primitive `V.string()` with a raw validator
      // registered must NOT fail validation that the validator would
      // reject if it ran.
      final schema = V.string().addRaw(const _AlwaysFails());
      expect(schema.validate('hello'), isTrue);
      expect(schema.errors('hello'), isNull);
    });

    test('addRaw inside VMap fires the raw step', () {
      // Direct addRaw on VMap reaches `_runRawValidators` exactly the
      // same way refineFieldRaw does — confirms the public API is
      // wired end-to-end and not just a refineFieldRaw private helper.
      final schema =
          V.map({'name': V.string()}).addRaw(const _MapRequiresName());
      final errs = schema.errors({'name': ''});
      expect(errs, isNotNull);
      expect(errs!.first.code, 'name_required');
    });

    test('addRaw with explicit path attaches the error to that path', () {
      final schema = V.map({'name': V.string()}).addRaw(
        const _MapRequiresName(),
        path: const ['name'],
      );
      final errs = schema.errors({'name': ''});
      expect(errs!.first.path, ['name']);
    });
  });
}

class _AlwaysFails extends Validator<String> {
  const _AlwaysFails();

  @override
  String get code => 'always_fails';

  @override
  Map<String, dynamic>? validate(String value) => {};
}

class _MapRequiresName extends Validator<Map<String, dynamic>> {
  const _MapRequiresName();

  @override
  String get code => 'name_required';

  @override
  Map<String, dynamic>? validate(Map<String, dynamic> value) =>
      (value['name'] as String?)?.isNotEmpty == true ? null : {};
}

class _DependsOnDemo {
  final String a;
  final String b;
  const _DependsOnDemo({required this.a, required this.b});
}

enum _DemoColor { red, green, blue }

class _Dummy {
  const _Dummy();
}

class _DemoUser {
  final String name;
  const _DemoUser(this.name);
}

class _RawDemo {
  final String value;
  final bool flag;

  const _RawDemo({required this.value, required this.flag});
}
