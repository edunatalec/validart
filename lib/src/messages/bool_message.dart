import 'package:keeper/src/messages/base_message.dart';

class BoolMessage extends BaseMessage {
  final String isTrue;
  final String isFalse;

  const BoolMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
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
    String? any,
    String? every,
  }) {
    return BoolMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
      isTrue: isTrue ?? this.isTrue,
      isFalse: isFalse ?? this.isFalse,
    );
  }
}
