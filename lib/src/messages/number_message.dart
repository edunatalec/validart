import 'package:keeper/src/messages/base_message.dart';

class NumberMessage<T extends num> extends BaseMessage {
  final String Function(T min) min;
  final String Function(T max) max;
  final String Function(T multipleOf) multipleOf;
  final String Function(T min, T max) between;
  final String positive;
  final String negative;

  NumberMessage({
    required super.required,
    required super.refine,
    required this.min,
    required this.max,
    required this.multipleOf,
    required this.between,
    required this.positive,
    required this.negative,
  });
}
