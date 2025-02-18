import 'package:validart/src/messages/base_message.dart';

/// A message container for validation errors related to string values.
///
/// This class extends `BaseMessage` and provides validation messages
/// specific to string-based validations, such as emails, URLs, UUIDs, and more.
///
/// Example usage:
/// ```dart
/// final stringMessages = StringMessage(
///   min: (value) => 'At least $value characters required',
///   max: (value) => 'No more than $value characters allowed',
///   email: 'Enter a valid email',
///   uuid: 'Invalid UUID',
/// );
/// ```
class StringMessage extends BaseMessage {
  /// Message for email validation.
  final String email;

  /// Message for UUID validation.
  final String uuid;

  /// Message for URL validation.
  final String url;

  /// Message for CPF (Brazilian tax ID) validation.
  final String cpf;

  /// Message for CNPJ (Brazilian company tax ID) validation.
  final String cnpj;

  /// Message for postal code (CEP in Brazil) validation.
  final String cep;

  /// Message for the minimum string length validation.
  final String Function(int min) min;

  /// Message for the maximum string length validation.
  final String Function(int max) max;

  /// Message for phone number validation.
  final String phone;

  /// Message for time format validation.
  final String time;

  /// Message for IP address validation.
  final String ip;

  /// Message for date format validation.
  final String date;

  /// Message for the validation that ensures a string contains a specific substring.
  final String Function(String data) contains;

  /// Message for the validation that ensures a string matches an exact value.
  final String Function(String data) equals;

  /// Message for the validation that ensures a string starts with a specific prefix.
  final String Function(String prefix) startsWith;

  /// Message for the validation that ensures a string ends with a specific suffix.
  final String Function(String sufix) endsWith;

  /// Message for general pattern validation.
  final String pattern;

  /// Creates a new instance of `StringMessage` with customizable validation messages.
  ///
  /// If no custom messages are provided, default messages will be used.
  StringMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    String? email,
    String? uuid,
    String? url,
    String? cpf,
    String? cnpj,
    String? cep,
    String Function(int min)? min,
    String Function(int max)? max,
    String? phone,
    String? time,
    String? ip,
    String? date,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String prefix)? startsWith,
    String Function(String sufix)? endsWith,
    String? pattern,
  })  : email = email ?? 'Enter a valid email',
        uuid = uuid ?? 'Invalid UUID',
        url = url ?? 'Enter a valid URL',
        cpf = cpf ?? 'Invalid CPF',
        cnpj = cnpj ?? 'Invalid CNPJ',
        cep = cep ?? 'Invalid postal code',
        min = min ?? ((min) => 'At least $min characters required'),
        max = max ?? ((max) => 'No more than $max characters allowed'),
        phone = phone ?? 'Invalid phone number',
        time = time ?? 'Invalid time format',
        ip = ip ?? 'Invalid IP address',
        date = date ?? 'Invalid date',
        contains = contains ?? ((data) => 'Must contain "$data"'),
        equals = equals ?? ((data) => 'Must be exactly "$data"'),
        startsWith = startsWith ?? ((prefix) => 'Must start with "$prefix"'),
        endsWith = endsWith ?? ((sufix) => 'Must end with "$sufix"'),
        pattern = pattern ?? 'Invalid format';

  /// Merges the current `StringMessage` instance with a `BaseMessage`,
  /// replacing only the undefined values with those from the base.
  ///
  /// This allows inheriting common validation messages while keeping
  /// specific string-related messages intact.
  ///
  /// Example:
  /// ```dart
  /// final baseMessage = BaseMessage(required: 'This field is mandatory');
  /// final stringMessage = StringMessage().mergeWithBase(baseMessage);
  ///
  /// print(stringMessage.required); // Output: 'This field is mandatory'
  /// print(stringMessage.email);    // Output: 'Enter a valid email' (unchanged)
  /// ```
  StringMessage mergeWithBase(BaseMessage base) {
    return copyWith(
      required: base.required,
      refine: base.refine,
      any: base.any,
      every: base.every,
    );
  }

  /// Creates a copy of the current `StringMessage` instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// Example:
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
    String? required,
    String? refine,
    String? any,
    String? every,
    String? email,
    String? uuid,
    String? url,
    String? cpf,
    String? cnpj,
    String? cep,
    String Function(int min)? min,
    String Function(int max)? max,
    String? phone,
    String? time,
    String? ip,
    String? date,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String prefix)? startsWith,
    String Function(String sufix)? endsWith,
    String? pattern,
  }) {
    return StringMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
      email: email ?? this.email,
      uuid: uuid ?? this.uuid,
      url: url ?? this.url,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      cep: cep ?? this.cep,
      min: min ?? this.min,
      max: max ?? this.max,
      phone: phone ?? this.phone,
      time: time ?? this.time,
      ip: ip ?? this.ip,
      date: date ?? this.date,
      contains: contains ?? this.contains,
      equals: equals ?? this.equals,
      startsWith: startsWith ?? this.startsWith,
      endsWith: endsWith ?? this.endsWith,
      pattern: pattern ?? this.pattern,
    );
  }
}
