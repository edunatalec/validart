import 'package:keeper/src/messages/base_message.dart';

class BoolMessage extends BaseMessage {
  final String isTrue;
  final String isFalse;

  const BoolMessage({
    super.required,
    super.refine,
    String? isTrue,
    String? isFalse,
  }) : isTrue = 'The value must be true',
       isFalse = 'The value must be false';

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
