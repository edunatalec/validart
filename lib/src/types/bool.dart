part of 'type.dart';

class VBool extends VType<bool> {
  final VBoolMessages _messages;

  VBool({
    VBoolMessages? messages,
    String? requiredMessage,
    String Function(String, String)? invalidTypeMessage,
  }) : _messages = messages ?? const VBoolMessages() {
    if (requiredMessage != null) _requiredMessage = requiredMessage;
    if (invalidTypeMessage != null) _invalidTypeMessage = invalidTypeMessage;
  }

  VBool isTrue({String? message}) {
    _add(IsTrueValidator(message: message ?? _messages.isTrue));
    return this;
  }

  VBool isFalse({String? message}) {
    _add(IsFalseValidator(message: message ?? _messages.isFalse));
    return this;
  }

  VArray<bool> array() => VArray<bool>(this);
}
