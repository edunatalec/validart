import 'package:keeper/src/enums/area_code_format.dart';
import 'package:keeper/src/enums/country_code_format.dart';
import 'package:keeper/src/enums/phone_type.dart';
import 'package:keeper/src/validators/validator.dart';

class PhoneValidator extends KValidator<String> {
  final PhoneType type;
  final AreaCodeFormat areaCode;
  final CountryCodeFormat countryCode;

  PhoneValidator(
    this.type, {
    required super.message,
    this.areaCode = AreaCodeFormat.required,
    this.countryCode = CountryCodeFormat.none,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    final pattern = _buildPattern();

    if (RegExp(pattern).hasMatch(value)) return null;

    return message;
  }

  String _buildPattern() {
    String pattern = '^';

    pattern += _getCountryCodePattern;
    pattern += _getAreaCodePattern;
    pattern += type.pattern;
    pattern += '\$';

    return pattern;
  }

  String get _getCountryCodePattern {
    switch (countryCode) {
      case CountryCodeFormat.required:
        return type.countryCode;
      case CountryCodeFormat.optional:
        return '(${type.countryCode})?';
      case CountryCodeFormat.none:
        return '';
    }
  }

  String get _getAreaCodePattern {
    switch (areaCode) {
      case AreaCodeFormat.required:
        return type.areaCode;
      case AreaCodeFormat.optional:
        return '(${type.areaCode})?';
      case AreaCodeFormat.none:
        return '';
    }
  }
}
