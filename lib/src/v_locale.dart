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
  final Map<String, Object> _translations;

  /// Creates a [VLocale] with optional custom [_translations]. Values may
  /// be either a `String` (for a direct message) or a nested `Map` whose
  /// keys form the remainder of the error code path.
  const VLocale([this._translations = const {}]);

  static const _defaults = <String, String>{
    // General — used as fallback for every type-specific `required` /
    // `invalid_type` lookup.
    'required': 'Required',
    'invalid_type': 'Expected {expected}, received {received}',

    // String
    'not_empty': 'Must not be empty',
    'string.too_small': 'Must be at least {min} characters',
    'string.too_big': 'Must be at most {max} characters',
    'string.length': 'Must be exactly {length} characters',
    'string.integer': 'Must be a valid integer',
    'string.numeric': 'Must be a valid number',
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
