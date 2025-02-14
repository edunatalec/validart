import 'package:keeper/src/validators/validator.dart';

class DateValidator extends KValidator<String> {
  DateValidator({required super.message});

  @override
  String? validate(String? value) {
    if (value == null) return message;

    DateTime? date = _parseDate(value);
    if (date == null) return message;

    return null;
  }

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

  int _daysInMonth(int year, int month) {
    final daysInMonth = <int>[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    if (month == 2 && _isLeapYear(year)) return 29;

    return daysInMonth[month - 1];
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
}
