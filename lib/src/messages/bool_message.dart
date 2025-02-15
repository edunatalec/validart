import 'package:keeper/src/messages/base_message.dart';

class BoolMessage extends BaseMessage {
  final String isTrue;
  final String isFalse;

  BoolMessage({
    required super.required,
    required super.refine,
    required this.isTrue,
    required this.isFalse,
  });

  @override
  BoolMessage copyWith({
    String? required,
    String? refine,
    String? isTrue,
    String? isFalse,
  }) {
    return BoolMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      isTrue: isTrue ?? this.isTrue,
      isFalse: isFalse ?? this.isFalse,
    );
  }
}
