// Internal date-parsing helper — shared between `DateStringValidator`
// (validation) and `VCoerce.date()` (coercion). Not exported via
// `lib/validart.dart`; external consumers should use one of those
// higher-level APIs instead.

/// Default format patterns accepted by `V.string().date()` and
/// `V.coerce.date()` when no specific format is requested.
///
/// Order matters for ambiguous inputs like `'01/02/2024'`: the first
/// format that matches wins. `DD/MM/YYYY` appears before `MM/DD/YYYY`,
/// so `01/02/2024` is read as 1-Feb, not 2-Jan.
const List<String> defaultDateFormats = [
  'YYYY-MM-DD',
  'YYYY/MM/DD',
  'YYYYMMDD',
  'DD/MM/YYYY',
  'MM/DD/YYYY',
  'DD-MM-YYYY',
  'MM-DD-YYYY',
  'DD.MM.YYYY',
];

/// Parses [value] as a `DateTime`, trying ISO 8601 first (via
/// [DateTime.parse]) and then each pattern in [formats] (or
/// [defaultDateFormats] when omitted). Returns `null` when no pattern
/// matches or when the date is calendar-invalid (e.g. `2024-02-30`).
DateTime? tryParseFlexibleDate(String value, [List<String>? formats]) {
  // Fast path for ISO 8601 strings with a time component
  // (`2024-01-15T10:30:00`, `2024-01-15 10:30`). For date-only strings
  // we defer to the format loop, which performs explicit calendar
  // validation — `DateTime.parse` silently rolls `2024-02-30` over to
  // 2024-03-01, and we must reject that.
  if (value.contains('T') || value.contains(' ')) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Fall through to format matching.
    }
  }

  for (final format in formats ?? defaultDateFormats) {
    final parsed = _matchFormat(value, format);

    if (parsed != null) return parsed;
  }

  return null;
}

DateTime? _matchFormat(String value, String format) {
  if (!format.contains('YYYY') ||
      !format.contains('MM') ||
      !format.contains('DD')) {
    return null;
  }

  final regex = _formatToRegex(format);
  final match = regex.firstMatch(value);

  if (match == null) return null;

  final yearStr = match.namedGroup('year');
  final monthStr = match.namedGroup('month');
  final dayStr = match.namedGroup('day');

  if (yearStr == null || monthStr == null || dayStr == null) return null;

  final year = int.parse(yearStr);
  final month = int.parse(monthStr);
  final day = int.parse(dayStr);

  final date = DateTime(year, month, day);

  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }

  return date;
}

RegExp _formatToRegex(String format) {
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
