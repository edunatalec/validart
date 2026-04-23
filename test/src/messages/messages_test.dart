import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VLocale', () {
    test('default translations should work', () {
      const locale = VLocale();
      expect(locale.translate('required'), 'Required');
      expect(locale.translate('string.email'), 'Invalid email address');
      expect(locale.translate('number.positive'), 'Must be positive');
      expect(locale.translate('bool.is_true'), 'Must be true');
    });

    test('default translations should interpolate params', () {
      const locale = VLocale();
      expect(
        locale.translate('string.too_small', {'min': 3}),
        'Must be at least 3 characters',
      );
      expect(
        locale.translate(
            'invalid_type', {'expected': 'String', 'received': 'int'}),
        'Expected String, received int',
      );
    });

    test('custom translations should override defaults', () {
      const locale = VLocale({
        'required': 'Campo obrigatório',
        'string.email': 'Email inválido',
      });
      expect(locale.translate('required'), 'Campo obrigatório');
      expect(locale.translate('string.email'), 'Email inválido');
      // Non-overridden keys should fall back to defaults
      expect(locale.translate('string.url'), 'Invalid URL');
    });

    test('unknown code should return code itself', () {
      const locale = VLocale();
      expect(locale.translate('unknown_code'), 'unknown_code');
    });

    test('custom translations should interpolate params', () {
      const locale = VLocale({
        'string.too_small': 'Mínimo de {min} caracteres',
      });
      expect(
        locale.translate('string.too_small', {'min': 5}),
        'Mínimo de 5 caracteres',
      );
    });

    test('should assert when template has unreplaced placeholders', () {
      const locale = VLocale({
        'number.not_in_range': 'Must be {min} to {max}',
      });
      expect(
        () => locale.translate('number.not_in_range', {'min': 5}),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('V.setLocale', () {
    test('should change translations for string validators', () {
      V.setLocale(const VLocale({
        'string.email': 'Email inválido',
      }));
      final schema = VString().email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Email inválido');
    });

    test('should change translations for number validators', () {
      V.setLocale(const VLocale({
        'number.positive': 'Deve ser positivo',
      }));
      final schema = VInt().positive();
      final errs = schema.errors(-1);
      expect(errs!.first.message, 'Deve ser positivo');
    });

    test('should change translations for bool validators', () {
      V.setLocale(const VLocale({
        'bool.is_true': 'Deve ser verdadeiro',
      }));
      final schema = VBool().isTrue();
      final errs = schema.errors(false);
      expect(errs!.first.message, 'Deve ser verdadeiro');
    });

    test('should change required message globally', () {
      V.setLocale(const VLocale({
        'required': 'Campo obrigatório',
      }));

      final stringErrs = VString().errors(null);
      expect(stringErrs!.first.message, 'Campo obrigatório');

      final intErrs = VInt().errors(null);
      expect(intErrs!.first.message, 'Campo obrigatório');

      final mapErrs = VMap({'name': VString()}).errors(null);
      expect(mapErrs!.first.message, 'Campo obrigatório');

      final objectErrs = VObject<String>().errors(null);
      expect(objectErrs!.first.message, 'Campo obrigatório');
    });

    test('should change invalidType message globally', () {
      V.setLocale(const VLocale({
        'invalid_type': 'Esperado {expected}, recebido {received}',
      }));
      final errs = VString().errors(123);
      expect(errs!.first.message, contains('Esperado'));
      expect(errs.first.message, contains('recebido'));
    });
  });

  group('V.t', () {
    test('should translate codes using current locale', () {
      V.setLocale(const VLocale({
        'required': 'Obrigatório',
      }));
      expect(V.t('required'), 'Obrigatório');
    });

    test('should interpolate params', () {
      V.setLocale(const VLocale({
        'string.too_small': 'Min {min}',
      }));
      expect(V.t('string.too_small', {'min': 3}), 'Min 3');
    });

    test('should fall back to default when custom not set', () {
      V.setLocale(const VLocale());
      expect(V.t('required'), 'Required');
    });

    test('should return code itself when no translation exists', () {
      V.setLocale(const VLocale());
      expect(V.t('totally_unknown_code'), 'totally_unknown_code');
    });
  });

  group('Per-validator override bypasses locale', () {
    test('should use per-validator message over locale', () {
      V.setLocale(const VLocale({
        'string.email': 'Global email msg',
      }));
      final schema = VString().email(message: 'Per-validator msg');
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Per-validator msg');
    });

    test('should use default message when no custom provided', () {
      V.setLocale(const VLocale());
      final schema = VString().email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Invalid email address');
    });
  });

  group('Fallback chain', () {
    test('custom locale -> default -> code itself', () {
      // Custom translation takes priority
      V.setLocale(const VLocale({
        'required': 'Custom required',
      }));
      expect(V.t('required'), 'Custom required');

      // Default is used when no custom
      expect(V.t('string.email'), 'Invalid email address');

      // Code itself is returned when nothing matches
      expect(V.t('nonexistent_code'), 'nonexistent_code');
    });
  });

  group('Prefixed codes and nested translations', () {
    test('flat prefixed override wins over generic', () {
      V.setLocale(const VLocale({
        'required': 'Generic required',
        'string.required': 'String required',
      }));

      expect(VString().errors(null)!.first.message, 'String required');
      expect(VInt().errors(null)!.first.message, 'Generic required');
    });

    test('nested map override wins over generic', () {
      V.setLocale(const VLocale({
        'required': 'Generic required',
        'string': {'required': 'String required'},
      }));

      expect(VString().errors(null)!.first.message, 'String required');
      expect(VInt().errors(null)!.first.message, 'Generic required');
    });

    test('generic required still applies when no type-specific override', () {
      V.setLocale(const VLocale({'required': 'Obrigatório'}));

      expect(VString().errors(null)!.first.message, 'Obrigatório');
      expect(VInt().errors(null)!.first.message, 'Obrigatório');
      expect(VBool().errors(null)!.first.message, 'Obrigatório');
      expect(VMap({'a': VString()}).errors(null)!.first.message, 'Obrigatório');
    });

    test('prefixed invalid_type overrides generic', () {
      V.setLocale(const VLocale({
        'invalid_type': 'Generic type',
        'string.invalid_type': 'String type',
      }));

      expect(VString().errors(42)!.first.message, 'String type');
      expect(VInt().errors('x')!.first.message, 'Generic type');
    });

    test('nested and flat can coexist', () {
      V.setLocale(const VLocale({
        'int.required': 'Int required',
        'string': {'required': 'String required'},
      }));

      expect(VString().errors(null)!.first.message, 'String required');
      expect(VInt().errors(null)!.first.message, 'Int required');
      // Falls back to default English for others
      expect(VBool().errors(null)!.first.message, 'Required');
    });

    test('error code emitted carries the type prefix', () {
      expect(VString().errors(null)!.first.code, 'string.required');
      expect(VInt().errors(null)!.first.code, 'int.required');
      expect(VBool().errors(null)!.first.code, 'bool.required');
      expect(VString().errors(42)!.first.code, 'string.invalid_type');
      expect(VInt().errors('x')!.first.code, 'int.invalid_type');
    });

    test('custom drop-prefix: flat key without type prefix wins', () {
      // User sets only the unprefixed `'email'` — emitted code is
      // `'string.email'`; the resolver drops the `'string.'` prefix and
      // hits the custom generic key.
      V.setLocale(const VLocale({'email': 'Custom email'}));

      expect(V.t('string.email'), 'Custom email');
      expect(VString().email().errors('bad')!.first.message, 'Custom email');
    });

    test('default drop-prefix: prefixed code falls back to generic default',
        () {
      // No custom locale, no type-specific default for `'string.whatever'`
      // — but the resolver finds `'required'` in defaults after dropping
      // the prefix.
      const locale = VLocale();

      // `string.required` is not in _defaults nested, but `required` is —
      // resolver drops the prefix and returns the English default.
      expect(locale.translate('string.required'), 'Required');
      expect(locale.translate('int.required'), 'Required');
      expect(locale.translate('map.invalid_type', {'expected': 'Map', 'received': 'int'}),
          'Expected Map, received int');
    });

    test('full 5-layer fallback chain resolves in the documented order', () {
      // Layer 1: custom prefixed wins
      V.setLocale(const VLocale({
        'string.email': 'L1 custom prefixed',
        'email': 'L2 custom drop',
      }));
      expect(V.t('string.email'), 'L1 custom prefixed');

      // Layer 2: custom drop-prefix (no prefixed match)
      V.setLocale(const VLocale({'email': 'L2 custom drop'}));
      expect(V.t('string.email'), 'L2 custom drop');

      // Layer 3: default prefixed (no custom at all) — nested defaults
      V.setLocale(const VLocale());
      expect(V.t('string.email'), 'Invalid email address');

      // Layer 4: default drop-prefix (prefixed code with no prefixed
      // default, but generic sibling exists).
      expect(V.t('string.required'), 'Required');

      // Layer 5: code itself when nothing matches anywhere
      expect(V.t('totally.made.up.code'), 'totally.made.up.code');
    });
  });

  group('Malformed locale handling', () {
    test('non-Map value at a path segment falls back gracefully', () {
      // User mistakenly sets 'string' to a String instead of a Map.
      // Lookup for 'string.email' cannot navigate into it — resolver
      // drops prefix and finds 'email' (not set) → default 'string.email'
      // via nested defaults → 'Invalid email address'.
      const locale = VLocale({'string': 'not a map'});

      expect(locale.translate('string.email'), 'Invalid email address');
    });

    test('non-String leaf value is rejected (treated as no match)', () {
      // Malformed locale with a non-String value. Lookup returns null for
      // that key — resolver falls through to defaults.
      const locale = VLocale(<String, Object>{'required': 42});

      expect(locale.translate('required'), 'Required');
    });

    test('deep nested paths (3+ levels) resolve correctly', () {
      // Code with multiple dots navigates the tree fully. Defensive
      // check — no current emitted code has 3 levels, but the resolver
      // should handle it for future-proofing and third-party extensions.
      const locale = VLocale({
        'a': {
          'b': {'c': 'deep'},
        },
      });

      expect(locale.translate('a.b.c'), 'deep');
      // Miss at the deepest level: falls through to fallback (no match
      // anywhere, returns code).
      expect(locale.translate('a.b.missing'), 'a.b.missing');
    });
  });
}
