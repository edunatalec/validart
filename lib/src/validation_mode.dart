/// Controls which formatted variants a pattern accepts.
///
/// Many string validators accept the same information in more than one
/// shape — `123-45-6789` vs `123456789`, `K1A 0B1` vs `K1A0B1`. The mode
/// lets callers pin the input to a specific shape instead of silently
/// accepting both.
///
/// Defaults to [any] on every pattern that supports the mode, which keeps
/// current behavior. Pass [formatted] to require the separators to be
/// present; pass [unformatted] to require them to be absent.
///
/// ```dart
/// V.string().postalCode(
///   pattern: const UkPostcodePattern(mode: ValidationMode.formatted),
/// );
///
/// V.string().taxId(
///   pattern: const UsSsnPattern(mode: ValidationMode.unformatted),
/// );
/// ```
enum ValidationMode {
  /// Accept the input with or without formatting separators.
  ///
  /// The same value in either shape is valid — e.g. `123-45-6789` and
  /// `123456789` are both accepted by [UsSsnPattern] when the mode is
  /// `any`.
  any,

  /// Only accept the input in its fully-formatted form.
  ///
  /// Rejects inputs missing the expected separators.
  formatted,

  /// Only accept the input stripped of formatting separators.
  ///
  /// Rejects inputs that contain any separator character the pattern
  /// would otherwise treat as formatting.
  unformatted,
}
