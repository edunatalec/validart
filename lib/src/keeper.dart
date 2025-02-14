import 'package:keeper/src/messages/int_message.dart';
import 'package:keeper/src/messages/map_message.dart';
import 'package:keeper/src/messages/message.dart';
import 'package:keeper/src/messages/string_message.dart';
import 'package:keeper/src/types/map.dart';
import 'package:keeper/src/types/string.dart';
import 'package:keeper/src/types/type.dart';

final _errorMessage = Message(
  intMessage: IntMessage(),
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
}
