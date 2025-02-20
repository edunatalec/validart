import 'package:validart/src/messages/map_message.dart';
import 'package:validart/src/types/array.dart';
import 'package:validart/src/types/type.dart';
import 'package:validart/src/validators/refine_map_validator.dart';
import 'package:validart/src/validators/required_validator.dart';
import 'package:validart/src/validators/validator.dart';

/// A validator for `Map<String, dynamic>` values, enabling object validation.
///
/// ### Example
/// ```dart
/// final v = Validart();
///
/// final validator = v.map({
///   'email': v.string().email(),
///   'password': v.string().min(8).max(20),
/// });
///
/// print(validator.validate({'email': 'user@example.com', 'password': 'secure123'})); // true
/// print(validator.validate({'email': 'invalid-email', 'password': '123'})); // false
/// ```
class VMap extends VType<Map<String, dynamic>> {
  /// Stores the object schema definition.
  final Map<String, VType> _object;

  /// Stores the validation messages for `Map` related errors.
  final MapMessage _message;

  /// Creates an instance of `VMap` for validating key-value pairs.
  ///
  /// This constructor initializes the map validator and ensures that the map contains at least one field.
  /// By default, a `RequiredValidator` is applied to enforce that the map is not empty unless explicitly marked as optional.
  ///
  /// ### Example
  /// ```dart
  /// final validator = v.map({
  ///   'name': v.string().min(3),
  ///   'age': v.int().min(18),
  /// });
  ///
  /// print(validator.validate({'name': 'John', 'age': 25})); // true
  /// print(validator.validate({})); // 'Map is required' (invalid)
  /// ```
  ///
  /// ### Parameters
  /// - [_object]: A map where each key is a string and each value is a `VType`, representing the validation rules for each field.
  /// - [_message]: The validation messages used for error handling.
  /// - [message]: *(optional)* A custom error message for required validation.
  ///
  /// ### Behavior
  /// - The map **must** contain at least one field; otherwise, an assertion error is thrown.
  /// - By default, the map is required. To allow an empty or missing map, use `.optional()`.
  VMap(this._object, this._message, {String? message}) {
    assert(_object.isNotEmpty, 'Map must have at least one field.');
    add(RequiredValidator(message: message ?? _message.required));
  }

  /// Retrieves the object schema containing validation types for each key.
  ///
  /// This getter returns a map where each key represents a field name, and the value is a `VType`
  /// instance defining the validation rules for that field.
  ///
  /// ### Example
  /// ```dart
  /// final schema = v.object({
  ///   'name': v.string().min(3),
  ///   'age': v.number().min(18),
  /// });
  ///
  /// print(schema.object);
  /// // { "name": VString, "age": VNumber }
  /// ```
  ///
  /// ### Returns
  /// A `Map<String, VType>` containing the validation types associated with each field.
  Map<String, VType> get object => _object;

  /// Creates an array validator (`VArray<Map<String, dynamic>>`) for validating lists of objects.
  ///
  /// This method enables validation of arrays where each element is a `Map<String, dynamic>`,
  /// applying the same validation rules defined for the individual map validator.
  ///
  /// ### Parameters
  /// - [message] *(optional)*: A custom validation message for array validation errors.
  ///
  /// ### Returns
  /// A `VArray<Map<String, dynamic>>` instance for validating lists of objects.
  VArray<Map<String, dynamic>> array({String? message}) {
    return VArray<Map<String, dynamic>>(this, _message.array, message: message);
  }

  /// Applies a custom validation function to the map.
  ///
  /// This method allows defining a custom validation rule using a function that evaluates
  /// the map and returns `true` if valid. The validation is applied to a specific key path.
  ///
  /// ### Parameters
  /// - [validator]: A function that takes a `Map<String, dynamic>` and returns `true` if valid.
  /// - [path]: The specific key path in the map where the validation should be applied.
  /// - [message] *(optional)*: A custom error message if the validation fails.
  ///
  /// ### Returns
  /// The current `VMap` instance with the custom validation applied.
  VMap refine(
    bool Function(Map<String, dynamic> data) validator, {
    required String path,
    String? message,
  }) {
    assert(
      _object.containsKey(path),
      "The provided path '$path' does not exist in the validation object.",
    );

    return add(
      RefineMapValidator(
        validator,
        path: path,
        message: message ?? _message.refine,
      ),
    );
  }

  /// Adds a custom validator to the `VMap` instance.
  ///
  /// This method allows adding additional validation rules for map values,
  /// enabling more flexible and specific constraints.
  ///
  /// ### Parameters
  /// - [validator]: A custom validator that extends `Validator<Map<String, dynamic>>`.
  ///
  /// ### Returns
  /// The current `VMap` instance with the added validator.
  @override
  VMap add(Validator<Map<String, dynamic>> validator) {
    super.add(validator);
    return this;
  }

  /// Marks the map as nullable, allowing `null` as a valid value.
  ///
  /// When this method is applied, the validation will pass if the value is `null`,
  /// otherwise, all other validation rules will be checked.
  ///
  /// ### Returns
  /// The current `VMap` instance with the `nullable` flag enabled.
  @override
  VMap nullable() {
    super.nullable();
    return this;
  }

  /// Marks the map as optional, meaning it does not require a value.
  ///
  /// When this method is applied, an empty map will pass validation, while
  /// other validation rules will still apply if a value is provided.
  ///
  /// ### Returns
  /// The current `VMap` instance with the `optional` flag enabled.
  @override
  VMap optional() {
    super.optional();
    return this;
  }

  /// Retrieves the error message for the given map.
  ///
  /// This method first applies all validators attached to the map itself.
  /// If the map-level validation passes, it then checks each individual entry
  /// against its respective validation rules. The first validation failure
  /// encountered at either level will be returned.
  ///
  /// ### Validation Order
  /// 1. The map-level validators (e.g., `.required()`, `.refine()`) are checked first.
  /// 2. If the map passes, each key-value pair inside the map is validated individually.
  ///
  /// ### Returns
  /// - `null` if the map and all its entries pass validation.
  /// - A `Map<String, dynamic>` containing validation error messages for failing fields.
  @override
  Map<String, dynamic>? getErrorMessage(Map<String, dynamic>? value) {
    if (value == null && isNullable) return null;

    final Map<String, dynamic> errors = {};

    for (final validator in validators) {
      final message = validator.validate(value);

      if (message != null) {
        if (validator is RequiredValidator && isOptional && value != null) {
          return null;
        }

        if (validator is! RequiredValidator) {
          errors.addAll({(validator as dynamic).path: message});
        }
      }
    }

    for (final entry in _object.entries) {
      final error = entry.value.getErrorMessage(value?[entry.key]);

      if (error != null) {
        errors.addAll({entry.key: error});
      }
    }

    return errors.isEmpty ? null : errors;
  }
}
