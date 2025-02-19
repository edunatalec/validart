import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  final Validart v = Validart();

  group('string', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.string().array();

        expect(validator.validate(['valid']), true);
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });

    group('unique', () {
      test('should validate unique correctly', () {
        final validator = v.string().array().unique();

        expect(validator.validate(['a', 'b', 'c']), true);
        expect(validator.validate(['a', 'b', 'a']), false);
        expect(validator.validate([]), false);
      });
    });

    group('contains', () {
      test('should validate contains correctly', () {
        final validator = v.string().array().contains(['a', 'b']);

        expect(validator.validate(['a', 'b', 'c']), true);
        expect(validator.validate(['a', 'c']), false);
        expect(validator.validate(['b', 'c']), false);
        expect(validator.validate([]), false);
      });
    });

    group('min length', () {
      test('should enforce minimum array length', () {
        final validator = v.string().array().min(2);

        expect(validator.validate(['a', 'b']), true);
        expect(validator.validate(['a']), false);
        expect(validator.validate([]), false);
      });
    });

    group('max length', () {
      test('should enforce maximum array length', () {
        final validator = v.string().array().max(3);

        expect(validator.validate(['a', 'b']), true);
        expect(validator.validate(['a', 'b', 'c']), true);
        expect(validator.validate(['a', 'b', 'c', 'd']), false);
      });
    });

    group('nullable', () {
      test('should validate nullable correctly', () {
        final validator = v.string().array().nullable();

        expect(validator.validate(null), true);
        expect(validator.validate(['valid']), true);
        expect(validator.validate([]), false);
      });
    });

    group('optional', () {
      test('should validate optional correctly', () {
        final validator = v.string().array().optional();

        expect(validator.validate(null), false);
        expect(validator.validate([]), true);
        expect(validator.validate(['valid']), true);
      });
    });

    group('refine', () {
      test('should validate refine function correctly', () {
        final validator = v.string().array().refine(
              (list) => list.length > 2,
              message: 'The array must contain more than 2 items.',
            );

        expect(validator.validate(['a', 'b', 'c']), true);
        expect(validator.validate(['a', 'b']), false);
        expect(validator.validate([]), false);
      });
    });
  });

  group('map', () {
    group('required', () {
      test('should validate required map array correctly', () {
        final validator = v.map({
          'name': v.string().min(3),
        }).array();

        expect(
          validator.validate([
            {'name': 'John'},
            {'name': 'Erick'},
          ]),
          true,
        );
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });

    group('unique', () {
      test('should validate unique maps correctly', () {
        final validator = v
            .map({
              'name': v.string().min(3),
            })
            .array()
            .unique();

        expect(
          validator.validate([
            {'name': 'John'},
            {'name': 'Erick'}
          ]),
          true,
        );
        expect(
          validator.validate([
            {'name': 'John'},
            {'name': 'John'}
          ]),
          false,
        );
      });
    });

    group('contains', () {
      test('should validate contains maps correctly', () {
        final validator = v
            .map({
              'name': v.string().min(3),
            })
            .array()
            .contains([
              {'name': 'Erick'}
            ]);

        expect(
          validator.validate([
            {'name': 'John'},
            {'name': 'Erick'}
          ]),
          true,
        );
        expect(
          validator.validate([
            {'name': 'John'},
            {'name': 'Leo'}
          ]),
          false,
        );
      });
    });

    group('nullable', () {
      test('should validate nullable maps correctly', () {
        final validator = v.map({'name': v.string().min(3)}).array().nullable();

        expect(validator.validate(null), true);
        expect(
          validator.validate([
            {'name': 'John'}
          ]),
          true,
        );
        expect(validator.validate([]), false);
      });
    });

    group('optional', () {
      test('should validate optional maps correctly', () {
        final validator = v.map({'name': v.string().min(3)}).array().optional();

        expect(validator.validate([]), true);
        expect(
          validator.validate([
            {'name': 'John'}
          ]),
          true,
        );
        expect(validator.validate(null), false);
      });
    });

    group('refine', () {
      test('should validate refine function for maps correctly', () {
        final validator = v.map({'key': v.string()}).array().refine(
              (list) => list.length > 1,
              message: 'The array must contain more than 1 item.',
            );

        expect(
          validator.validate([
            {'key': 'value1'},
            {'key': 'value2'}
          ]),
          true,
        );
        expect(
          validator.validate([
            {'key': 'value1'}
          ]),
          false,
        );
      });
    });
  });

  group('bool', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.bool().array();

        expect(validator.validate([false, true, false]), true);
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });
  });

  group('double', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.double().array();

        expect(validator.validate([1.1, 1.2, 100.1]), true);
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });
  });

  group('int', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.int().array();

        expect(validator.validate([1, 1, 100]), true);
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });
  });

  group('num', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.num().array();

        expect(validator.validate([1, 10, 100.1, 0.1111]), true);
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });
  });

  group('date', () {
    group('required', () {
      test('should validate required correctly', () {
        final validator = v.date().array();

        expect(
          validator.validate([
            DateTime.now(),
            DateTime(2025),
            DateTime(2024),
          ]),
          true,
        );
        expect(validator.validate([]), false);
        expect(validator.validate(null), false);
      });
    });
  });
}
