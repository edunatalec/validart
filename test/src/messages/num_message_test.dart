import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = NumMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));

    expect(message.positive, equals('The number must be positive'));
    expect(message.negative, equals('The number must be negative'));

    expect(message.min(5), equals('The number must be at least 5'));
    expect(message.max(10), equals('The number must be at most 10'));
    expect(
      message.between(5, 10),
      equals('The number must be between 5 and 10'),
    );
    expect(message.multipleOf(2), equals('The number must be a multiple of 2'));
  });

  test('should use custom messages when provided', () {
    final message = NumMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
      positive: 'Custom positive message',
      negative: 'Custom negative message',
      min: (value) => 'Min must be $value',
      max: (value) => 'Max must be $value',
      between: (min, max) => 'Between $min and $max',
      multipleOf: (value) => 'Must be multiple of $value',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));

    expect(message.positive, equals('Custom positive message'));
    expect(message.negative, equals('Custom negative message'));

    expect(message.min(5), equals('Min must be 5'));
    expect(message.max(10), equals('Max must be 10'));
    expect(message.between(5, 10), equals('Between 5 and 10'));
    expect(message.multipleOf(2), equals('Must be multiple of 2'));
  });

  test('should create a copy with updated values', () {
    final message = NumMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      positive: 'Updated positive',
      negative: 'Updated negative',
      min: (value) => 'Min updated to $value',
      max: (value) => 'Max updated to $value',
      between: (min, max) => 'Updated between $min and $max',
      multipleOf: (value) => 'Updated multiple of $value',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(updatedMessage.positive, equals('Updated positive'));
    expect(updatedMessage.negative, equals('Updated negative'));

    expect(updatedMessage.min(5), equals('Min updated to 5'));
    expect(updatedMessage.max(10), equals('Max updated to 10'));
    expect(updatedMessage.between(5, 10), equals('Updated between 5 and 10'));
    expect(updatedMessage.multipleOf(2), equals('Updated multiple of 2'));

    expect(message.required, equals('Required'));
    expect(message.positive, equals('The number must be positive'));
    expect(message.min(5), equals('The number must be at least 5'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = NumMessage(positive: 'Must be positive');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.positive, equals('Must be positive'));
    expect(updatedMessage.negative, equals('The number must be negative'));

    final updatedNumMessage = message.copyWith(negative: 'Must be negative');

    expect(updatedNumMessage.required, equals('Required'));
    expect(updatedNumMessage.negative, equals('Must be negative'));
    expect(updatedNumMessage.min(5), equals('The number must be at least 5'));
  });

  test('should create a NumMessage instance from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final numMessage = NumMessage().mergeWithBase(baseMessage);

    expect(numMessage.required, equals('Base required'));
    expect(numMessage.refine, equals('Base refine'));
    expect(numMessage.any, equals('Base any'));
    expect(numMessage.every, equals('Base every'));
  });

  test('should create a copy with updated values from BaseMessage', () {
    final baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final numMessage = NumMessage().mergeWithBase(baseMessage);
    final updatedMessage = numMessage.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));

    expect(numMessage.required, equals('Base required'));
    expect(numMessage.refine, equals('Base refine'));
    expect(numMessage.any, equals('Base any'));
    expect(numMessage.every, equals('Base every'));
  });
}
