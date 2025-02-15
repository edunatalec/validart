import 'package:keeper/src/messages/base_message.dart';

class NumberMessage<T extends num> extends BaseMessage {
  final String Function(T min) min;
  final String Function(T max) max;
  final String Function(T multipleOf) multipleOf;
  final String Function(T min, T max) between;
  final String positive;
  final String negative;

  NumberMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    String Function(T min)? min,
    String Function(T max)? max,
    String Function(T multipleOf)? multipleOf,
    String Function(T min, T max)? between,
    String? positive,
    String? negative,
  }) : min = min ?? ((min) => 'The number must be at least $min'),
       max = max ?? ((max) => 'The number must be at most $max'),
       multipleOf =
           multipleOf ??
           ((multiple) => 'The number must be a multiple of $multiple'),
       between =
           between ??
           ((min, max) => 'The number must be between $min and $max'),
       positive = positive ?? 'The number must be positive',
       negative = negative ?? 'The number must be negative';

  @override
  NumberMessage<T> copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
    String Function(T min)? min,
    String Function(T max)? max,
    String Function(T multipleOf)? multipleOf,
    String Function(T min, T max)? between,
    String? positive,
    String? negative,
  }) {
    return NumberMessage<T>(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      any: any ?? this.any,
      every: every ?? this.every,
      min: min ?? this.min,
      max: max ?? this.max,
      multipleOf: multipleOf ?? this.multipleOf,
      between: between ?? this.between,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }
}
