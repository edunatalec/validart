// Aggregator entry point — runs every per-type and per-feature
// example file in `example/types/` and `example/features/`. Each file
// is also runnable standalone (every file has its own `main()`), so
// this aggregator is just a convenience for `dart run example/example.dart`.
//
// Layout:
//   example/types/<type>.dart       — one file per VType
//   example/features/<feature>.dart — coerce, when, equalFields, refine,
//                                     preprocess, transform, async,
//                                     composition, locale, errors,
//                                     nullable_default, patterns
//   example/shared/fixtures.dart    — DTOs, enums, custom patterns
//                                     reused across the files above

import 'features/async.dart';
import 'features/coerce.dart';
import 'features/composition.dart';
import 'features/equal_fields.dart';
import 'features/errors.dart';
import 'features/locale.dart';
import 'features/nullable_default.dart';
import 'features/patterns.dart';
import 'features/preprocess.dart';
import 'features/refine.dart';
import 'features/transform.dart';
import 'features/when.dart';
import 'types/array.dart';
import 'types/bool.dart';
import 'types/date.dart';
import 'types/double.dart';
import 'types/enum.dart';
import 'types/int.dart';
import 'types/literal.dart';
import 'types/map.dart';
import 'types/object.dart';
import 'types/string.dart';
import 'types/union.dart';

Future<void> main() async {
  print('=== Types ===');
  runStringExamples();
  runIntExamples();
  runDoubleExamples();
  runBoolExamples();
  runDateExamples();
  runArrayExamples();
  runMapExamples();
  runObjectExamples();
  runEnumExamples();
  runLiteralExamples();
  runUnionExamples();

  print('\n=== Features ===');
  runCoerceExamples();
  runNullableDefaultExamples();
  runPreprocessExamples();
  runTransformExamples();
  runRefineExamples();
  runEqualFieldsExamples();
  runWhenExamples();
  runCompositionExamples();
  runErrorsExamples();
  runPatternsExamples();
  runLocaleExamples();
  await runAsyncExamples();
}
