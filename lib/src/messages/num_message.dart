// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:keeper/src/messages/base_message.dart';

class NumMessage<T extends num> extends BaseMessage {
  final String Function(T min) min;
  final String Function(T max) max;
  final String Function(T multipleOf) multipleOf;
  final String Function(T min, T max) between;
  final String positive;
  final String negative;

  NumMessage({
    required super.required,
    required super.refine,
    required this.min,
    required this.max,
    required this.multipleOf,
    required this.between,
    required this.positive,
    required this.negative,
  });

  @override
  NumMessage<T> copyWith({
    String? required,
    String? refine,
    String Function(T min)? min,
    String Function(T max)? max,
    String Function(T multipleOf)? multipleOf,
    String Function(T min, T max)? between,
    String? positive,
    String? negative,
  }) {
    return NumMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
      min: min ?? this.min,
      max: max ?? this.max,
      multipleOf: multipleOf ?? this.multipleOf,
      between: between ?? this.between,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }
}
