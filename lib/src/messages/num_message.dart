import 'package:keeper/src/messages/number_message.dart';

class NumMessage extends NumberMessage<num> {
  NumMessage({
    super.required,
    super.refine,
    super.min,
    super.max,
    super.multipleOf,
    super.between,
    super.positive,
    super.negative,
  });
}
