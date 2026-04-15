part of 'type.dart';

class VString extends VType<String> {
  VString notEmpty({String? message}) {
    add(const NotEmptyValidator(), message: message);
    return this;
  }

  VString min(int length, {String Function(int)? message}) {
    add(MinLengthValidator(min: length), message: message?.call(length));
    return this;
  }

  VString max(int length, {String Function(int)? message}) {
    add(MaxLengthValidator(max: length), message: message?.call(length));
    return this;
  }

  VString length(int len, {String Function(int)? message}) {
    add(LengthValidator(length: len), message: message?.call(len));
    return this;
  }

  VString email({String? message}) {
    add(const EmailValidator(), message: message);
    return this;
  }

  VString url({String? message}) {
    add(const UrlValidator(), message: message);
    return this;
  }

  VString uuid({String? message}) {
    add(const UuidValidator(), message: message);
    return this;
  }

  VString ip({String? message}) {
    add(const IpValidator(), message: message);
    return this;
  }

  VString pattern(String regex, {String? message}) {
    add(PatternValidator(pattern: regex), message: message);
    return this;
  }

  VString date({String? message}) {
    add(const DateStringValidator(), message: message);
    return this;
  }

  VString time({String? message}) {
    add(const TimeValidator(), message: message);
    return this;
  }

  VString contains(String value, {String? message}) {
    add(ContainsValidator(substring: value), message: message);
    return this;
  }

  VString startsWith(String prefix, {String? message}) {
    add(StartsWithValidator(prefix: prefix), message: message);
    return this;
  }

  VString endsWith(String suffix, {String? message}) {
    add(EndsWithValidator(suffix: suffix), message: message);
    return this;
  }

  VString equals(String value, {String? message}) {
    add(EqualsValidator(expected: value), message: message);
    return this;
  }

  VString alpha({String? message}) {
    add(const AlphaValidator(), message: message);
    return this;
  }

  VString alphanumeric({String? message}) {
    add(const AlphanumericValidator(), message: message);
    return this;
  }

  VString slug({String? message}) {
    add(const SlugValidator(), message: message);
    return this;
  }

  VString password({String? message}) {
    add(const PasswordValidator(), message: message);
    return this;
  }

  VString jwt({String? message}) {
    add(const JwtValidator(), message: message);
    return this;
  }

  VString card({String? message}) {
    add(const CardValidator(), message: message);
    return this;
  }

  VString phone({String? message}) {
    add(const PhoneValidator(), message: message);
    return this;
  }

  /// Removes leading and trailing whitespace from the value.
  ///
  /// Runs in the pre-processing phase, before any validation.
  VString trim() {
    _preTransform((value) => value.trim());
    return this;
  }

  /// Converts the value to lowercase.
  ///
  /// Runs in the pre-processing phase, before any validation.
  VString toLowerCase() {
    _preTransform((value) => value.toLowerCase());
    return this;
  }

  /// Converts the value to uppercase.
  ///
  /// Runs in the pre-processing phase, before any validation.
  VString toUpperCase() {
    _preTransform((value) => value.toUpperCase());
    return this;
  }

  VArray<String> array() => VArray<String>(this);
}
