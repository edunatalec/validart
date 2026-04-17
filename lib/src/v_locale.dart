/// Provides locale-aware error message translations.
///
/// Uses `{param}` interpolation for dynamic values. Falls back to the
/// default English messages when a translation is not found.
///
/// ```dart
/// V.setLocale(const VLocale({
///   'required': 'Campo obrigatório',
///   'invalid_email': 'E-mail inválido',
/// }));
/// ```
class VLocale {
  final Map<String, String> _translations;

  /// Creates a [VLocale] with optional custom [_translations].
  const VLocale([this._translations = const {}]);

  static const _defaults = <String, String>{
    // General
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',

    // String
    'not_empty': 'Must not be empty',
    'string.too_small': 'Must be at least {min} characters',
    'string.too_big': 'Must be at most {max} characters',
    'string.length': 'Must be exactly {length} characters',
    'invalid_email': 'Invalid email address',
    'invalid_url': 'Invalid URL',
    'invalid_uuid': 'Invalid UUID',
    'invalid_ip': 'Invalid IP address',
    'invalid_format': 'Invalid format',
    'invalid_date': 'Invalid date',
    'invalid_time': 'Invalid time',
    'contains': 'Must contain "{substring}"',
    'starts_with': 'Must start with "{prefix}"',
    'ends_with': 'Must end with "{suffix}"',
    'equals': 'Must be equal to "{expected}"',
    'alpha': 'Must contain only letters',
    'alphanumeric': 'Must contain only letters and numbers',
    'slug': 'Must be a valid slug',
    'password':
        'Password must have at least 8 characters, including uppercase, lowercase, digit, and special character',
    'jwt': 'Invalid JWT',
    'card': 'Invalid credit card number',
    'invalid_phone': 'Invalid phone number',

    // Number
    'number.too_small': 'Must be at least {min}',
    'number.too_big': 'Must be at most {max}',
    'number.not_in_range': 'Must be between {min} and {max}',
    'positive': 'Must be positive',
    'negative': 'Must be negative',
    'multiple_of': 'Must be a multiple of {factor}',
    'even': 'Must be even',
    'odd': 'Must be odd',
    'prime': 'Must be prime',
    'finite': 'Must be finite',
    'decimal': 'Must be a decimal number',
    'integer': 'Must be an integer',

    // Bool
    'is_true': 'Must be true',
    'is_false': 'Must be false',

    // Date
    'date.too_small': 'Must be after {date}',
    'date.too_big': 'Must be before {date}',
    'date.not_in_range': 'Must be between {min} and {max}',
    'weekday': 'Must be a weekday',
    'weekend': 'Must be a weekend',

    // Array
    'array.too_small': 'Must have at least {min} items',
    'array.too_big': 'Must have at most {max} items',
    'unique': 'Must contain unique values',
    'contains_all': 'Must contain all required values',

    // Composite
    'invalid_enum': 'Invalid value. Expected one of: {values}',
    'invalid_literal': 'Expected "{expected}", received "{received}"',
    'invalid_union': 'Value does not match any of the union types',
    'unrecognized_key': 'Unrecognized key "{key}"',
    'fields_not_equal': '{field} must be equal to {other}',
    'custom': 'Invalid value',
  };

  /// Translates an error [code] with optional [params] interpolation.
  ///
  /// Lookup order: custom translations → default English → code itself.
  ///
  /// ```dart
  /// final locale = VLocale({'required': 'Obrigatório'});
  /// locale.translate('required'); // 'Obrigatório'
  /// ```
  String translate(String code, [Map<String, dynamic> params = const {}]) {
    final template = _translations[code] ?? _defaults[code] ?? code;

    return _interpolate(template, params);
  }

  static String _interpolate(String template, Map<String, dynamic> params) {
    String result = template;

    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }

    assert(
      !_placeholderPattern.hasMatch(result),
      'Unreplaced placeholder(s) in translation: "$result". '
      'Provide values for all {param} tokens in the template.',
    );

    return result;
  }

  static final RegExp _placeholderPattern =
      RegExp(r'\{[a-zA-Z_][a-zA-Z0-9_]*\}');
}
