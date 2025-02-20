import 'package:validart/src/messages/array_message.dart';
import 'package:validart/src/messages/base_message.dart';

/// A message container for validation errors related to string values.
///
/// This class extends `BaseMessage` and provides validation messages
/// specific to string-based validations, such as emails, URLs, UUIDs, and more.
///
/// ### Example
/// ```dart
/// final stringMessages = StringMessage(
///   min: (value) => 'At least $value characters required',
///   max: (value) => 'No more than $value characters allowed',
///   email: 'Enter a valid email',
///   uuid: 'Invalid UUID',
/// );
/// ```
class StringMessage extends BaseMessage {
  /// Message for alphabetic character validation (letters only).
  final String alpha;

  /// Message for alphanumeric character validation (letters and numbers only).
  final String alphanumeric;

  /// Message for credit card validation.
  final String card;

  /// Message for postal code (CEP in Brazil) validation.
  final String cep;

  /// Message for CNPJ (Brazilian company tax ID) validation.
  final String cnpj;

  /// Message for CPF (Brazilian tax ID) validation.
  final String cpf;

  /// Message for date format validation.
  final String date;

  /// Message for double validation.
  final String double;

  /// Message for email validation.
  final String email;

  /// Message for the validation that ensures a string contains a specific substring.
  final String Function(String data) contains;

  /// Message for the validation that ensures a string matches an exact value.
  final String Function(String data) equals;

  /// Message for the validation that ensures a string ends with a specific suffix.
  final String Function(String suffix) endsWith;

  /// Message for IP address validation.
  final String ip;

  /// Message for integer validation.
  final String integer;

  /// Message for JWT validation.
  final String jwt;

  /// Message for the maximum string length validation.
  final String Function(int max) max;

  /// Message for the minimum string length validation.
  final String Function(int min) min;

  /// Message for password validation.
  final String password;

  /// Message for general pattern validation.
  final String pattern;

  /// Message for phone number validation.
  final String phone;

  /// Message for slug validation.
  final String slug;

  /// Message for the validation that ensures a string starts with a specific prefix.
  final String Function(String prefix) startsWith;

  /// Message for time format validation.
  final String time;

  /// Message for URL validation.
  final String url;

  /// Message for UUID validation.
  final String uuid;

  /// Creates a new instance of `StringMessage` with customizable validation messages.
  ///
  /// If no custom messages are provided, default messages will be used.
  StringMessage({
    super.any,
    super.array,
    super.every,
    super.refine,
    super.required,
    String? alpha,
    String? alphanumeric,
    String? card,
    String? cep,
    String? cnpj,
    String? cpf,
    String? date,
    String? double,
    String? email,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String suffix)? endsWith,
    String? ip,
    String? integer,
    String? jwt,
    String Function(int max)? max,
    String Function(int min)? min,
    String? password,
    String? pattern,
    String? phone,
    String? slug,
    String Function(String prefix)? startsWith,
    String? time,
    String? url,
    String? uuid,
  })  : alpha = alpha ?? 'Only letters are allowed',
        alphanumeric = alphanumeric ?? 'Only letters and numbers are allowed',
        card = card ?? 'Invalid card number',
        cep = cep ?? 'Invalid postal code',
        cnpj = cnpj ?? 'Invalid CNPJ',
        cpf = cpf ?? 'Invalid CPF',
        date = date ?? 'Invalid date format',
        double = double ?? 'Invalid double value',
        email = email ?? 'Enter a valid email',
        contains = contains ?? ((data) => 'Must contain "$data"'),
        equals = equals ?? ((data) => 'Must be exactly "$data"'),
        endsWith = endsWith ?? ((suffix) => 'Must end with "$suffix"'),
        ip = ip ?? 'Invalid IP address',
        integer = integer ?? 'Invalid integer value',
        jwt = jwt ?? 'Invalid JWT token',
        max = max ?? ((max) => 'No more than $max characters allowed'),
        min = min ?? ((min) => 'At least $min characters required'),
        password =
            password ?? 'The password does not meet security requirements',
        pattern = pattern ?? 'Invalid format',
        phone = phone ?? 'Invalid phone number',
        slug = slug ?? 'Invalid slug format',
        startsWith = startsWith ?? ((prefix) => 'Must start with "$prefix"'),
        time = time ?? 'Invalid time format',
        url = url ?? 'Enter a valid URL',
        uuid = uuid ?? 'Invalid UUID';

  /// Merges the current `StringMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// This allows inheriting common validation messages while keeping
  /// specific string-related messages intact.
  ///
  /// ### Example
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final stringMessage = StringMessage().mergeWithBase(baseMessage);
  ///
  /// print(stringMessage.required); // Output: 'This field is mandatory'
  /// print(stringMessage.email);    // Output: 'Enter a valid email' (unchanged)
  /// ```
  StringMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      any: base.any,
      array: base.array,
      every: base.every,
      refine: base.refine,
      required: base.required,
    );
  }

  /// Creates a copy of the current `StringMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// ### Example
  /// ```dart
  /// final defaultMessage = StringMessage();
  /// final customMessage = defaultMessage.copyWith(
  ///   email: 'Please enter a valid email address',
  ///   min: (value) => 'At least $value characters required',
  /// );
  ///
  /// print(customMessage.email); // Output: 'Please enter a valid email address'
  /// print(customMessage.min(5)); // Output: 'At least 5 characters required'
  /// print(customMessage.required); // Output: 'Required' (unchanged)
  /// ```
  @override
  StringMessage copyWith({
    String? alpha,
    String? alphanumeric,
    ArrayMessage? array,
    String? any,
    String? card,
    String? cep,
    String? cnpj,
    String Function(String data)? contains,
    String? cpf,
    String? date,
    String? double,
    String? email,
    String Function(String data)? equals,
    String Function(String suffix)? endsWith,
    String? every,
    String? ip,
    String? integer,
    String? jwt,
    String Function(int max)? max,
    String Function(int min)? min,
    String? password,
    String? pattern,
    String? phone,
    String? refine,
    String? required,
    String? slug,
    String Function(String prefix)? startsWith,
    String? time,
    String? url,
    String? uuid,
  }) {
    return StringMessage(
      alpha: alpha ?? this.alpha,
      alphanumeric: alphanumeric ?? this.alphanumeric,
      array: array ?? this.array,
      any: any ?? this.any,
      card: card ?? this.card,
      cep: cep ?? this.cep,
      cnpj: cnpj ?? this.cnpj,
      contains: contains ?? this.contains,
      cpf: cpf ?? this.cpf,
      date: date ?? this.date,
      double: double ?? this.double,
      email: email ?? this.email,
      equals: equals ?? this.equals,
      endsWith: endsWith ?? this.endsWith,
      every: every ?? this.every,
      ip: ip ?? this.ip,
      integer: integer ?? this.integer,
      jwt: jwt ?? this.jwt,
      max: max ?? this.max,
      min: min ?? this.min,
      password: password ?? this.password,
      pattern: pattern ?? this.pattern,
      phone: phone ?? this.phone,
      refine: refine ?? this.refine,
      required: required ?? this.required,
      slug: slug ?? this.slug,
      startsWith: startsWith ?? this.startsWith,
      time: time ?? this.time,
      url: url ?? this.url,
      uuid: uuid ?? this.uuid,
    );
  }
}
