/// Defines the validation mode for formatted and unformatted values.
///
/// This enum determines whether the validation process should consider the formatting of input data.
///
/// ### Variants
/// - `formatted` → The value must be validated **with** formatting (e.g., `+1 (123) 456-7890`).
/// - `unformatted` → The value must be validated **without** formatting (e.g., `11234567890`).
enum ValidationMode {
  /// The value must be validated in its **formatted** representation.
  formatted,

  /// The value must be validated in its **unformatted** representation.
  unformatted,
}
