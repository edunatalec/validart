import 'package:keeper/src/messages/base_message.dart';

class MapMessage extends BaseMessage {
  MapMessage({required super.required, required super.refine});

  @override
  MapMessage copyWith({String? required, String? refine}) {
    return MapMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
    );
  }
}
