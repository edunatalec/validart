import 'package:test/test.dart';
import 'package:validart/validart.dart';

class _VerifyDeviceDto {
  const _VerifyDeviceDto({required this.code, this.email});

  final String code;
  final String? email;
}

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('applyIf', () {
    test('condition true invokes the builder', () {
      final base = V.string().email();
      final result = base.applyIf(true, (s) => s.nullable());

      expect(result.validate(null), isTrue);
    });

    test('condition false returns the receiver unchanged', () {
      final base = V.string().email();
      final result = base.applyIf(false, (s) => s.nullable());

      expect(identical(result, base), isTrue);
      expect(result.validate(null), isFalse);
    });

    test('preserves concrete type for further fluent chain', () {
      final result =
          V.string().email().applyIf(true, (s) => s.nullable()).min(2);

      expect(result, isA<VString>());
      expect(result.validate('a@b.com'), isTrue);
      expect(result.validate(null), isTrue);
      expect(result.validate('a'), isFalse);
    });

    test('VInt preserves its concrete type', () {
      final result = V.int().applyIf(true, (s) => s.min(5));

      expect(result, isA<VInt>());
      expect(result.validate(10), isTrue);
      expect(result.validate(2), isFalse);
    });

    test('chained applyIf simulates if/else with negated condition', () {
      VString build(bool isAdmin) => V
          .string()
          .applyIf(isAdmin, (s) => s.min(10))
          .applyIf(!isAdmin, (s) => s.min(3));

      expect(build(true).validate('admin12345'), isTrue);
      expect(build(true).validate('short'), isFalse);
      expect(build(false).validate('abc'), isTrue);
      expect(build(false).validate('ab'), isFalse);
    });

    test('use case: parametrize nullable on a VObject field', () {
      VObject<_VerifyDeviceDto> schemaFor({required bool needsEmail}) {
        return V
            .object<_VerifyDeviceDto>()
            .field('code', (d) => d.code, V.string().min(6))
            .field(
              'email',
              (d) => d.email,
              V.string().email().applyIf(!needsEmail, (s) => s.nullable()),
            );
      }

      final required = schemaFor(needsEmail: true);
      expect(
        required.validate(const _VerifyDeviceDto(code: '123456')),
        isFalse,
        reason: 'needsEmail true → email cannot be null',
      );
      expect(
        required.validate(
          const _VerifyDeviceDto(code: '123456', email: 'a@b.com'),
        ),
        isTrue,
      );

      final optional = schemaFor(needsEmail: false);
      expect(
        optional.validate(const _VerifyDeviceDto(code: '123456')),
        isTrue,
        reason: 'needsEmail false → email may be null',
      );
      expect(
        optional.validate(
          const _VerifyDeviceDto(code: '123456', email: 'a@b.com'),
        ),
        isTrue,
      );
    });

    test('builder receives the receiver and may swap to a different schema',
        () {
      // The builder is free to derive any schema of the same concrete
      // type; here we replace VString.email() with a simpler chain on
      // the false-branch side.
      VString build(bool strict) =>
          V.string().applyIf(strict, (s) => s.email().min(10));

      expect(build(true).validate('a@b.com'), isFalse);
      expect(build(true).validate('foo@example.com'), isTrue);
      expect(build(false).validate('any'), isTrue);
    });
  });
}
