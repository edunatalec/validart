import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/messages/string_message.dart';

class Message {
  final IntMessage intMessage;
  final StringMessage stringMessage;
  final MapMessage mapMessage;

  Message({
    required this.intMessage,
    required this.stringMessage,
    required this.mapMessage,
  });

  Message copyWith({
    IntMessage? intMessage,
    StringMessage? stringMessage,
    MapMessage? mapMessage,
  }) {
    return Message(
      intMessage: intMessage ?? this.intMessage,
      stringMessage: stringMessage ?? this.stringMessage,
      mapMessage: mapMessage ?? this.mapMessage,
    );
  }
}
