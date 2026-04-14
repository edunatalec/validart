import 'package:test/test.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/v.dart';
import 'package:validart/src/v_locale.dart';

class Folder {
  final String? id;
  final String name;
  Folder({this.id, required this.name});
}

void main() {
  setUp(() => V.setLocale(const VLocale()));

  group('VObject', () {
    // ── simple not-null check ─────────────────────────────────────────────
    group('simple not-null check', () {
      test('should pass for non-null Folder instance', () {
        final schema = VObject<Folder>();
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail for null', () {
        final schema = VObject<Folder>();
        expect(schema.validate(null), isFalse);
      });

      test('should return required error for null', () {
        final schema = VObject<Folder>();
        final errors = schema.errors(null);
        expect(errors, isNotNull);
        expect(errors!.first.code, 'required');
      });

      test('should pass for Folder with all fields', () {
        final schema = VObject<Folder>();
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Documents',
          )),
          isTrue,
        );
      });
    });

    // ── field validation with path errors ─────────────────────────────────
    group('field validation', () {
      test('should validate fields and pass for valid data', () {
        final schema = VObject<Folder>(
            configure: (o) => o
                .field(
                  'id',
                  (f) => f.id,
                  VString()
                    ..uuid()
                    ..optional(),
                )
                .field('name', (f) => f.name, VString()..min(1)));
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail for invalid field', () {
        final schema = VObject<Folder>(
            configure: (o) => o.field(
                  'name',
                  (f) => f.name,
                  VString()..min(5),
                ));
        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('should include field name in error path', () {
        final schema = VObject<Folder>(
            configure: (o) => o.field(
                  'name',
                  (f) => f.name,
                  VString()..min(5),
                ));
        final errors = schema.errors(Folder(name: 'Doc'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'too_small');
        expect(errors.first.path, ['name']);
      });

      test('should validate uuid field', () {
        final schema = VObject<Folder>(
            configure: (o) => o.field(
                  'id',
                  (f) => f.id,
                  VString()..uuid(),
                ));
        expect(
          schema.validate(Folder(
            id: '550e8400-e29b-41d4-a716-446655440000',
            name: 'Test',
          )),
          isTrue,
        );
      });

      test('should fail for invalid uuid field', () {
        final schema = VObject<Folder>(
            configure: (o) => o.field(
                  'id',
                  (f) => f.id,
                  VString()..uuid(),
                ));
        final errors = schema.errors(Folder(id: 'not-a-uuid', name: 'Test'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'invalid_uuid');
        expect(errors.first.path, ['id']);
      });

      test('should collect multiple field errors', () {
        final schema = VObject<Folder>(
            configure: (o) => o
                .field('id', (f) => f.id, VString()..uuid())
                .field('name', (f) => f.name, VString()..min(10)));
        final errors = schema.errors(Folder(id: 'bad', name: 'short'));
        expect(errors, isNotNull);
        expect(errors!.length, 2);
        expect(errors[0].path, ['id']);
        expect(errors[1].path, ['name']);
      });
    });

    // ── refine ────────────────────────────────────────────────────────────
    group('refine', () {
      test('should add custom validation', () {
        final schema = VObject<Folder>()
          ..refine(
            (f) => f.name.isNotEmpty,
            message: 'Name cannot be empty',
            code: 'empty_name',
          );
        expect(schema.validate(Folder(name: 'Documents')), isTrue);
      });

      test('should fail custom validation', () {
        final schema = VObject<Folder>()
          ..refine(
            (f) => f.name.length >= 5,
            message: 'Name too short',
            code: 'name_too_short',
          );
        expect(schema.validate(Folder(name: 'Doc')), isFalse);
      });

      test('should return custom error code', () {
        final schema = VObject<Folder>()
          ..refine(
            (f) => f.id != null,
            message: 'ID is required',
            code: 'missing_id',
          );
        final errors = schema.errors(Folder(name: 'Test'));
        expect(errors, isNotNull);
        expect(errors!.first.code, 'missing_id');
        expect(errors.first.message, 'ID is required');
      });
    });

    // ── nullable / optional ───────────────────────────────────────────────
    group('nullable and optional', () {
      test('nullable should allow null', () {
        final schema = VObject<Folder>()..nullable();
        expect(schema.validate(null), isTrue);
      });

      test('nullable should parse null to null', () {
        final schema = VObject<Folder>()..nullable();
        expect(schema.parse(null), isNull);
      });

      test('optional should allow null', () {
        final schema = VObject<Folder>()..optional();
        expect(schema.validate(null), isTrue);
      });

      test('defaultValue should return default when null', () {
        final fallback = Folder(name: 'Default');
        final schema = VObject<Folder>()..defaultValue(fallback);
        final result = schema.parse(null);
        expect(result, fallback);
      });
    });

    // ── wrong type input ──────────────────────────────────────────────────
    group('wrong type input', () {
      test('should fail for string input', () {
        final schema = VObject<Folder>();
        expect(schema.validate('not a folder'), isFalse);
      });

      test('should return invalid_type error for wrong type', () {
        final schema = VObject<Folder>();
        final errors = schema.errors('not a folder');
        expect(errors, isNotNull);
        expect(errors!.first.code, 'invalid_type');
      });

      test('should fail for int input', () {
        final schema = VObject<Folder>();
        expect(schema.validate(42), isFalse);
      });

      test('should fail for list input', () {
        final schema = VObject<Folder>();
        expect(schema.validate([1, 2, 3]), isFalse);
      });

      test('should fail for map input', () {
        final schema = VObject<Folder>();
        expect(schema.validate({'name': 'test'}), isFalse);
      });
    });

    // ── combined with VMap ────────────────────────────────────────────────
    group('combined with VMap', () {
      test('should use VObject inside VMap schema', () {
        final schema = VMap({
          'folder': VObject<Folder>(
              configure: (o) => o.field(
                    'name',
                    (f) => f.name,
                    VString()..min(1),
                  )),
        });
        expect(
          schema.validate({'folder': Folder(name: 'Documents')}),
          isTrue,
        );
      });

      test('should fail when VObject field inside VMap is invalid', () {
        final schema = VMap({
          'folder': VObject<Folder>(
              configure: (o) => o.field(
                    'name',
                    (f) => f.name,
                    VString()..min(10),
                  )),
        });
        expect(
          schema.validate({'folder': Folder(name: 'Doc')}),
          isFalse,
        );
      });

      test('should produce nested path for VObject inside VMap', () {
        final schema = VMap({
          'folder': VObject<Folder>(
              configure: (o) => o.field(
                    'name',
                    (f) => f.name,
                    VString()..min(10),
                  )),
        });
        final errors = schema.errors({'folder': Folder(name: 'Doc')});
        expect(errors, isNotNull);
        expect(errors!.first.path, ['folder', 'name']);
      });

      test('should fail when VObject field in VMap is null', () {
        final schema = VMap({
          'folder': VObject<Folder>(),
        });
        final errors = schema.errors({'folder': null});
        expect(errors, isNotNull);
        expect(errors!.first.code, 'required');
        expect(errors.first.path, ['folder']);
      });
    });
  });
}
