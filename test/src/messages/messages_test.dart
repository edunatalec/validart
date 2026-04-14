import 'package:test/test.dart';
import 'package:validart/src/messages/messages.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validart.dart';

void main() {
  group('VMessages', () {
    test('default messages should work', () {
      const messages = VMessages();
      expect(messages.required, 'Required');
      expect(messages.string.email, 'Invalid email address');
      expect(messages.number.positive, 'Must be positive');
      expect(messages.bool.isTrue, 'Must be true');
    });

    test('custom messages should override defaults', () {
      const messages = VMessages(
        required: 'Campo obrigatório',
        string: VStringMessages(email: 'Email inválido'),
      );
      expect(messages.required, 'Campo obrigatório');
      expect(messages.string.email, 'Email inválido');
      expect(messages.string.url, 'Invalid URL');
    });
  });

  group('VString with custom messages', () {
    test('should use custom messages from constructor', () {
      final schema = VString(
        messages: const VStringMessages(email: 'Email inválido'),
      )..email();

      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Email inválido');
    });

    test('should use per-validator message over global', () {
      final schema = VString(
        messages: const VStringMessages(email: 'Global email msg'),
      )..email(message: 'Per-validator msg');

      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Per-validator msg');
    });

    test('should use default messages when no custom provided', () {
      final schema = VString()..email();
      final errs = schema.errors('bad');
      expect(errs!.first.message, 'Invalid email address');
    });
  });

  group('VInt with custom messages', () {
    test('should use custom messages', () {
      final schema = VInt(
        messages: const VNumberMessages(positive: 'Deve ser positivo'),
      )..positive();

      final errs = schema.errors(-1);
      expect(errs!.first.message, 'Deve ser positivo');
    });
  });

  group('VBool with custom messages', () {
    test('should use custom messages', () {
      final schema = VBool(
        messages: const VBoolMessages(isTrue: 'Deve ser verdadeiro'),
      )..isTrue();

      final errs = schema.errors(false);
      expect(errs!.first.message, 'Deve ser verdadeiro');
    });
  });

  group('VDate with custom messages', () {
    test('should use custom messages', () {
      final now = DateTime.now();
      final future = now.add(const Duration(days: 1));

      final schema = VDate(
        messages: VDateMessages(after: (d) => 'Deve ser após $d'),
      )..after(future);

      final errs = schema.errors(now);
      expect(errs!.first.message, contains('Deve ser após'));
    });
  });

  group('VArray with custom messages', () {
    test('should use custom messages', () {
      final schema = VArray<String>(
        VString(),
        messages: const VArrayMessages(unique: 'Valores devem ser únicos'),
      )..unique();

      final errs = schema.errors(['a', 'a']);
      expect(errs!.first.message, 'Valores devem ser únicos');
    });
  });

  group('Global required message via Validart', () {
    test('should propagate to string', () {
      final v = Validart(
        messages: const VMessages(required: 'Campo obrigatório'),
      );
      final errs = v.string().errors(null);
      expect(errs!.first.message, 'Campo obrigatório');
    });

    test('should propagate to int', () {
      final v = Validart(
        messages: const VMessages(required: 'Campo obrigatório'),
      );
      final errs = v.int().errors(null);
      expect(errs!.first.message, 'Campo obrigatório');
    });

    test('should propagate to map', () {
      final v = Validart(
        messages: const VMessages(required: 'Campo obrigatório'),
      );
      final errs = v.map({'name': v.string()}).errors(null);
      expect(errs!.first.message, 'Campo obrigatório');
    });

    test('should propagate to object', () {
      final v = Validart(
        messages: const VMessages(required: 'Campo obrigatório'),
      );
      final errs = v.object<String>().errors(null);
      expect(errs!.first.message, 'Campo obrigatório');
    });

    test('should propagate custom invalidType', () {
      final v = Validart(
        messages: VMessages(
          invalidType: (expected, received) =>
              'Esperado $expected, recebido $received',
        ),
      );
      final errs = v.string().errors(123);
      expect(errs!.first.message, contains('Esperado'));
      expect(errs.first.message, contains('recebido'));
    });
  });
}
