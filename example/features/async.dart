import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for the async API: `refineAsync`, `addAsync`,
/// `preprocessAsync`, `transformAsync`, `validateAsync`, `parseAsync`,
/// `safeParseAsync`, `errorsAsync`, and the `VAsyncRequiredException`
/// thrown when calling sync consumers on an async schema.
Future<void> runAsyncExamples() async {
  section('refineAsync — IO-bound predicate');

  Future<bool> isEmailAvailable(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    return email != 'taken@example.com';
  }

  final schema = V.string().email().refineAsync(
        isEmailAvailable,
        message: 'Email already registered',
        code: 'email_taken',
      );

  print(await schema.validateAsync('new@example.com')); // true
  print(await schema.validateAsync('taken@example.com')); // false

  section('async-only schemas reject sync consumers');

  // Calling the sync API on an async schema throws — the suggestion
  // tells the caller exactly which Async variant to use instead.
  try {
    schema.validate('x');
  } on VAsyncRequiredException catch (e) {
    print('caught: ${e.suggestion}'); // 'validateAsync'
  }

  section('addAsync — reusable AsyncValidator');

  // `UsernameAvailable` lives in shared/fixtures.dart.
  final usernameSchema = V.string().addAsync(const UsernameAvailable());
  print(await usernameSchema.validateAsync('new_user')); // true
  print(await usernameSchema.validateAsync('taken')); // false

  section('refineAsync with timeout');

  // Exceeding the timeout counts as failure; the schema does not hang.
  final slow = V.string().refineAsync(
    (v) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return true;
    },
    timeout: const Duration(milliseconds: 50),
    message: 'Timed out',
  );
  print(await slow.validateAsync('x')); // false

  section('preprocessAsync + min — reshape then validate');

  final resolved = V.string().preprocessAsync((raw) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return raw.toString().trim();
  }).min(3);
  print(await resolved.validateAsync('  hello  ')); // true

  section('transformAsync — change output type asynchronously');

  final lengthFromUuid = V.string().uuid().transformAsync<int>((id) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return id.length;
  });
  print(await lengthFromUuid
      .parseAsync('550e8400-e29b-41d4-a716-446655440000')); // 36

  section('sync schemas keep working without overhead');

  // Schemas without any async step still run sync — `validateAsync`
  // returns `Future<bool>` but resolves synchronously inside the loop.
  print(V.string().email().validate('a@b.com')); // true
}

Future<void> main() => runAsyncExamples();
