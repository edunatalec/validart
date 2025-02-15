import 'package:keeper/src/messages/num_message.dart';

class DoubleMessage extends NumMessage<double> {
  final String finite;
  final String decimal;
  final String integer;

  DoubleMessage({
    required super.required,
    required super.refine,
    required super.min,
    required super.max,
    required super.multipleOf,
    required super.between,
    required super.positive,
    required super.negative,
    required this.finite,
    required this.decimal,
    required this.integer,
  });

  @override
  DoubleMessage copyWith({
    String? required,
    String? refine,
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
