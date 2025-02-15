import 'package:keeper/src/messages/bool_message.dart';
import 'package:keeper/src/messages/double_message.dart';
import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/messages/message.dart';
import 'package:keeper/src/messages/num_message.dart';
import 'package:keeper/src/messages/string_message.dart';
import 'package:keeper/src/types/bool.dart';
import 'package:keeper/src/types/double.dart';
import 'package:keeper/src/types/int.dart';
import 'package:keeper/src/types/map.dart';
import 'package:keeper/src/types/num.dart';
import 'package:keeper/src/types/string.dart';
import 'package:keeper/src/types/type.dart';

final _errorMessage = Message(
  boolMessage: BoolMessage(
    required: 'Required',
    refine: 'Invalid value',
    isTrue: 'The value must be true',
    isFalse: 'The value must be false',
  ),
  doubleMessage: DoubleMessage(
    required: 'Required',
    refine: 'Invalid value',
    min: (min) => 'The number must be at least $min',
    max: (max) => 'The number must be at most $max',
    multipleOf: (multiple) => 'The number must be a multiple of $multiple',
    between: (lower, upper) => 'The number must be between $lower and $upper',
    positive: 'The number must be positive',
    negative: 'The number must be negative',
    finite: 'The number must be finite',
    decimal: 'The number must be a decimal (not an integer)',
    integer: 'The number must be an integer',
  ),
  intMessage: IntMessage(
    required: 'Required',
    refine: 'Invalid value',
    min: (min) => 'The number must be at least $min',
    max: (max) => 'The number must be at most $max',
    multipleOf: (multiple) => 'The number must be a multiple of $multiple',
    between: (lower, upper) => 'The number must be between $lower and $upper',
    positive: 'The number must be positive',
    negative: 'The number must be negative',
    odd: 'The number must be odd',
    even: 'The number must be even',
  ),
  numMessage: NumMessage(
    required: 'Required',
    refine: 'Invalid value',
    min: (min) => 'The number must be at least $min',
    max: (max) => 'The number must be at most $max',
    multipleOf: (multiple) => 'The number must be a multiple of $multiple',
    between: (lower, upper) => 'The number must be between $lower and $upper',
    positive: 'The number must be positive',
    negative: 'The number must be negative',
  ),
  mapMessage: MapMessage(
    required: 'Required',
    refine: 'Does not meet validation rules',
  ),
  stringMessage: StringMessage(
    required: 'Required',
    email: 'Enter a valid email',
    uuid: 'Invalid UUID',
    url: 'Enter a valid URL',
    cpf: 'Invalid CPF',
    cnpj: 'Invalid CNPJ',
    cep: 'Invalid postal code',
    min: (min) => 'At least $min characters required',
    max: (max) => 'No more than $max characters allowed',
    phone: 'Invalid phone number',
    time: 'Invalid time format',
    ip: 'Invalid IP address',
    date: 'Invalid date',
    contains: (data) => 'Must contain "$data"',
    equals: (data) => 'Must be exactly "$data"',
    startsWidth: (prefix) => 'Must start with "$prefix"',
    endsWith: (sufix) => 'Must end with "$sufix"',
    pattern: 'Invalid format',
    refine: 'Does not meet validation rules',
  ),
);

class Keeper {
  final Message _message;

  Keeper({Message? message}) : _message = message ?? _errorMessage;

  KMap map(Map<String, KType> object, {String? message}) {
    return KMap(object, _message.mapMessage, message: message);
  }

  KString string({String? message}) {
    return KString(_message.stringMessage, message: message);
  }

  KBool bool({String? message}) {
    return KBool(_message.boolMessage, message: message);
  }

  KInt int({String? message}) {
    return KInt(_message.intMessage, message: message);
  }

  KDouble double({String? message}) {
    return KDouble(_message.doubleMessage, message: message);
  }

  KNum num({String? message}) {
    return KNum(_message.numMessage, message: message);
  }
}
