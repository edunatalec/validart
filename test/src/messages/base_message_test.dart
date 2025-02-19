import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    const message = BaseMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
  });

  test('should use custom messages when provided', () {
    const message = BaseMessage(
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
    const message = BaseMessage();
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
    const message = BaseMessage(required: 'Mandatory field');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.required, equals('Mandatory field'));
    expect(updatedMessage.refine, equals('Invalid value'));

    final updatedBaseMessage = message.copyWith(refine: 'New refine message');

    expect(updatedBaseMessage.any, equals('Invalid value'));
    expect(updatedBaseMessage.refine, equals('New refine message'));
  });
}
