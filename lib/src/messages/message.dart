import 'package:keeper/src/messages/bool_message.dart';
import 'package:keeper/src/messages/double_message.dart';
import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/messages/num_message.dart';
import 'package:keeper/src/messages/string_message.dart';

class Message {
  final BoolMessage boolMessage;
  final NumMessage numMessage;
  final DoubleMessage doubleMessage;
  final IntMessage intMessage;
  final StringMessage stringMessage;
  final MapMessage mapMessage;

  Message({
    required this.boolMessage,
    required this.numMessage,
    required this.doubleMessage,
    required this.intMessage,
    required this.stringMessage,
    required this.mapMessage,
  });

  Message copyWith({
    BoolMessage? boolMessage,
    NumMessage? numMessage,
    DoubleMessage? doubleMessage,
    IntMessage? intMessage,
    StringMessage? stringMessage,
    MapMessage? mapMessage,
  }) {
    return Message(
      boolMessage: boolMessage ?? this.boolMessage,
      numMessage: numMessage ?? this.numMessage,
      doubleMessage: doubleMessage ?? this.doubleMessage,
      intMessage: intMessage ?? this.intMessage,
      stringMessage: stringMessage ?? this.stringMessage,
      mapMessage: mapMessage ?? this.mapMessage,
    );
  }
}
