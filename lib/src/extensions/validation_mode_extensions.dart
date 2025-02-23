import 'package:validart/src/enums/validation_mode.dart';

/// Provides helper methods for `ValidationMode`, making it easier
/// to check whether the validation should consider formatted or unformatted values.
///
/// This extension simplifies condition checks when applying validation rules.
extension ValidationModeExtensions on ValidationMode {
  /// Checks if the validation mode is set to `unformatted`.
  ///
  /// When `true`, the validation expects values **without formatting**.
  ///
  /// ### Example
  /// ```dart
  /// final mode = ValidationMode.unformatted;
  ///
  /// print(mode.isUnformatted); // true
  /// print(mode.isFormatted); // false
  /// ```
  bool get isUnformatted => this == ValidationMode.unformatted;

  /// Checks if the validation mode is set to `formatted`.
  ///
  /// When `true`, the validation expects values **with formatting**.
  ///
  /// ### Example
  /// ```dart
  /// final mode = ValidationMode.formatted;
  ///
  /// print(mode.isFormatted); // true
  /// print(mode.isUnformatted); // false
  /// ```
  bool get isFormatted => this == ValidationMode.formatted;
}
