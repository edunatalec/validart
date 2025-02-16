import 'package:validart/src/messages/bool_message.dart';
import 'package:validart/src/messages/double_message.dart';
import 'package:validart/src/messages/int_message.dart';
import 'package:validart/src/messages/map_message.dart';
import 'package:validart/src/messages/num_message.dart';
import 'package:validart/src/messages/string_message.dart';

/// A container for all validation messages used within Validart.
///
/// This class holds instances of different validation message types,
/// allowing customization of validation error messages for various data types.
///
/// Example usage:
/// ```dart
/// final customMessages = Message(
///   string: StringMessage(required: 'This field cannot be empty'),
///   int: IntMessage(min: (value) => 'Minimum value allowed is $value'),
/// );
/// final validart = Validart(message: customMessages);
/// ```
class Message {
  /// Validation messages for boolean values.
  final BoolMessage bool;

  /// Validation messages for `num` values.
  final NumMessage num;

  /// Validation messages for `double` values.
  final DoubleMessage double;

  /// Validation messages for `int` values.
  final IntMessage int;

  /// Validation messages for `String` values.
  final StringMessage string;

  /// Validation messages for `Map<String, dynamic>` values.
  final MapMessage map;

  /// Creates a new instance of `Message`, allowing customization of validation messages.
  ///
  /// If no specific messages are provided, default messages will be used.
  Message({
    BoolMessage? bool,
    NumMessage? num,
    DoubleMessage? double,
    IntMessage? int,
    StringMessage? string,
    MapMessage? map,
  }) : bool = bool ?? const BoolMessage(),
       num = num ?? NumMessage(),
       double = double ?? DoubleMessage(),
       int = int ?? IntMessage(),
       string = string ?? StringMessage(),
       map = map ?? const MapMessage();

  /// Creates a copy of this `Message` instance with the ability to override specific fields.
  ///
  /// Example usage:
  /// ```dart
  /// final updatedMessages = defaultMessages.copyWith(
  ///   string: StringMessage(required: 'Custom required message'),
  /// );
  /// ```
  Message copyWith({
    BoolMessage? bool,
    NumMessage? num,
    DoubleMessage? double,
    IntMessage? int,
    StringMessage? string,
    MapMessage? map,
  }) {
    return Message(
      bool: bool ?? this.bool,
      num: num ?? this.num,
      double: double ?? this.double,
      int: int ?? this.int,
      string: string ?? this.string,
      map: map ?? this.map,
    );
  }
}
