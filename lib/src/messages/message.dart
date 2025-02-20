import 'package:validart/src/messages/base_message.dart';
import 'package:validart/src/messages/bool_message.dart';
import 'package:validart/src/messages/date_message.dart';
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
/// ### Example
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

  /// Validation messages for date values.
  final DateMessage date;

  /// Validation messages for `double` values.
  final DoubleMessage double;

  /// Validation messages for `int` values.
  final IntMessage int;

  /// Validation messages for `Map<String, dynamic>` values.
  final MapMessage map;

  /// Validation messages for `num` values.
  final NumMessage num;

  /// Validation messages for `String` values.
  final StringMessage string;

  /// Creates a new instance of `Message`, allowing customization of validation messages.
  ///
  /// If no specific messages are provided, default messages will be used.
  ///
  /// ### Example
  /// ```dart
  /// final messages = Message(
  ///   base: BaseMessage(required: 'This field is required'),
  ///   string: StringMessage(required: 'You must provide a string'),
  /// );
  /// ```
  Message({
    BaseMessage? base,
    BoolMessage? bool,
    DateMessage? date,
    DoubleMessage? double,
    IntMessage? int,
    MapMessage? map,
    NumMessage? num,
    StringMessage? string,
  })  : bool = bool ?? BoolMessage().mergeWithBase(base ?? BaseMessage()),
        date = date ?? DateMessage().mergeWithBase(base ?? BaseMessage()),
        double = double ?? DoubleMessage().mergeWithBase(base ?? BaseMessage()),
        int = int ?? IntMessage().mergeWithBase(base ?? BaseMessage()),
        map = map ?? MapMessage().mergeWithBase(base ?? BaseMessage()),
        num = num ?? NumMessage().mergeWithBase(base ?? BaseMessage()),
        string = string ?? StringMessage().mergeWithBase(base ?? BaseMessage());

  /// Creates a copy of this `Message` instance with the ability to override specific fields.
  ///
  /// ### Example
  /// ```dart
  /// final updatedMessages = defaultMessages.copyWith(
  ///   string: StringMessage(required: 'Custom required message'),
  /// );
  /// ```
  Message copyWith({
    BoolMessage? bool,
    DateMessage? date,
    DoubleMessage? double,
    IntMessage? int,
    MapMessage? map,
    NumMessage? num,
    StringMessage? string,
  }) {
    return Message(
      bool: bool ?? this.bool,
      date: date ?? this.date,
      double: double ?? this.double,
      int: int ?? this.int,
      map: map ?? this.map,
      num: num ?? this.num,
      string: string ?? this.string,
    );
  }
}
