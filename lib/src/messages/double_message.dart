import 'package:keeper/src/messages/number_message.dart';

class DoubleMessage extends NumberMessage<double> {
  final String finite;
  final String decimal;
  final String integer;

  DoubleMessage({
    super.required,
    super.refine,
    super.any,
    super.every,
    super.min,
    super.max,
    super.multipleOf,
    super.between,
    super.positive,
    super.negative,
    String? finite,
    String? decimal,
    String? integer,
  }) : finite = finite ?? 'The number must be finite',
       decimal = decimal ?? 'The number must be a decimal (not an integer)',
       integer = integer ?? 'The number must be an integer';

  @override
  DoubleMessage copyWith({
    String? required,
    String? refine,
    String? any,
    String? every,
    String Function(double min)? min,
    String Function(double max)? max,
    String Function(double multipleOf)? multipleOf,
    String Function(double min, double max)? between,
    String? positive,
    String? negative,
    String? finite,
    String? decimal,
    String? integer,
  }) {
    return DoubleMessage(
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
      finite: finite ?? this.finite,
      decimal: decimal ?? this.decimal,
      integer: integer ?? this.integer,
    );
  }
}
