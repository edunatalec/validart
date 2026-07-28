/// Provides locale-aware error message translations.
///
/// Uses `{param}` interpolation for dynamic values. Error codes can be
/// given in **flat** form (`'string.required'`), **nested** form
/// (`{'string': {'required': '...'}}`), or a mix of both.
///
/// When a prefixed code such as `string.required` is looked up and no
/// match is found, the lookup falls back to the trailing segment
/// (`required`) — so an override on the generic `required` key still
/// affects every type unless you also define a type-specific message.
///
/// Lookup order:
/// 1. Custom translations, exact match (flat or nested).
/// 2. Custom translations, fallback to the last segment (drops the
///    prefix).
/// 3. Default English messages, exact match.
/// 4. Default English messages, fallback to the last segment.
/// 5. The code itself.
///
/// ```dart
/// V.setLocale(const VLocale({
///   // Generic override — affects every type.
///   'required': 'Campo obrigatório',
///
///   // Nested override — only strings.
///   'string': {
///     'required': 'Campo de texto obrigatório',
///   },
///
///   // Flat override — same as above but written inline.
///   'int.required': 'Número obrigatório',
/// }));
/// ```
class VLocale {
  /// Creates a [VLocale] with optional custom [_translations]. Values may
  /// be either a `String` (for a direct message) or a nested `Map` whose
  /// keys form the remainder of the error code path.
  const VLocale([this._translations = const {}]);

  final Map<String, Object> _translations;

  static const _defaults = <String, Object>{
    // Generic fallbacks — used when a prefixed key (e.g. `string.required`)
    // has no match in the nested groups below. The resolver drops the
    // prefix and retries here before giving up.
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',
    'custom': 'Invalid value',

    'string': <String, String>{
      'not_empty': 'Must not be empty',
      'too_small': 'Must be at least {min} characters',
      'too_big': 'Must be at most {max} characters',
      'length': 'Must be exactly {length} characters',
      'integer': 'Must be a valid integer',
      'numeric': 'Must be a valid number',
      'email': 'Invalid email address',
      'url': 'Invalid URL',
      'domain': 'Invalid domain',
      'uuid': 'Invalid UUID',
      'ip': 'Invalid IP address',
      'format': 'Invalid format',
      'date': 'Invalid date',
      'time': 'Invalid time',
      'phone': 'Invalid phone number',
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
      'base64': 'Invalid Base64',
      'hex_color': 'Invalid hex color',
      'mac': 'Invalid MAC address',
      'semver': 'Invalid Semantic Version',
      'mongo_id': 'Invalid MongoDB ObjectId',
      'ulid': 'Invalid ULID',
      'nano_id': 'Invalid NanoID',
      'iban': 'Invalid IBAN',
      'json': 'Invalid JSON',
      'cvv': 'Invalid CVV',
      'postal_code': 'Invalid {name}',
      'tax_id': 'Invalid {name}',
      'license_plate': 'Invalid {name}',
    },

    'number': <String, String>{
      'too_small': 'Must be at least {min}',
      'too_big': 'Must be at most {max}',
      'not_in_range': 'Must be between {min} and {max}',
      'positive': 'Must be positive',
      'negative': 'Must be negative',
      'multiple_of': 'Must be a multiple of {factor}',
      'finite': 'Must be finite',
    },

    'int': <String, String>{
      'even': 'Must be even',
      'odd': 'Must be odd',
      'prime': 'Must be prime',
    },

    'double': <String, String>{
      'decimal': 'Must be a decimal number',
      'integer': 'Must be an integer',
    },

    'bool': <String, String>{
      'is_true': 'Must be true',
      'is_false': 'Must be false',
    },

    'date': <String, String>{
      'too_small': 'Must be after {date}',
      'too_big': 'Must be before {date}',
      'not_in_range': 'Must be between {min} and {max}',
      'weekday': 'Must be a weekday',
      'weekend': 'Must be a weekend',
      'age': 'Age is out of the allowed range',
      'is_today': 'Must be today',
      'same_day': 'Must be the same day as {date}',
      'after_today': 'Must be after today',
      'before_today': 'Must be before today',
    },

    'array': <String, String>{
      'too_small': 'Must have at least {min} items',
      'too_big': 'Must have at most {max} items',
      'unique': 'Must contain unique values',
      'contains_all': 'Must contain all required values',
    },

    'map': <String, String>{
      'unrecognized_key': 'Unrecognized key "{key}"',
      'fields_not_equal': '{field} must be equal to {other}',
    },

    'object': <String, String>{
      'unrecognized_key': 'Unrecognized key "{key}"',
      'fields_not_equal': '{field} must be equal to {other}',
    },

    'enum': <String, String>{
      'invalid': 'Invalid value. Expected one of: {values}',
    },

    'literal': <String, String>{
      'invalid': 'Expected "{expected}", received "{received}"',
    },

    'union': <String, String>{
      'invalid': 'Value does not match any of the union types',
    },
  };

  /// Translates an error [code] with optional [params] interpolation.
  ///
  /// ```dart
  /// const locale = VLocale({'required': 'Obrigatório'});
  /// locale.translate('string.required'); // 'Obrigatório' (fallback)
  /// ```
  String translate(String code, [Map<String, dynamic> params = const {}]) {
    final template =
        _resolve(_translations, code) ?? _resolve(_defaults, code) ?? code;

    return _interpolate(template, params);
  }

  /// Resolves [code] against [source] following the documented fallback
  /// chain: exact match (flat or nested), then the trailing segment
  /// after dropping the prefix.
  static String? _resolve(Map<String, Object> source, String code) {
    final direct = _lookup(source, code);

    if (direct != null) return direct;

    final dot = code.indexOf('.');

    if (dot < 0) return null;

    return _lookup(source, code.substring(dot + 1));
  }

  /// Looks up [code] in [source] accepting either the flat form
  /// (`'string.required'`) or the nested form
  /// (`{'string': {'required': '...'}}`).
  static String? _lookup(Map<String, Object> source, String code) {
    final flat = source[code];

    if (flat is String) return flat;

    final parts = code.split('.');

    if (parts.length < 2) return null;

    Object? current = source;

    for (final part in parts) {
      if (current is! Map) return null;

      current = current[part];

      if (current == null) return null;
    }

    return current is String ? current : null;
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
