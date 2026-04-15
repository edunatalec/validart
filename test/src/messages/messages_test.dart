import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VLocale', () {
    test('default translations should work', () {
      const locale = VLocale();
      expect(locale.translate('required'), 'Required');
      expect(locale.translate('invalid_email'), 'Invalid email address');
      expect(locale.translate('positive'), 'Must be positive');
      expect(locale.translate('is_true'), 'Must be true');
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
        'invalid_email': 'Email inválido',
      });
      expect(locale.translate('required'), 'Campo obrigatório');
      expect(locale.translate('invalid_email'), 'Email inválido');
      // Non-overridden keys should fall back to defaults
      expect(locale.translate('invalid_url'), 'Invalid URL');
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
  });

  group('V.setLocale', () {
    test('should change translations for string validators', () {
      V.setLocale(const VLocale({
        'invalid_email': 'Email inválido',
      }));
      final schema = VString()..email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Email inválido');
    });

    test('should change translations for number validators', () {
      V.setLocale(const VLocale({
        'positive': 'Deve ser positivo',
      }));
      final schema = VInt()..positive();
      final errs = schema.errors(-1);
      expect(errs!.first.message, 'Deve ser positivo');
    });

    test('should change translations for bool validators', () {
      V.setLocale(const VLocale({
        'is_true': 'Deve ser verdadeiro',
      }));
      final schema = VBool()..isTrue();
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
        'invalid_email': 'Global email msg',
      }));
      final schema = VString()..email(message: 'Per-validator msg');
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Per-validator msg');
    });

    test('should use default message when no custom provided', () {
      V.setLocale(const VLocale());
      final schema = VString()..email();
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
      expect(V.t('invalid_email'), 'Invalid email address');

      // Code itself is returned when nothing matches
      expect(V.t('nonexistent_code'), 'nonexistent_code');
    });
  });
}
