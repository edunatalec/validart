import 'package:keeper/src/messages/message.dart';
import 'package:keeper/src/types/bool.dart';
import 'package:keeper/src/types/double.dart';
import 'package:keeper/src/types/int.dart';
import 'package:keeper/src/types/map.dart';
import 'package:keeper/src/types/num.dart';
import 'package:keeper/src/types/string.dart';
import 'package:keeper/src/types/type.dart';

class Keeper {
  final Message _message;

  Keeper({Message? message}) : _message = message ?? Message();

  KMap map(Map<String, KType> object, {String? message}) {
    return KMap(object, _message.map, message: message);
  }

  KString string({String? message}) {
    return KString(_message.string, message: message);
  }

  KBool bool({String? message}) {
    return KBool(_message.bool, message: message);
  }

  KInt int({String? message}) {
    return KInt(_message.int, message: message);
  }

  KDouble double({String? message}) {
    return KDouble(_message.double, message: message);
  }

  KNum num({String? message}) {
    return KNum(_message.num, message: message);
  }
}
