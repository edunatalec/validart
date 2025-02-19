import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = DoubleMessage();

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.finite, equals('The number must be finite'));
    expect(
      message.decimal,
      equals('The number must be a decimal (not an integer)'),
    );
    expect(message.integer, equals('The number must be an integer'));
  });

  test('should use custom messages when provided', () {
    final message = DoubleMessage(
      required: 'Custom required',
      refine: 'Custom refine',
      any: 'Custom any',
      every: 'Custom every',
      finite: 'Custom finite',
      decimal: 'Custom decimal',
      integer: 'Custom integer',
    );

    expect(message.required, equals('Custom required'));
    expect(message.refine, equals('Custom refine'));
    expect(message.any, equals('Custom any'));
    expect(message.every, equals('Custom every'));
    expect(message.finite, equals('Custom finite'));
    expect(message.decimal, equals('Custom decimal'));
    expect(message.integer, equals('Custom integer'));
  });

  test('should create a copy with updated values', () {
    final message = DoubleMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      finite: 'Updated finite',
      decimal: 'Updated decimal',
      integer: 'Updated integer',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));
    expect(updatedMessage.finite, equals('Updated finite'));
    expect(updatedMessage.decimal, equals('Updated decimal'));
    expect(updatedMessage.integer, equals('Updated integer'));

    expect(message.required, equals('Required'));
    expect(message.refine, equals('Invalid value'));
    expect(message.any, equals('Invalid value'));
    expect(message.every, equals('Invalid value'));
    expect(message.finite, equals('The number must be finite'));
    expect(
      message.decimal,
      equals('The number must be a decimal (not an integer)'),
    );
    expect(message.integer, equals('The number must be an integer'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = DoubleMessage(finite: 'Finite number required');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.finite, equals('Finite number required'));
    expect(
      updatedMessage.decimal,
      equals('The number must be a decimal (not an integer)'),
    );

    final updatedDoubleMessage =
        message.copyWith(decimal: 'Must be a decimal number');

    expect(updatedDoubleMessage.required, equals('Required'));
    expect(
      updatedDoubleMessage.integer,
      equals('The number must be an integer'),
    );
    expect(updatedDoubleMessage.decimal, equals('Must be a decimal number'));
  });

  test('should create a DoubleMessage instance from BaseMessage', () {
    const baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final doubleMessage = DoubleMessage().mergeWithBase(baseMessage);

    expect(doubleMessage.required, equals('Base required'));
    expect(doubleMessage.refine, equals('Base refine'));
    expect(doubleMessage.any, equals('Base any'));
    expect(doubleMessage.every, equals('Base every'));
    expect(doubleMessage.finite, equals('The number must be finite'));
    expect(
      doubleMessage.decimal,
      equals('The number must be a decimal (not an integer)'),
    );
    expect(doubleMessage.integer, equals('The number must be an integer'));
  });

  test('should create a copy with updated values from BaseMessage', () {
    const baseMessage = BaseMessage(
      required: 'Base required',
      refine: 'Base refine',
      any: 'Base any',
      every: 'Base every',
    );

    final doubleMessage = DoubleMessage().mergeWithBase(baseMessage);
    final updatedMessage = doubleMessage.copyWith(
      required: 'Updated required',
      refine: 'Updated refine',
      any: 'Updated any',
      every: 'Updated every',
      finite: 'Updated finite',
      decimal: 'Updated decimal',
      integer: 'Updated integer',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.refine, equals('Updated refine'));
    expect(updatedMessage.any, equals('Updated any'));
    expect(updatedMessage.every, equals('Updated every'));
    expect(updatedMessage.finite, equals('Updated finite'));
    expect(updatedMessage.decimal, equals('Updated decimal'));
    expect(updatedMessage.integer, equals('Updated integer'));

    expect(doubleMessage.required, equals('Base required'));
    expect(doubleMessage.refine, equals('Base refine'));
    expect(doubleMessage.any, equals('Base any'));
    expect(doubleMessage.every, equals('Base every'));
    expect(doubleMessage.finite, equals('The number must be finite'));
    expect(
      doubleMessage.decimal,
      equals('The number must be a decimal (not an integer)'),
    );
    expect(doubleMessage.integer, equals('The number must be an integer'));
  });
}
