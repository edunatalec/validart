import 'package:keeper/src/messages/number_message.dart';

class IntMessage extends NumberMessage<int> {
  final String odd;
  final String even;

  IntMessage({
    super.required,
    super.refine,
    super.min,
    super.max,
    super.multipleOf,
    super.between,
    super.positive,
    super.negative,
    String? odd,
    String? even,
  }) : odd = odd ?? 'The number must be odd',
       even = even ?? 'The number must be even';

  @override
  IntMessage copyWith({
    String? required,
    String? refine,
    String Function(int min)? min,
    String Function(int max)? max,
    String Function(int multipleOf)? multipleOf,
    String Function(int min, int max)? between,
    String? positive,
    String? negative,
    String? odd,
    String? even,
  }) {
    return IntMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      min: min ?? this.min,
      max: max ?? this.max,
      multipleOf: multipleOf ?? this.multipleOf,
      between: between ?? this.between,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      odd: odd ?? this.odd,
      even: even ?? this.even,
    );
  }
}
