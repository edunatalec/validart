import 'package:keeper/src/messages/bool_message.dart';
import 'package:keeper/src/messages/double_message.dart';
import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/messages/num_message.dart';
import 'package:keeper/src/messages/string_message.dart';

class Message {
  final BoolMessage bool;
  final NumMessage num;
  final DoubleMessage double;
  final IntMessage int;
  final StringMessage string;
  final MapMessage map;

  Message({
    BoolMessage? bool,
    NumMessage? num,
    DoubleMessage? double,
    IntMessage? int,
    StringMessage? string,
    MapMessage? map,
  }) : bool = bool ?? BoolMessage(),
       num = num ?? NumMessage(),
       double = double ?? DoubleMessage(),
       int = int ?? IntMessage(),
       string = string ?? StringMessage(),
       map = map ?? MapMessage();

  Message copyWith({
    BoolMessage? bool,
    NumMessage? num,
    DoubleMessage? double,
    IntMessage? int,
    StringMessage? string,
    MapMessage? map,
  }) {
    return Message(
      bool: bool ?? this.bool,
      num: num ?? this.num,
      double: double ?? this.double,
      int: int ?? this.int,
      string: string ?? this.string,
      map: map ?? this.map,
    );
  }
}
