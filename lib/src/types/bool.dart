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
    final msg = message ?? _messages.isTrue;
    _addValidator('is_true', (value) => value == true ? null : msg);
    return this;
  }

  VBool isFalse({String? message}) {
    final msg = message ?? _messages.isFalse;
    _addValidator('is_false', (value) => value == false ? null : msg);
    return this;
  }

  VArray<bool> array() => VArray<bool>(this);
}
