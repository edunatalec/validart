import 'package:test/test.dart';
import 'package:validart/src/error.dart';

void main() {
  group('VError', () {
    group('copyWith', () {
      test('returns a copy with the same path when no args are passed', () {
        const original = VError(
          code: 'string.email',
          message: 'Invalid email',
          path: ['user', 'email'],
        );

        final copy = original.copyWith();

        expect(copy.code, 'string.email');
        expect(copy.message, 'Invalid email');
        expect(copy.path, ['user', 'email']);
        expect(copy.context, isNull);
      });

      test('overrides path when provided', () {
        const original = VError(code: 'required', message: 'Required');

        final copy = original.copyWith(path: ['name']);

        expect(copy.path, ['name']);
      });

      test('overrides context when provided', () {
        const original = VError(code: 'union', message: 'Union failed');

        final copy = original.copyWith(
          context: const [
            [VError(code: 'string.required', message: 'Required')],
          ],
        );

        expect(copy.context, hasLength(1));
        expect(copy.context!.first.first.code, 'string.required');
      });
    });

    group('hashCode', () {
      test('is stable for the same code/message/path', () {
        const a = VError(code: 'x', message: 'y', path: ['a', 0]);
        const b = VError(code: 'x', message: 'y', path: ['a', 0]);

        expect(a.hashCode, b.hashCode);
      });

      test('differs when code, message, or path differ', () {
        const a = VError(code: 'x', message: 'y');
        const b = VError(code: 'x', message: 'z');
        const c = VError(code: 'x', message: 'y', path: ['a']);

        expect(a.hashCode, isNot(b.hashCode));
        expect(a.hashCode, isNot(c.hashCode));
      });
    });
  });
}
