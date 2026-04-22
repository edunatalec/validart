import 'package:validart/src/v_code.dart';
import 'package:validart/src/validators/validator.dart';

/// Validates that a string is a real calendar date.
///
/// When [format] is provided, the string must match that format exactly.
/// Supported tokens: `YYYY` (4-digit year), `MM` (2-digit month), `DD`
/// (2-digit day). Any other character in [format] is treated as a literal
/// separator (e.g. `/`, `-`, `.`).
///
/// When [format] is omitted, the validator accepts any of the known
/// default formats (ISO, BR/EU, US). The string passes if at least one
/// format parses it as a calendar-valid date. Invalid dates such as
/// `2024-02-30`, `30/02/2024` or `2024-13-01` are rejected.
class DateStringValidator extends Validator<String> {
  /// Optional strict format. When `null`, any format from
  /// [_defaultFormats] is accepted.
  final String? format;

  /// Creates a [DateStringValidator].
  const DateStringValidator({this.format});

  @override
  String get code => VStringCode.date;

  @override
  Map<String, dynamic>? validate(String value) {
    final strict = format;

    if (strict != null) {
      return _matches(value, strict) ? null : {};
    }

    for (final candidate in _defaultFormats) {
      if (_matches(value, candidate)) return null;
    }

    return {};
  }

  static const List<String> _defaultFormats = [
    'YYYY-MM-DD',
    'YYYY/MM/DD',
    'YYYYMMDD',
    'DD/MM/YYYY',
    'MM/DD/YYYY',
    'DD-MM-YYYY',
    'MM-DD-YYYY',
    'DD.MM.YYYY',
  ];

  bool _matches(String value, String format) {
    if (!format.contains('YYYY') ||
        !format.contains('MM') ||
        !format.contains('DD')) {
      return false;
    }

    final regex = _formatToRegex(format);
    final match = regex.firstMatch(value);

    if (match == null) return false;

    final yearStr = match.namedGroup('year');
    final monthStr = match.namedGroup('month');
    final dayStr = match.namedGroup('day');

    if (yearStr == null || monthStr == null || dayStr == null) return false;

    final year = int.parse(yearStr);
    final month = int.parse(monthStr);
    final day = int.parse(dayStr);

    final date = DateTime(year, month, day);

    return date.year == year && date.month == month && date.day == day;
  }

  static RegExp _formatToRegex(String format) {
    final buffer = StringBuffer('^');
    int i = 0;

    while (i < format.length) {
      if (format.startsWith('YYYY', i)) {
        buffer.write(r'(?<year>\d{4})');
        i += 4;
      } else if (format.startsWith('MM', i)) {
        buffer.write(r'(?<month>\d{2})');
        i += 2;
      } else if (format.startsWith('DD', i)) {
        buffer.write(r'(?<day>\d{2})');
        i += 2;
      } else {
        buffer.write(RegExp.escape(format[i]));
        i++;
      }
    }

    buffer.write(r'$');

    return RegExp(buffer.toString());
  }
}
