import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should create a default Message instance with default messages', () {
    final message = Message();

    expect(message.bool.required, 'Required');
    expect(message.num.required, 'Required');
    expect(message.double.required, 'Required');
    expect(message.int.required, 'Required');
    expect(message.string.required, 'Required');
    expect(message.map.required, 'Required');
  });

  test('should allow customization of individual message types', () {
    final customMessage = Message(
      string: StringMessage(required: 'Custom string required message'),
    );

    expect(customMessage.string.required, 'Custom string required message');
    expect(customMessage.bool.required, 'Required');
  });

  test('should inherit baseMessage values when provided', () {
    final baseMessage = BaseMessage(required: 'Base required message');
    final message = Message(base: baseMessage);

    expect(message.bool.required, 'Base required message');
    expect(message.num.required, 'Base required message');
    expect(message.double.required, 'Base required message');
    expect(message.int.required, 'Base required message');
    expect(message.string.required, 'Base required message');
    expect(message.map.required, 'Base required message');
  });

  test('copyWith should override specific fields', () {
    final message = Message();
    final updatedMessage = message.copyWith();

    expect(updatedMessage.bool.required, 'Required');
    expect(updatedMessage.num.required, 'Required');

    final updatedBoolMessage = message.copyWith(
      bool: BoolMessage(required: 'New required'),
    );

    expect(updatedBoolMessage.bool.required, 'New required');
  });
}
