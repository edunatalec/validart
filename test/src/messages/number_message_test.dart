import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = NumberMessage<int>();

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
    final message = NumberMessage<int>(
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
}
