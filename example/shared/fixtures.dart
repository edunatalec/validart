import 'package:validart/validart.dart';

/// Sample enum used by `types/enum.dart` and other files that need a
/// non-trivial Dart enum.
enum Color { red, green, blue }

/// Plain data class consumed by `types/object.dart`.
class Folder {
  final String id;
  final String name;

  Folder({required this.id, required this.name});
}

/// Minimal sign-in DTO. Demonstrates the canonical `static final schema`
/// pattern from the README.
class SignInDto {
  final String email;
  final String password;

  const SignInDto({required this.email, required this.password});

  static final schema = V
      .object<SignInDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password());
}

/// Sign-up DTO with password confirmation. Shows `equalFields` on
/// `VObject`.
class SignUpDto {
  final String email;
  final String password;
  final String confirm;

  const SignUpDto({
    required this.email,
    required this.password,
    required this.confirm,
  });

  static final schema = V
      .object<SignUpDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .field('confirm', (d) => d.confirm, V.string())
      .equalFields('password', 'confirm');
}

/// Custom phone pattern used in `features/patterns.dart` to demonstrate
/// extending the pluggable-patterns API.
class LocalPhonePattern extends PhonePattern {
  const LocalPhonePattern();

  @override
  String get code => 'invalid_phone_local';

  @override
  Map<String, dynamic>? validate(String value) =>
      value.startsWith('LOCAL:') ? null : {};
}

/// Custom tax-id pattern (string-prefixed sentinel). Same purpose as
/// [LocalPhonePattern] — demonstrate the extension hook.
class DummyTaxIdPattern extends TaxIdPattern {
  const DummyTaxIdPattern();

  @override
  String get name => 'Dummy Tax ID';

  @override
  bool matches(String value) => value.startsWith('TAX:');
}

/// Custom license-plate pattern matching `ABC-1234` shape.
class DummyPlatePattern extends LicensePlatePattern {
  const DummyPlatePattern();

  @override
  String get name => 'Dummy Plate';

  @override
  bool matches(String value) => RegExp(r'^[A-Z]{3}-\d{4}$').hasMatch(value);
}

/// Async validator demoing `addAsync` in `features/async.dart`.
class UsernameAvailable extends AsyncValidator<String> {
  const UsernameAvailable();

  @override
  String get code => 'username_taken';

  @override
  Future<Map<String, dynamic>?> validate(String value) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    return value == 'taken' ? {} : null;
  }
}

/// Helper that prints a section header. Keeps the output of every
/// example file visually consistent when run standalone or via the
/// aggregator in `example/example.dart`.
void section(String name) {
  print('\n--- $name ---');
}
