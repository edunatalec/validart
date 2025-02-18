import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = MapMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
  });

  test('should use custom messages when provided', () {
    final message = MapMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));
  });

  test('should create a copy with updated values', () {
    final message = MapMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = MapMessage(required: 'Map is required');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.required, equals('Map is required'));
    expect(updatedMessage.refine, equals('Invalid value'));

    final updatedMapMessage = message.copyWith(refine: 'Invalid map format');

    expect(updatedMapMessage.any, equals('Invalid value'));
    expect(updatedMapMessage.refine, equals('Invalid map format'));
  });

  test('should create a MapMessage instance from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final mapMessage = MapMessage().mergeWithBase(baseMessage);

    expect(mapMessage.required, equals('Base required'));
    expect(mapMessage.refine, equals('Base refine'));
    expect(mapMessage.any, equals('Base any'));
    expect(mapMessage.every, equals('Base every'));
  });

  test('should create a copy with updated values from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final mapMessage = MapMessage().mergeWithBase(baseMessage);
    final updatedMessage = mapMessage.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(mapMessage.required, equals('Base required'));
    expect(mapMessage.refine, equals('Base refine'));
    expect(mapMessage.any, equals('Base any'));
    expect(mapMessage.every, equals('Base every'));
  });
}
