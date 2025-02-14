import 'package:keeper/src/enums/area_code_format.dart';
import 'package:keeper/src/enums/country_code_format.dart';
import 'package:keeper/src/enums/phone_type.dart';
import 'package:keeper/src/validators/validator.dart';

class PhoneValidator extends KValidator<String> {
  final List<PhoneType> types;
  final AreaCodeFormat areaCode;
  final CountryCodeFormat countryCode;

  PhoneValidator(
    this.types, {
    required super.message,
    this.areaCode = AreaCodeFormat.required,
    this.countryCode = CountryCodeFormat.none,
  });

  @override
  String? validate(String? value) {
    if (value == null) return message;

    for (final type in types) {
      final pattern = _buildPattern(type);

      if (RegExp(pattern).hasMatch(value)) return null;
    }

    return message;
  }

  String _buildPattern(PhoneType type) {
    String pattern = '^';

    pattern += _getCountryCodePattern(type);
    pattern += _getAreaCodePattern(type);
    pattern += type.pattern;
    pattern += '\$';

    return pattern;
  }

  String _getCountryCodePattern(PhoneType type) {
    switch (countryCode) {
      case CountryCodeFormat.required:
        return type.countryCode;
      case CountryCodeFormat.optional:
        return '(${type.countryCode})?';
      case CountryCodeFormat.none:
        return '';
    }
  }

  String _getAreaCodePattern(PhoneType type) {
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
