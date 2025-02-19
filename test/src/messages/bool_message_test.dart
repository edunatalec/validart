import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    const message = BoolMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.isTrue, equals('The value must be true'));
    expect(message.isFalse, equals('The value must be false'));
  });

  test('should use custom messages when provided', () {
    const message = BoolMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
      isTrue: 'Must be checked',
      isFalse: 'Must not be checked',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));
    expect(message.isTrue, equals('Must be checked'));
    expect(message.isFalse, equals('Must not be checked'));
  });

  test('should create a copy with updated values', () {
    const message = BoolMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      isTrue: 'Updated true',
      isFalse: 'Updated false',
      any: 'Updated any',
      every: 'Updated every',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));
    expect(updatedMessage.isTrue, equals('Updated true'));
    expect(updatedMessage.isFalse, equals('Updated false'));

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.isTrue, equals('The value must be true'));
    expect(message.isFalse, equals('The value must be false'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    const message = BoolMessage(isTrue: 'Must be checked');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.isTrue, equals('Must be checked'));
    expect(updatedMessage.isFalse, equals('The value must be false'));

    final updatedBoolMessage = message.copyWith(isFalse: 'Must not be checked');

    expect(updatedBoolMessage.required, equals('Required'));
    expect(updatedBoolMessage.isFalse, equals('Must not be checked'));
  });

  test('should create BoolMessage from BaseMessage', () {
    const baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final message = const BoolMessage().mergeWithBase(baseMessage);

    expect(message.required, equals('Base required'));
    expect(message.refine, equals('Base refine'));
    expect(message.any, equals('Base any'));
    expect(message.every, equals('Base every'));
    expect(message.isTrue, equals('The value must be true'));
    expect(message.isFalse, equals('The value must be false'));
  });

  test('should override BaseMessage values when provided in BoolMessage', () {
    const baseMessage = BaseMessage(required: 'Base required');

    final message = const BoolMessage()
        .mergeWithBase(baseMessage)
        .copyWith(required: 'Overridden required', isTrue: 'Custom true');

    expect(message.required, equals('Overridden required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.isTrue, equals('Custom true'));
    expect(message.isFalse, equals('The value must be false'));
  });
}
