import 'package:validart/validart.dart';

import '../shared/fixtures.dart';

/// Examples for `.applyIf(condition, builder)` — a tiny extension on
/// every `VType` that conditionally transforms the schema at
/// **construction time** (not at validation time). Pair it with a flag
/// known at the call site to avoid duplicating the schema body for
/// each branch.
///
/// For runtime cross-field rules use `whenMatches` on `VMap`/`VObject`.
/// For an else-branch, chain a second `applyIf` with the negated
/// condition.
void runApplyIfExamples() {
  section('applyIf — parametrize nullable from an external flag');

  // Tax-id is nullable only when the form is in "draft" mode.
  VString taxIdField({required bool draft}) =>
      V.string().min(11).applyIf(draft, (s) => s.nullable());

  print(taxIdField(draft: true).validate(null)); // true
  print(taxIdField(draft: false).validate(null)); // false
  print(taxIdField(draft: false).validate('12345678901')); // true

  section('applyIf — chained for if/else');

  // Strict mode requires a longer code; lax mode keeps the default.
  VString codeField({required bool strict}) => V
      .string()
      .applyIf(strict, (s) => s.min(10))
      .applyIf(!strict, (s) => s.min(3));

  print(codeField(strict: true).validate('short')); // false
  print(codeField(strict: true).validate('abcdefghij')); // true
  print(codeField(strict: false).validate('abc')); // true
  print(codeField(strict: false).validate('ab')); // false

  section('applyIf — used inside a VObject field');

  // Sign-up DTO where `confirm` is required only on the public flow;
  // internal admin flow accepts any string.
  VObject<SignUpDto> signUpSchema({required bool publicFlow}) => V
      .object<SignUpDto>()
      .field('email', (d) => d.email, V.string().email())
      .field('password', (d) => d.password, V.string().password())
      .field(
        'confirm',
        (d) => d.confirm,
        V.string().applyIf(publicFlow, (s) => s.min(8)),
      );

  print(
    signUpSchema(publicFlow: true).validate(
      const SignUpDto(
        email: 'a@b.com',
        password: 'Str0ng!Pass',
        confirm: 'Str0ng!',
      ),
    ),
  ); // false — confirm too short on public flow

  print(
    signUpSchema(publicFlow: false).validate(
      const SignUpDto(
        email: 'a@b.com',
        password: 'Str0ng!Pass',
        confirm: 'x',
      ),
    ),
  ); // true — internal flow skips the confirm length check
}

void main() => runApplyIfExamples();
