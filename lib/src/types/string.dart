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
    final msg = message?.call(length) ?? _messages.min(length);
    _addValidator('too_small', (value) => value.length >= length ? null : msg);
    return this;
  }

  VString max(int length, {String Function(int)? message}) {
    final msg = message?.call(length) ?? _messages.max(length);
    _addValidator('too_big', (value) => value.length <= length ? null : msg);
    return this;
  }

  VString length(int len, {String Function(int)? message}) {
    final msg = message?.call(len) ?? _messages.length(len);
    _addValidator('length', (value) => value.length == len ? null : msg);
    return this;
  }

  VString email({String? message}) {
    final msg = message ?? _messages.email;
    final regex = RegExp(
      r"^(?!.*\.\.)[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$",
    );
    _addValidator(
      'invalid_email',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString url({String? message}) {
    final msg = message ?? _messages.url;
    final regex = RegExp(r'^https?://[^\s/$.?#].[^\s]*$');
    _addValidator(
      'invalid_url',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString uuid({String? message}) {
    final msg = message ?? _messages.uuid;
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    _addValidator(
      'invalid_uuid',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString ip({String? message}) {
    final msg = message ?? _messages.ip;
    final ipv4 = RegExp(
      r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    );
    final ipv6 = RegExp(
      r'^(([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]+|::(ffff(:0{1,4})?:)?((25[0-5]|(2[0-4]|1?\d)?\d)\.){3}(25[0-5]|(2[0-4]|1?\d)?\d)|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1?\d)?\d)\.){3}(25[0-5]|(2[0-4]|1?\d)?\d))$',
    );
    _addValidator(
      'invalid_ip',
      (value) => ipv4.hasMatch(value) || ipv6.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString pattern(String regex, {String? message}) {
    final msg = message ?? _messages.pattern;
    final regExp = RegExp(regex);
    _addValidator(
      'invalid_format',
      (value) => regExp.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString date({String? message}) {
    final msg = message ?? _messages.date;
    final regex = RegExp(r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$');
    _addValidator(
      'invalid_date',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString time({String? message}) {
    final msg = message ?? _messages.time;
    final regex = RegExp(r'^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$');
    _addValidator(
      'invalid_time',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString contains(String value, {String? message}) {
    final msg = message ?? _messages.contains(value);
    _addValidator('contains', (v) => v.contains(value) ? null : msg);
    return this;
  }

  VString startsWith(String prefix, {String? message}) {
    final msg = message ?? _messages.startsWith(prefix);
    _addValidator(
      'starts_with',
      (value) => value.startsWith(prefix) ? null : msg,
    );
    return this;
  }

  VString endsWith(String suffix, {String? message}) {
    final msg = message ?? _messages.endsWith(suffix);
    _addValidator(
      'ends_with',
      (value) => value.endsWith(suffix) ? null : msg,
    );
    return this;
  }

  VString equals(String value, {String? message}) {
    final msg = message ?? _messages.equals(value);
    _addValidator('equals', (v) => v == value ? null : msg);
    return this;
  }

  VString alpha({String? message}) {
    final msg = message ?? _messages.alpha;
    final regex = RegExp(r'^[a-zA-Z]+$');
    _addValidator('alpha', (value) => regex.hasMatch(value) ? null : msg);
    return this;
  }

  VString alphanumeric({String? message}) {
    final msg = message ?? _messages.alphanumeric;
    final regex = RegExp(r'^[a-zA-Z0-9]+$');
    _addValidator(
      'alphanumeric',
      (value) => regex.hasMatch(value) ? null : msg,
    );
    return this;
  }

  VString slug({String? message}) {
    final msg = message ?? _messages.slug;
    final regex = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
    _addValidator('slug', (value) => regex.hasMatch(value) ? null : msg);
    return this;
  }

  VString password({String? message}) {
    final msg = message ?? _messages.password;
    _addValidator('password', (value) {
      if (value.length < 8) return msg;
      if (!RegExp(r'[A-Z]').hasMatch(value)) return msg;
      if (!RegExp(r'[a-z]').hasMatch(value)) return msg;
      if (!RegExp(r'[0-9]').hasMatch(value)) return msg;
      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return msg;
      return null;
    });
    return this;
  }

  VString jwt({String? message}) {
    final msg = message ?? _messages.jwt;
    final regex = RegExp(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$');
    _addValidator('jwt', (value) => regex.hasMatch(value) ? null : msg);
    return this;
  }

  VString card({String? message}) {
    final msg = message ?? _messages.card;
    _addValidator('card', (value) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 13 || digits.length > 19) return msg;

      int sum = 0;
      bool alternate = false;

      for (int i = digits.length - 1; i >= 0; i--) {
        int n = int.parse(digits[i]);
        if (alternate) {
          n *= 2;
          if (n > 9) n -= 9;
        }
        sum += n;
        alternate = !alternate;
      }

      return sum % 10 == 0 ? null : msg;
    });
    return this;
  }

  VString phone({String? message}) {
    final msg = message ?? _messages.phone;
    final regex = RegExp(r'^\+?[1-9]\d{1,14}$');
    _addValidator(
      'invalid_phone',
      (value) => regex.hasMatch(value) ? null : msg,
    );
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
