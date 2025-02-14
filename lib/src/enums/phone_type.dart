enum PhoneType {
  brazil(
    pattern: r'\d{5}-\d{4}',
    areaCode: r'\(?\d{2}\)?\s',
    countryCode: r'\+55\s',
  ),
  usa(
    pattern: r'\d{3}-\d{4}',
    areaCode: r'\(?\d{3}\)?\s|\d{3}-',
    countryCode: r'\+1\s',
  ),
  argentina(
    pattern: r'\d{4}-?\d{4}',
    areaCode: r'\(?\d{2,4}\)?\s',
    countryCode: r'\+54\s',
  ),
  germany(
    pattern: r'\d{3,8}',
    areaCode: r'\(?\d{2,5}\)?\s',
    countryCode: r'\+49\s',
  ),
  china(
    pattern: r'\d{4}\s?\d{4}',
    areaCode: r'\d{2,3}\s',
    countryCode: r'\+86\s',
  ),
  japan(
    pattern: r'\d{4}-?\d{4}',
    areaCode: r'\d{1,2}-',
    countryCode: r'\+81\s',
  ),
  international(
    pattern: r'\d{3,5}(\s|-)\d{3,5}',
    areaCode: r'\d{1,5}(\s|-)',
    countryCode: r'\+\d{1,3}\s',
  );

  final String pattern;
  final String areaCode;
  final String countryCode;

  const PhoneType({
    required this.pattern,
    required this.areaCode,
    required this.countryCode,
  });
}
