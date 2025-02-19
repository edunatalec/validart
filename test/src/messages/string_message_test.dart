import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = StringMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));

    expect(message.email, equals('Enter a valid email'));
    expect(message.uuid, equals('Invalid UUID'));
    expect(message.url, equals('Enter a valid URL'));
    expect(message.cpf, equals('Invalid CPF'));
    expect(message.cnpj, equals('Invalid CNPJ'));
    expect(message.cep, equals('Invalid postal code'));

    expect(message.min(5), equals('At least 5 characters required'));
    expect(message.max(10), equals('No more than 10 characters allowed'));

    expect(message.phone, equals('Invalid phone number'));
    expect(message.time, equals('Invalid time format'));
    expect(message.ip, equals('Invalid IP address'));
    expect(message.date, equals('Invalid date format'));

    expect(message.contains('test'), equals('Must contain "test"'));
    expect(message.equals('test'), equals('Must be exactly "test"'));
    expect(message.startsWith('pre'), equals('Must start with "pre"'));
    expect(message.endsWith('suf'), equals('Must end with "suf"'));
    expect(message.pattern, equals('Invalid format'));
  });

  test('should use custom messages when provided', () {
    final message = StringMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
      email: 'Custom email message',
      uuid: 'Custom UUID message',
      url: 'Custom URL message',
      cpf: 'Custom CPF message',
      cnpj: 'Custom CNPJ message',
      cep: 'Custom postal code message',
      min: (value) => 'Min length: $value',
      max: (value) => 'Max length: $value',
      phone: 'Custom phone message',
      time: 'Custom time message',
      ip: 'Custom IP message',
      date: 'Custom date message',
      contains: (data) => 'Contains "$data"',
      equals: (data) => 'Equals "$data"',
      startsWith: (prefix) => 'Starts with "$prefix"',
      endsWith: (suffix) => 'Ends with "$suffix"',
      pattern: 'Custom pattern message',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));

    expect(message.email, equals('Custom email message'));
    expect(message.uuid, equals('Custom UUID message'));
    expect(message.url, equals('Custom URL message'));
    expect(message.cpf, equals('Custom CPF message'));
    expect(message.cnpj, equals('Custom CNPJ message'));
    expect(message.cep, equals('Custom postal code message'));

    expect(message.min(5), equals('Min length: 5'));
    expect(message.max(10), equals('Max length: 10'));

    expect(message.phone, equals('Custom phone message'));
    expect(message.time, equals('Custom time message'));
    expect(message.ip, equals('Custom IP message'));
    expect(message.date, equals('Custom date message'));

    expect(message.contains('test'), equals('Contains "test"'));
    expect(message.equals('test'), equals('Equals "test"'));
    expect(message.startsWith('pre'), equals('Starts with "pre"'));
    expect(message.endsWith('suf'), equals('Ends with "suf"'));
    expect(message.pattern, equals('Custom pattern message'));
  });

  test('should create a copy with updated values', () {
    final message = StringMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      email: 'Updated email message',
      uuid: 'Updated UUID message',
      url: 'Updated URL message',
      cpf: 'Updated CPF message',
      cnpj: 'Updated CNPJ message',
      cep: 'Updated postal code message',
      min: (value) => 'Min updated to $value',
      max: (value) => 'Max updated to $value',
      phone: 'Updated phone message',
      time: 'Updated time message',
      ip: 'Updated IP message',
      date: 'Updated date message',
      contains: (data) => 'Updated contains "$data"',
      equals: (data) => 'Updated equals "$data"',
      startsWith: (prefix) => 'Updated starts with "$prefix"',
      endsWith: (suffix) => 'Updated ends with "$suffix"',
      pattern: 'Updated pattern message',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(updatedMessage.email, equals('Updated email message'));
    expect(updatedMessage.uuid, equals('Updated UUID message'));
    expect(updatedMessage.url, equals('Updated URL message'));
    expect(updatedMessage.cpf, equals('Updated CPF message'));
    expect(updatedMessage.cnpj, equals('Updated CNPJ message'));
    expect(updatedMessage.cep, equals('Updated postal code message'));

    expect(updatedMessage.min(5), equals('Min updated to 5'));
    expect(updatedMessage.max(10), equals('Max updated to 10'));

    expect(updatedMessage.phone, equals('Updated phone message'));
    expect(updatedMessage.time, equals('Updated time message'));
    expect(updatedMessage.ip, equals('Updated IP message'));
    expect(updatedMessage.date, equals('Updated date message'));

    expect(updatedMessage.contains('test'), equals('Updated contains "test"'));
    expect(updatedMessage.equals('test'), equals('Updated equals "test"'));
    expect(
      updatedMessage.startsWith('pre'),
      equals('Updated starts with "pre"'),
    );
    expect(updatedMessage.endsWith('suf'), equals('Updated ends with "suf"'));
    expect(updatedMessage.pattern, equals('Updated pattern message'));

    expect(message.required, equals('Required'));
    expect(message.email, equals('Enter a valid email'));
    expect(message.min(5), equals('At least 5 characters required'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = StringMessage(email: 'Must be a valid email');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.email, equals('Must be a valid email'));
    expect(updatedMessage.phone, equals('Invalid phone number'));

    final updatedStringMessage = message.copyWith(
      phone: 'Must be a valid phone',
    );

    expect(updatedStringMessage.required, equals('Required'));
    expect(updatedStringMessage.phone, equals('Must be a valid phone'));
    expect(
      updatedStringMessage.min(5),
      equals('At least 5 characters required'),
    );
  });

  test('should create a StringMessage instance from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final stringMessage = StringMessage().mergeWithBase(baseMessage);

    expect(stringMessage.required, equals('Base required'));
    expect(stringMessage.refine, equals('Base refine'));
    expect(stringMessage.any, equals('Base any'));
    expect(stringMessage.every, equals('Base every'));
  });

  test('should create a copy with updated values from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final stringMessage = StringMessage().mergeWithBase(baseMessage);
    final updatedMessage = stringMessage.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(stringMessage.required, equals('Base required'));
    expect(stringMessage.refine, equals('Base refine'));
    expect(stringMessage.any, equals('Base any'));
    expect(stringMessage.every, equals('Base every'));
  });
}
