import 'package:test/test.dart';
import 'package:validart/validart.dart';

void main() {
  test('should use default messages when no parameters are provided', () {
    final message = DateMessage();

    expect(message.after, equals('The date must be after the specified date'));
    expect(
      message.before,
      equals('The date must be before the specified date'),
    );
    expect(
      message.betweenDates(DateTime(2025, 1, 1), DateTime(2025, 12, 31)),
      equals(
        'The date must be between 2025-01-01T00:00:00.000 and 2025-12-31T00:00:00.000',
      ),
    );
    expect(message.weekday, equals('The date must be a weekday'));
    expect(message.weekend, equals('The date must be a weekend'));
  });

  test('should use custom messages when provided', () {
    final message = DateMessage(
      after: 'Custom after',
      before: 'Custom before',
      betweenDates: (min, max) => 'Between ${min.year} and ${max.year}',
      weekday: 'Custom weekday',
      weekend: 'Custom weekend',
    );

    expect(message.after, equals('Custom after'));
    expect(message.before, equals('Custom before'));
    expect(
      message.betweenDates(DateTime(2020, 1, 1), DateTime(2030, 1, 1)),
      equals('Between 2020 and 2030'),
    );
    expect(message.weekday, equals('Custom weekday'));
    expect(message.weekend, equals('Custom weekend'));
  });

  test('should create a copy with updated values', () {
    final message = DateMessage();
    final updatedMessage = message.copyWith(
      after: 'Updated after',
      before: 'Updated before',
      betweenDates: (min, max) => 'Between ${min.year} and ${max.year}',
      weekday: 'Updated weekday',
      weekend: 'Updated weekend',
    );

    expect(updatedMessage.after, equals('Updated after'));
    expect(updatedMessage.before, equals('Updated before'));
    expect(
      updatedMessage.betweenDates(DateTime(2025, 1, 1), DateTime(2025, 12, 31)),
      equals('Between 2025 and 2025'),
    );
    expect(updatedMessage.weekday, equals('Updated weekday'));
    expect(updatedMessage.weekend, equals('Updated weekend'));

    expect(message.after, equals('The date must be after the specified date'));
    expect(
      message.before,
      equals('The date must be before the specified date'),
    );
    expect(
      message.betweenDates(DateTime(2025, 1, 1), DateTime(2025, 12, 31)),
      equals(
        'The date must be between 2025-01-01T00:00:00.000 and 2025-12-31T00:00:00.000',
      ),
    );
    expect(message.weekday, equals('The date must be a weekday'));
    expect(message.weekend, equals('The date must be a weekend'));
  });

  test('should create a copy while keeping previous values if not updated', () {
    final message = DateMessage(after: 'Original after');
    final updatedMessage = message.copyWith();

    expect(updatedMessage.after, equals('Original after'));
    expect(
      updatedMessage.before,
      equals('The date must be before the specified date'),
    );

    final updatedBaseMessage = message.copyWith(before: 'New before message');

    expect(updatedBaseMessage.before, equals('New before message'));
    expect(updatedBaseMessage.after, equals('Original after'));
  });
}
