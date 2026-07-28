import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('fluent chain type preservation', () {
    test('VString preserves type through base VType methods', () {
      final VString a = V.string().nullable().email();
      final VString b = V.string().defaultValue('x').min(1);
      final VString c = V.string().preprocess((v) => v).email();
      final VString d = V.string().refine((_) => true).email();

      expect(a.validate('a@b.com'), isTrue);
      expect(b.validate('x'), isTrue);
      expect(c.validate('a@b.com'), isTrue);
      expect(d.validate('a@b.com'), isTrue);
    });

    test('VBool preserves type through base VType methods', () {
      final VBool a = V.bool().nullable().isTrue();
      final VBool b = V.bool().defaultValue(false).isFalse();

      expect(a.validate(true), isTrue);
      expect(b.validate(false), isTrue);
    });

    test('VInt preserves type through VNumber and VType methods', () {
      final VInt a = V.int().nullable().even();
      final VInt b = V.int().positive().even();
      final VInt c = V.int().min(0).odd();
      final VInt d = V.int().defaultValue(0).prime();

      expect(a.validate(4), isTrue);
      expect(b.validate(4), isTrue);
      expect(c.validate(3), isTrue);
      expect(d.validate(7), isTrue);
    });

    test('VDouble preserves type through VNumber and VType methods', () {
      final VDouble a = V.double().nullable().finite();
      final VDouble b = V.double().positive().decimal();
      final VDouble c = V.double().min(0.0).integer();

      expect(a.validate(3.14), isTrue);
      expect(b.validate(3.14), isTrue);
      expect(c.validate(3.0), isTrue);
    });

    test('VDate preserves type through base VType methods', () {
      final VDate a = V.date().nullable().weekday();
      final VDate b = V.date().defaultValue(DateTime(2024)).weekend();

      expect(a.validate(DateTime(2024, 1, 15)), isTrue);
      expect(b.validate(DateTime(2024, 1, 14)), isTrue);
    });

    test('VArray preserves type through base VType methods', () {
      final VArray<String> a = V.string().array().nullable().min(1);
      final VArray<int> b =
          V.int().array().defaultValue(const <int>[]).unique();

      expect(a.validate(['x']), isTrue);
      expect(b.validate([1, 2, 3]), isTrue);
    });

    test('VMap preserves type through base VType methods', () {
      final VMap a = V.map({'x': V.string()}).nullable().strict();
      final VMap b = V.map({'x': V.string()}).passthrough().strict();

      expect(a.validate({'x': 'y'}), isTrue);
      expect(b.validate({'x': 'y'}), isTrue);
    });

    test('VString.treatEmptyAsNull() returns VString (fluent chain)', () {
      final VString a = V.string().treatEmptyAsNull().nullable().email();

      expect(a.validate(''), isTrue);
      expect(a.validate('user@mail.com'), isTrue);
    });

    test('VObject preserves type through base VType methods', () {
      final VObject<String> a = V.object<String>().nullable();

      expect(a.validate('x'), isTrue);
    });

    test('VObject.strict() / passthrough() return VObject<T> (fluent chain)',
        () {
      final VObject<String> a = V
          .object<String>()
          .field('length', (s) => s.length, V.int().positive())
          .strict();
      final VObject<String> b = V
          .object<String>()
          .field('length', (s) => s.length, V.int().positive())
          .passthrough();

      expect(a.validate('x'), isTrue);
      expect(b.validate('x'), isTrue);
    });

    test('VObject.field returns VObject<T> (fluent chain)', () {
      final VObject<String> a = V
          .object<String>()
          .field('length', (s) => s.length, V.int().positive())
          .nullable();

      expect(a.validate('hello'), isTrue);
      expect(a.validate(null), isTrue);
    });

    test('VMap.partial(except:) returns VMap (fluent chain)', () {
      final VMap a =
          V.map({'id': V.string().uuid(), 'name': V.string()}).partial(
        except: const ['id'],
      );

      expect(
        a.validate({'id': '550e8400-e29b-41d4-a716-446655440000'}),
        isTrue,
      );
    });

    test('VObject.partial(except:) returns VObject<T> (fluent chain)', () {
      final VObject<String> a = V
          .object<String>()
          .field('length', (s) => s.length, V.int().positive())
          .partial(except: const ['length']);

      expect(a.validate('hello'), isTrue);
    });
  });
}
