import 'package:keeper/src/messages/base_message.dart';

class StringMessage extends BaseMessage {
  final String email;
  final String uuid;
  final String url;
  final String cpf;
  final String cnpj;
  final String cep;
  final String Function(int min) min;
  final String Function(int max) max;
  final String phone;
  final String time;
  final String ip;
  final String date;
  final String Function(String data) contains;
  final String Function(String data) equals;
  final String Function(String prefix) startsWith;
  final String Function(String sufix) endsWith;
  final String pattern;

  StringMessage({
    super.required,
    super.refine,
    String? email,
    String? uuid,
    String? url,
    String? cpf,
    String? cnpj,
    String? cep,
    String Function(int min)? min,
    String Function(int max)? max,
    String? phone,
    String? time,
    String? ip,
    String? date,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String prefix)? startsWith,
    String Function(String sufix)? endsWith,
    String? pattern,
  }) : email = email ?? 'Enter a valid email',
       uuid = uuid ?? 'Invalid UUID',
       url = url ?? 'Enter a valid URL',
       cpf = cpf ?? 'Invalid CPF',
       cnpj = cnpj ?? 'Invalid CNPJ',
       cep = cep ?? 'Invalid postal code',
       min = min ?? ((min) => 'At least $min characters required'),
       max = max ?? ((max) => 'No more than $max characters allowed'),
       phone = phone ?? 'Invalid phone number',
       time = time ?? 'Invalid time format',
       ip = ip ?? 'Invalid IP address',
       date = date ?? 'Invalid date',
       contains = contains ?? ((data) => 'Must contain "$data"'),
       equals = equals ?? ((data) => 'Must be exactly "$data"'),
       startsWith = startsWith ?? ((prefix) => 'Must start with "$prefix"'),
       endsWith = endsWith ?? ((sufix) => 'Must end with "$sufix"'),
       pattern = pattern ?? 'Invalid format';

  @override
  StringMessage copyWith({
    String? required,
    String? refine,
    String? email,
    String? uuid,
    String? url,
    String? cpf,
    String? cnpj,
    String? cep,
    String Function(int min)? min,
    String Function(int max)? max,
    String? phone,
    String? time,
    String? ip,
    String? date,
    String Function(String data)? contains,
    String Function(String data)? equals,
    String Function(String prefix)? startsWith,
    String Function(String sufix)? endsWith,
    String? pattern,
  }) {
    return StringMessage(
      required: required ?? this.required,
      refine: refine ?? this.refine,
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
      startsWith: startsWith ?? this.startsWith,
      endsWith: endsWith ?? this.endsWith,
      pattern: pattern ?? this.pattern,
    );
  }
}
