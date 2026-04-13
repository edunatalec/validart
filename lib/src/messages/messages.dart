class VMessages {
  final String required;
  final String invalidType;
  final String invalidValue;
  final VStringMessages string;
  final VNumberMessages number;
  final VBoolMessages bool;
  final VDateMessages date;
  final VMapMessages map;
  final VObjectMessages object;
  final VArrayMessages array;

  const VMessages({
    this.required = 'Required',
    this.invalidType = 'Invalid type',
    this.invalidValue = 'Invalid value',
    this.string = const VStringMessages(),
    this.number = const VNumberMessages(),
    this.bool = const VBoolMessages(),
    this.date = const VDateMessages(),
    this.map = const VMapMessages(),
    this.object = const VObjectMessages(),
    this.array = const VArrayMessages(),
  });
}

class VStringMessages {
  final String Function(int) min;
  final String Function(int) max;
  final String Function(int) length;
  final String email;
  final String url;
  final String uuid;
  final String ip;
  final String pattern;
  final String date;
  final String time;
  final String Function(String) contains;
  final String Function(String) startsWith;
  final String Function(String) endsWith;
  final String Function(String) equals;
  final String alpha;
  final String alphanumeric;
  final String slug;
  final String password;
  final String jwt;
  final String card;
  final String phone;

  const VStringMessages({
    this.min = _defaultMin,
    this.max = _defaultMax,
    this.length = _defaultLength,
    this.email = 'Invalid email address',
    this.url = 'Invalid URL',
    this.uuid = 'Invalid UUID',
    this.ip = 'Invalid IP address',
    this.pattern = 'Invalid format',
    this.date = 'Invalid date',
    this.time = 'Invalid time',
    this.contains = _defaultContains,
    this.startsWith = _defaultStartsWith,
    this.endsWith = _defaultEndsWith,
    this.equals = _defaultEquals,
    this.alpha = 'Must contain only letters',
    this.alphanumeric = 'Must contain only letters and numbers',
    this.slug = 'Must be a valid slug',
    this.password =
        'Password must have at least 8 characters, including uppercase, lowercase, digit, and special character',
    this.jwt = 'Invalid JWT',
    this.card = 'Invalid credit card number',
    this.phone = 'Invalid phone number',
  });

  static String _defaultMin(int v) => 'Must be at least $v characters';
  static String _defaultMax(int v) => 'Must be at most $v characters';
  static String _defaultLength(int v) => 'Must be exactly $v characters';
  static String _defaultContains(String v) => 'Must contain "$v"';
  static String _defaultStartsWith(String v) => 'Must start with "$v"';
  static String _defaultEndsWith(String v) => 'Must end with "$v"';
  static String _defaultEquals(String v) => 'Must be equal to "$v"';
}

class VNumberMessages {
  final String Function(num) min;
  final String Function(num) max;
  final String positive;
  final String negative;
  final String Function(num, num) between;
  final String Function(num) multipleOf;
  final String even;
  final String odd;
  final String prime;
  final String finite;
  final String decimal;
  final String integer;

  const VNumberMessages({
    this.min = _defaultMin,
    this.max = _defaultMax,
    this.positive = 'Must be positive',
    this.negative = 'Must be negative',
    this.between = _defaultBetween,
    this.multipleOf = _defaultMultipleOf,
    this.even = 'Must be even',
    this.odd = 'Must be odd',
    this.prime = 'Must be prime',
    this.finite = 'Must be finite',
    this.decimal = 'Must be a decimal number',
    this.integer = 'Must be an integer',
  });

  static String _defaultMin(num v) => 'Must be at least $v';
  static String _defaultMax(num v) => 'Must be at most $v';
  static String _defaultBetween(num min, num max) =>
      'Must be between $min and $max';
  static String _defaultMultipleOf(num v) => 'Must be a multiple of $v';
}

class VBoolMessages {
  final String isTrue;
  final String isFalse;

  const VBoolMessages({
    this.isTrue = 'Must be true',
    this.isFalse = 'Must be false',
  });
}

class VDateMessages {
  final String Function(DateTime) after;
  final String Function(DateTime) before;
  final String Function(DateTime, DateTime) between;
  final String weekday;
  final String weekend;

  const VDateMessages({
    this.after = _defaultAfter,
    this.before = _defaultBefore,
    this.between = _defaultBetween,
    this.weekday = 'Must be a weekday',
    this.weekend = 'Must be a weekend',
  });

  static String _defaultAfter(DateTime d) => 'Must be after $d';
  static String _defaultBefore(DateTime d) => 'Must be before $d';
  static String _defaultBetween(DateTime min, DateTime max) =>
      'Must be between $min and $max';
}

class VMapMessages {
  final String required;
  final String invalidType;

  const VMapMessages({
    this.required = 'Required',
    this.invalidType = 'Invalid type',
  });
}

class VObjectMessages {
  final String required;
  final String invalidType;

  const VObjectMessages({
    this.required = 'Required',
    this.invalidType = 'Invalid type',
  });
}

class VArrayMessages {
  final String Function(int) min;
  final String Function(int) max;
  final String unique;
  final String contains;

  const VArrayMessages({
    this.min = _defaultMin,
    this.max = _defaultMax,
    this.unique = 'Must contain unique values',
    this.contains = 'Must contain all required values',
  });

  static String _defaultMin(int v) => 'Must have at least $v items';
  static String _defaultMax(int v) => 'Must have at most $v items';
}
