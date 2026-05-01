import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that all elements in a list are distinct **by the value
/// returned from [by]**. Use this when elements are `Map` or class
/// instances and uniqueness is determined by a property (an `id`, an
/// `email`, ...) rather than reference equality.
///
/// Emits the same error code as `UniqueValidator` (`VArrayCode.unique`)
/// since the failure mode is identical: the array contains duplicates.
class DistinctValidator<T> extends Validator<List<T>> {
  /// Extracts the uniqueness key from each element. The returned value
  /// must implement `==` and `hashCode` correctly (primitives, enums,
  /// strings, etc., do; bare class instances compare by reference unless
  /// you override `==`/`hashCode`).
  final Object Function(T element) by;

  /// Creates a [DistinctValidator] with the given [by] extractor.
  const DistinctValidator({required this.by});

  @override
  String get code => VArrayCode.unique;

  @override
  Map<String, dynamic>? validate(List<T> value) {
    final Set<Object> keys = value.map(by).toSet();

    return keys.length == value.length ? null : {};
  }
}
