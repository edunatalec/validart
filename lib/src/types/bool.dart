part of 'type.dart';

class VBool extends VType<bool> {
  VBool isTrue({String? message}) {
    add(const IsTrueValidator(), message: message);
    return this;
  }

  VBool isFalse({String? message}) {
    add(const IsFalseValidator(), message: message);
    return this;
  }

  VArray<bool> array() => VArray<bool>(this);
}
