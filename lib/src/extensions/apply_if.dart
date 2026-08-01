import '../types/type.dart';

/// Conditional schema construction. Applies a [builder] transformation to
/// the receiver only when [condition] is `true`, returning the receiver
/// unchanged otherwise.
///
/// `applyIf` runs at schema-construction time, **not** at validation time —
/// it produces a different schema based on a flag known when the schema
/// is built (a feature toggle, a request context, a config value). For
/// runtime cross-field rules, use `whenMatches` on [VMap]/[VObject].
///
/// The generic `<V extends VType>` preserves the receiver's concrete
/// type, so the fluent chain keeps working after the call (e.g.
/// `V.string().applyIf(...).email()` still returns [VString]). This
/// preservation requires the receiver to be statically typed as the
/// concrete subtype. Erasing the type to a bare [VType] before calling
/// `applyIf` collapses the inferred type to `VType<dynamic>`.
///
/// For an else-branch, chain a second `applyIf` with the negated
/// condition:
///
/// ```dart
/// schema
///   .applyIf(role == 'admin', (s) => s.min(10))
///   .applyIf(role != 'admin', (s) => s.min(3));
/// ```
///
/// ```dart
/// // Make `email` nullable only when the caller did not require it.
/// V.object<VerifyDeviceDto>()
///     .field('code', (d) => d.code, V.string().min(6))
///     .field(
///       'email',
///       (d) => d.email,
///       V.string().email().applyIf(!needsEmail, (s) => s.nullable()),
///     );
/// ```
///
/// See also:
///
///  * [VType], the base every schema extends.
///  * [VMap], whose conditional rules gate on values only known at
///    validation time.
extension VTypeApplyIf<V extends VType> on V {
  /// Returns `builder(this)` when [condition] is `true`; returns `this`
  /// unchanged otherwise.
  V applyIf(bool condition, V Function(V schema) builder) =>
      condition ? builder(this) : this;
}
