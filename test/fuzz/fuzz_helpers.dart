import 'dart:math';

/// Seed used by every fuzz test. Fixed on purpose so failures are
/// reproducible. Override at runtime with `FUZZ_SEED=<int>` (only works
/// when the test respects [envSeed]).
const int kFuzzSeed = 42;

/// Default iteration count per fuzz property. Balances coverage and
/// test-suite runtime (~1s per file with this value).
const int kFuzzIterations = 500;

/// Resolves the seed from the environment variable `FUZZ_SEED`, falling
/// back to [kFuzzSeed] when unset or malformed.
int envSeed() {
  const fromEnv = String.fromEnvironment('FUZZ_SEED');

  return int.tryParse(fromEnv) ?? kFuzzSeed;
}

/// Handful of ASCII printable chars used for "mostly valid" strings.
const String kAsciiPrintable =
    ' !"#\$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

/// Adversarial Unicode scalars used to stress validators: control chars,
/// zero-width, bidi overrides, combining marks, surrogates, high code
/// points. Written as escape sequences to keep the source ASCII-safe
/// and avoid `text_direction_code_point_in_literal` warnings.
const List<String> kAdversarialChars = [
  '\u{0000}', // NUL
  '\u{0007}', // BEL
  '\u{001B}', // ESC
  '\u{007F}', // DEL
  '\u{200B}', // zero-width space
  '\u{200E}', // left-to-right mark
  '\u{200F}', // right-to-left mark
  '\u{202E}', // right-to-left override
  '\u{00A0}', // non-breaking space
  '\u{0301}', // combining acute accent
  '\u{FFFD}', // replacement char
  '\u{FFFF}', // non-character
  '\u{1F600}', // emoji (surrogate pair)
  '\u{10FFFF}', // max Unicode code point
];

/// Random ASCII-printable string of [len] characters.
String randomAscii(Random rng, int len) {
  final buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    buf.write(kAsciiPrintable[rng.nextInt(kAsciiPrintable.length)]);
  }

  return buf.toString();
}

/// Random string that mixes ASCII-printable and adversarial Unicode
/// characters. Good for testing that validators neither crash nor
/// accept garbage.
String randomAdversarial(Random rng, int len) {
  final buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    if (rng.nextInt(10) < 3) {
      buf.write(kAdversarialChars[rng.nextInt(kAdversarialChars.length)]);
    } else {
      buf.write(kAsciiPrintable[rng.nextInt(kAsciiPrintable.length)]);
    }
  }

  return buf.toString();
}

/// Random digit-only string of [len] digits.
String randomDigits(Random rng, int len) {
  final buf = StringBuffer();

  for (int i = 0; i < len; i++) {
    buf.write(rng.nextInt(10));
  }

  return buf.toString();
}

/// Random integer in the full Dart int range (including negatives and
/// large magnitudes).
int randomInt(Random rng) {
  final magnitude = rng.nextInt(1 << 31);
  final sign = rng.nextBool() ? 1 : -1;

  return sign * magnitude;
}

/// Random double sampling edge cases: NaN, Infinity, subnormal, zero,
/// and uniformly-distributed finite values.
double randomDouble(Random rng) {
  switch (rng.nextInt(20)) {
    case 0:
      return double.nan;
    case 1:
      return double.infinity;
    case 2:
      return double.negativeInfinity;
    case 3:
      return 0.0;
    case 4:
      return -0.0;
    case 5:
      return double.minPositive;
    case 6:
      return double.maxFinite;
    case 7:
      return -double.maxFinite;
    default:
      return (rng.nextDouble() - 0.5) * 2 * 1e12;
  }
}

/// Iterates [kFuzzIterations] times, passing a seeded [Random] and the
/// iteration index to [body]. Failures print the seed so they can be
/// reproduced with `FUZZ_SEED=<n>`.
void fuzz(
  String description,
  void Function(Random rng, int iteration) body, {
  int? iterations,
  int? seed,
}) {
  final actualSeed = seed ?? envSeed();
  final rng = Random(actualSeed);
  final count = iterations ?? kFuzzIterations;

  for (int i = 0; i < count; i++) {
    try {
      body(rng, i);
    } catch (e, s) {
      throw StateError(
        'fuzz property "$description" failed at iteration $i '
        '(seed=$actualSeed): $e\n$s',
      );
    }
  }
}
