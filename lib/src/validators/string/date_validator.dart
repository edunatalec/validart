import 'package:keeper/src/validators/validator.dart';

/// A validator that checks whether a given string represents a valid date.
///
/// The `DateValidator` ensures that the provided value is a valid date
/// in one of the supported formats. It verifies that the date exists
/// and follows the correct day/month/year rules, including leap years.
///
/// ## Supported date formats:
/// - `yyyy-MM-dd` (e.g., `2025-02-16`)
/// - `yyyy-dd-MM` (e.g., `2025-16-02`)
/// - `dd/MM/yyyy` (e.g., `16/02/2025`)
/// - `MM/dd/yyyy` (e.g., `02/16/2025`)
///
/// ## Example usage:
/// ```dart
/// final validator = DateValidator(message: 'Invalid date');
///
/// print(validator.validate('2025-02-16'));  // null (valid)
/// print(validator.validate('16/02/2025'));  // null (valid)
/// print(validator.validate('2025-16-02'));  // null (valid)
/// print(validator.validate('02/30/2025'));  // 'Invalid date' (invalid)
/// print(validator.validate('invalid-date')); // 'Invalid date' (invalid)
/// ```
class DateValidator extends KValidator<String> {
  /// Creates a `DateValidator` instance with a custom error [message].
  DateValidator({required super.message});

  /// Validates whether the given [value] is a correctly formatted date.
  ///
  /// - If [value] is `null`, the validation fails.
  /// - Tries to parse the date using different formats.
  /// - If parsing fails or the date is invalid, returns the error message.
  ///
  /// Returns `null` if the date is valid, otherwise returns the error message.
  @override
  String? validate(String? value) {
    if (value == null) return message;

    DateTime? date = _parseDate(value);
    if (date == null) return message;

    return null;
  }

  /// Tries to parse a date string using multiple formats.
  ///
  /// The function iterates over a list of common date formats and
  /// attempts to convert the input into a valid `DateTime` object.
  ///
  /// Returns `DateTime` if parsing is successful, otherwise `null`.
  DateTime? _parseDate(String input) {
    final List<String> formats = [
      'yyyy-MM-dd',
      'yyyy-dd-MM',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ];

    for (var format in formats) {
      try {
        final date = _tryParseDate(input, format);
        if (date != null) return date;
      } catch (_) {}
    }

    return null;
  }

  /// Attempts to parse a date based on a given format.
  ///
  /// Splits the date string using `-` or `/` as separators and assigns
  /// the correct values for year, month, and day based on the format.
  ///
  /// Returns a `DateTime` if the date is valid, otherwise `null`.
  DateTime? _tryParseDate(String input, String format) {
    final parts = input.split(RegExp(r'[-/]'));

    if (parts.length != 3) return null;

    int year, month, day;

    switch (format) {
      case 'yyyy-MM-dd':
        year = int.parse(parts[0]);
        month = int.parse(parts[1]);
        day = int.parse(parts[2]);
        break;
      case 'yyyy-dd-MM':
        year = int.parse(parts[0]);
        month = int.parse(parts[2]);
        day = int.parse(parts[1]);
        break;
      case 'dd/MM/yyyy':
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        year = int.parse(parts[2]);
        break;
      case 'MM/dd/yyyy':
        month = int.parse(parts[0]);
        day = int.parse(parts[1]);
        year = int.parse(parts[2]);
        break;
      default:
        return null;
    }

    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    if (day > _daysInMonth(year, month)) return null;

    return DateTime(year, month, day);
  }

  /// Returns the number of days in a given month, considering leap years.
  int _daysInMonth(int year, int month) {
    final daysInMonth = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2 && _isLeapYear(year)) return 29;

    return daysInMonth[month - 1];
  }

  /// Determines whether a given year is a leap year.
  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
