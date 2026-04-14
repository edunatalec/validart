part of 'type.dart';

class VString extends VType<String> {
  final VStringMessages _messages;

  VString({
    VStringMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VStringMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  VString min(int length, {String Function(int)? message}) {
    _add(MinLengthValidator(
      min: length,
      message: message?.call(length) ?? _messages.min(length),
    ));
    return this;
  }

  VString max(int length, {String Function(int)? message}) {
    _add(MaxLengthValidator(
      max: length,
      message: message?.call(length) ?? _messages.max(length),
    ));
    return this;
  }

  VString length(int len, {String Function(int)? message}) {
    _add(LengthValidator(
      length: len,
      message: message?.call(len) ?? _messages.length(len),
    ));
    return this;
  }

  VString email({String? message}) {
    _add(EmailValidator(message: message ?? _messages.email));
    return this;
  }

  VString url({String? message}) {
    _add(UrlValidator(message: message ?? _messages.url));
    return this;
  }

  VString uuid({String? message}) {
    _add(UuidValidator(message: message ?? _messages.uuid));
    return this;
  }

  VString ip({String? message}) {
    _add(IpValidator(message: message ?? _messages.ip));
    return this;
  }

  VString pattern(String regex, {String? message}) {
    _add(PatternValidator(
      pattern: regex,
      message: message ?? _messages.pattern,
    ));
    return this;
  }

  VString date({String? message}) {
    _add(DateStringValidator(message: message ?? _messages.date));
    return this;
  }

  VString time({String? message}) {
    _add(TimeValidator(message: message ?? _messages.time));
    return this;
  }

  VString contains(String value, {String? message}) {
    _add(ContainsValidator(
      substring: value,
      message: message ?? _messages.contains(value),
    ));
    return this;
  }

  VString startsWith(String prefix, {String? message}) {
    _add(StartsWithValidator(
      prefix: prefix,
      message: message ?? _messages.startsWith(prefix),
    ));
    return this;
  }

  VString endsWith(String suffix, {String? message}) {
    _add(EndsWithValidator(
      suffix: suffix,
      message: message ?? _messages.endsWith(suffix),
    ));
    return this;
  }

  VString equals(String value, {String? message}) {
    _add(EqualsValidator(
      expected: value,
      message: message ?? _messages.equals(value),
    ));
    return this;
  }

  VString alpha({String? message}) {
    _add(AlphaValidator(message: message ?? _messages.alpha));
    return this;
  }

  VString alphanumeric({String? message}) {
    _add(AlphanumericValidator(message: message ?? _messages.alphanumeric));
    return this;
  }

  VString slug({String? message}) {
    _add(SlugValidator(message: message ?? _messages.slug));
    return this;
  }

  VString password({String? message}) {
    _add(PasswordValidator(message: message ?? _messages.password));
    return this;
  }

  VString jwt({String? message}) {
    _add(JwtValidator(message: message ?? _messages.jwt));
    return this;
  }

  VString card({String? message}) {
    _add(CardValidator(message: message ?? _messages.card));
    return this;
  }

  VString phone({String? message}) {
    _add(PhoneValidator(message: message ?? _messages.phone));
    return this;
  }

  VString trim() {
    _transform((value) => value.trim());
    return this;
  }

  VString toLowerCase() {
    _transform((value) => value.toLowerCase());
    return this;
  }

  VString toUpperCase() {
    _transform((value) => value.toUpperCase());
    return this;
  }

  VArray<String> array() => VArray<String>(this);
}
