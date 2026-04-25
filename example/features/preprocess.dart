import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.preprocess(...)`, `.preprocessAsync(...)`, and the
/// public accessors `runPreprocessors` / `runPreprocessorsAsync` /
/// `hasPreprocessors`.
///
/// Preprocessors run **before** the type check, before `_resolveNull`,
/// and before any validator — they reshape the raw input.
void runPreprocessExamples() {
  section('preprocess — reshape before validation');

  // Trim whitespace. Same `.parse('  hi  ')` would have failed `.min(2)`
  // without the trim because spaces count as length too.
  print(V.string().preprocess((v) => (v as String).trim()).parse('  hi  '));
  // 'hi'

  // Coerce raw int into a string for downstream validators.
  print(V.string().preprocess((v) => v?.toString() ?? '').parse(42));
  // '42'

  section('preprocessAsync — IO-bound reshape');

  // Resolve an alias lookup before validating. Async-only schema —
  // sync consumers throw VAsyncRequiredException.
  final aliased = V.string().preprocessAsync((v) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return (v as String).trim().toLowerCase();
  }).min(3);

  // Run the assertion via a sync-shaped main by awaiting in a Future.
  () async {
    print(await aliased.validateAsync('  Hello  ')); // true
  }();

  section('runPreprocessors — apply ONLY the preprocess stage');

  // Most consumers never need this — `parse` / `safeParse` already
  // include the preprocess stage. But when bridging into a different
  // pipeline (form libraries that revalidate per-field, snapshots,
  // custom debuggers), you sometimes want only the reshape — without
  // null handling, validators, or transforms.
  final greeting = V
      .string()
      .preprocess((v) => (v as String).trim())
      .min(3); // .min(3) does NOT run for runPreprocessors

  print(greeting.runPreprocessors('  hi  ')); // 'hi'
  print(greeting.runPreprocessors('  a  ')); // 'a' — no min check fired

  section('runPreprocessorsAsync — sync + async, in order');

  // Sync chain runs first (registration order), then async.
  final pipeline = V
      .string()
      .preprocess((v) => '${v as String}-sync')
      .preprocessAsync((v) async => '${v as String}-async');

  () async {
    print(await pipeline.runPreprocessorsAsync('x'));
    // 'x-sync-async'
  }();

  section('hasPreprocessors — gate downstream work');

  // Useful for consumers that build a snapshot only when needed.
  print(V.string().hasPreprocessors); // false
  print(V.string().preprocess((v) => v).hasPreprocessors); // true
  print(V.string().preprocessAsync((v) async => v).hasPreprocessors); // true

  section('preprocess on VMap container');

  // A container preprocessor sees the raw map and can normalize it
  // before per-field validators run.
  final user = V.map({
    'name': V.string().min(1),
  }).preprocess((raw) {
    final m = Map<String, dynamic>.from(raw as Map);
    if ((m['name'] as String).trim().isEmpty) m['name'] = 'Anonymous';
    return m;
  });

  print(user.parse({'name': '   '})); // {name: Anonymous}
}

void main() => runPreprocessExamples();
