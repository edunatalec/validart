import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = IntMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.odd, equals('The number must be odd'));
    expect(message.even, equals('The number must be even'));
  });

  test('should use custom messages when provided', () {
    final message = IntMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
      odd: 'Custom odd',
      even: 'Custom even',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));
    expect(message.odd, equals('Custom odd'));
    expect(message.even, equals('Custom even'));
  });

  test('should create a copy with updated values', () {
    final message = IntMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      odd: 'Updated odd',
      even: 'Updated even',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));
    expect(updatedMessage.odd, equals('Updated odd'));
    expect(updatedMessage.even, equals('Updated even'));

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.odd, equals('The number must be odd'));
    expect(message.even, equals('The number must be even'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = IntMessage(odd: 'Odd number required');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.odd, equals('Odd number required'));
    expect(updatedMessage.even, equals('The number must be even'));

    final updatedIntMessage = message.copyWith(even: 'Must be an even number');

    expect(updatedIntMessage.required, equals('Required'));
    expect(updatedIntMessage.even, equals('Must be an even number'));
  });

  test('should create an IntMessage instance from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final intMessage = IntMessage().mergeWithBase(baseMessage);

    expect(intMessage.required, equals('Base required'));
    expect(intMessage.refine, equals('Base refine'));
    expect(intMessage.any, equals('Base any'));
    expect(intMessage.every, equals('Base every'));
    expect(intMessage.odd, equals('The number must be odd'));
    expect(intMessage.even, equals('The number must be even'));
  });

  test('should create a copy with updated values from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final intMessage = IntMessage().mergeWithBase(baseMessage);
    final updatedMessage = intMessage.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      odd: 'Updated odd',
      even: 'Updated even',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));
    expect(updatedMessage.odd, equals('Updated odd'));
    expect(updatedMessage.even, equals('Updated even'));

    expect(intMessage.required, equals('Base required'));
    expect(intMessage.refine, equals('Base refine'));
    expect(intMessage.any, equals('Base any'));
    expect(intMessage.every, equals('Base every'));
    expect(intMessage.odd, equals('The number must be odd'));
    expect(intMessage.even, equals('The number must be even'));
  });
}
