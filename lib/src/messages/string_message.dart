import 'package:keeper/src/messages/base_message.dart';

class StringMessage extends BaseMessage {
  final String email;
  final String uuid;
  final String url;
  final String cpf;
  final String cnpj;
  final String cep;
  final String Function(int max) min;
  final String Function(int min) max;
  final String phone;
  final String time;
  final String ip;
  final String date;
  final String Function(String data) contains;
  final String Function(String data) equals;
  final String Function(String prefix) startsWidth;
  final String Function(String sufix) endsWith;
  final String pattern;

  StringMessage({
    required super.required,
    required super.refine,
    required this.email,
    required this.uuid,
    required this.url,
    required this.cpf,
    required this.cnpj,
    required this.cep,
    required this.min,
    required this.max,
    required this.phone,
    required this.time,
    required this.ip,
    required this.date,
    required this.contains,
    required this.equals,
    required this.startsWidth,
    required this.endsWith,
    required this.pattern,
  });

  @override
  StringMessage copyWith({
    String? required,
    String? email,
    String? uuid,
    String? url,
    String? cpf,
    String? cnpj,
    String? cep,
    String Function(int max)? min,
    String Function(int min)? max,
    String? phone,
    String? time,
    String? ip,
    String? date,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String prefix)? startsWidth,
    String Function(String sufix)? endsWith,
    String? pattern,
    String? refine,
  }) {
    return StringMessage(
      required: required ?? this.required,
      email: email ?? this.email,
      uuid: uuid ?? this.uuid,
      url: url ?? this.url,
      cpf: cpf ?? this.cpf,
      cnpj: cnpj ?? this.cnpj,
      cep: cep ?? this.cep,
      min: min ?? this.min,
      max: max ?? this.max,
      phone: phone ?? this.phone,
      time: time ?? this.time,
      ip: ip ?? this.ip,
      date: date ?? this.date,
      contains: contains ?? this.contains,
      equals: equals ?? this.equals,
      startsWidth: startsWidth ?? this.startsWidth,
      endsWith: endsWith ?? this.endsWith,
      pattern: pattern ?? this.pattern,
      refine: refine ?? this.refine,
    );
  }
}
