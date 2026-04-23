import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_code.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VUnion', () {
    test('should pass when value matches first option', () {
      final schema = VUnion([VString(), VInt()]);
      expect(schema.validate('hello'), isTrue);
    });

    test('should pass when value matches second option', () {
      final schema = VUnion([VString(), VInt()]);
      expect(schema.validate(42), isTrue);
    });

    test('should fail when value matches no option', () {
      final schema = VUnion([VString(), VInt()]);
      expect(schema.validate(3.14), isFalse);
      expect(schema.validate(true), isFalse);
    });

    test('should fail for null by default', () {
      final schema = VUnion([VString(), VInt()]);
      expect(schema.validate(null), isFalse);
    });

    test('should pass for null when nullable', () {
      final schema = VUnion([VString(), VInt()]).nullable();
      expect(schema.validate(null), isTrue);
    });

    test('should return correct error code', () {
      final schema = VUnion([VString(), VInt()]);
      final errs = schema.errors(3.14);
      expect(errs!.first.code, 'union.invalid');
    });

    test('should work with validators on options', () {
      final schema = VUnion([
        VString().email(),
        VInt().min(0),
      ]);
      expect(schema.validate('test@example.com'), isTrue);
      expect(schema.validate(42), isTrue);
      expect(schema.validate('not-email'), isFalse);
      expect(schema.validate(-1), isFalse);
    });

    test('should work with literal union', () {
      final schema = VUnion([
        VLiteral('admin'),
        VLiteral('user'),
        VLiteral('guest'),
      ]);
      expect(schema.validate('admin'), isTrue);
      expect(schema.validate('user'), isTrue);
      expect(schema.validate('other'), isFalse);
    });

    test('should expose per-option errors in VError.context', () {
      final schema = VUnion([
        VString().email(),
        VInt().positive(),
      ]);

      final errors = schema.errors(3.14);

      expect(errors, isNotNull);
      expect(errors!.first.code, VUnionCode.invalid);
      expect(errors.first.context, isNotNull);
      expect(errors.first.context!.length, 2);
      expect(errors.first.context![0].first.code, VStringCode.invalidType);
      expect(errors.first.context![1].first.code, VIntCode.invalidType);
    });
  });
}
