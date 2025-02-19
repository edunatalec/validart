import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = ArrayMessage();

    expect(message.required, equals('The array cannot be empty'));
    expect(message.unique, equals('The array must contain unique values'));
    expect(message.contains, equals('The array must contain required values'));
  });

  test('should use custom messages when provided', () {
    final message = ArrayMessage(
      required: 'Array is required',
      unique: 'Array values must be unique',
      contains: 'Array must contain required values',
    );

    expect(message.required, equals('Array is required'));
    expect(message.unique, equals('Array values must be unique'));
    expect(message.contains, equals('Array must contain required values'));
  });

  test('should create a copy with updated values', () {
    final message = ArrayMessage();
    final updatedMessage = message.copyWith(
      required: 'Updated required',
      unique: 'Updated unique',
      contains: 'Updated contains',
    );

    expect(updatedMessage.required, equals('Updated required'));
    expect(updatedMessage.unique, equals('Updated unique'));
    expect(updatedMessage.contains, equals('Updated contains'));

    expect(message.required, equals('The array cannot be empty'));
    expect(message.unique, equals('The array must contain unique values'));
    expect(message.contains, equals('The array must contain required values'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = ArrayMessage(required: 'Array must not be empty');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.required, equals('Array must not be empty'));
    expect(
      updatedMessage.unique,
      equals('The array must contain unique values'),
    );

    final updatedBaseMessage = message.copyWith(unique: 'Must be unique');

    expect(updatedBaseMessage.required, equals('Array must not be empty'));
    expect(updatedBaseMessage.unique, equals('Must be unique'));
  });
}
