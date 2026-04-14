class VLocale {
  final Map<String, String> _translations;

  const VLocale([this._translations = const {}]);

  static const _defaults = <String, String>{
    // General
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',

    // String
    'not_empty': 'Must not be empty',
    'too_small': 'Must be at least {min} characters',
    'too_big': 'Must be at most {max} characters',
    'length': 'Must be exactly {length} characters',
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
    'positive': 'Must be positive',
    'negative': 'Must be negative',
    'not_in_range': 'Must be between {min} and {max}',
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
    'weekday': 'Must be a weekday',
    'weekend': 'Must be a weekend',

    // Array
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

  String translate(String code, [Map<String, dynamic> params = const {}]) {
    final template = _translations[code] ?? _defaults[code] ?? code;

    return _interpolate(template, params);
  }

  static String _interpolate(String template, Map<String, dynamic> params) {
    String result = template;

    for (final entry in params.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value.toString());
    }

    return result;
  }
}
