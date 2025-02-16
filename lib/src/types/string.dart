import 'package:keeper/src/enums/area_code_format.dart';
import 'package:keeper/src/enums/case_sensitivity.dart';
import 'package:keeper/src/enums/country_code_format.dart';
import 'package:keeper/src/enums/phone_type.dart';
import 'package:keeper/src/enums/uuid_version.dart';
import 'package:keeper/src/messages/string_message.dart';
import 'package:keeper/src/types/refine.dart';
import 'package:keeper/src/validators/required_validator.dart';
import 'package:keeper/src/validators/string/cep_validator.dart';
import 'package:keeper/src/validators/string/cnpj_validator.dart';
import 'package:keeper/src/validators/string/contains_validator.dart';
import 'package:keeper/src/validators/string/cpf_validator.dart';
import 'package:keeper/src/validators/string/date_validator.dart';
import 'package:keeper/src/validators/string/email_validator.dart';
import 'package:keeper/src/validators/string/ends_with_validator.dart';
import 'package:keeper/src/validators/string/equals_validator.dart';
import 'package:keeper/src/validators/string/ip_validator.dart';
import 'package:keeper/src/validators/string/max_length_validator.dart';
import 'package:keeper/src/validators/string/min_length_validator.dart';
import 'package:keeper/src/validators/string/pattern_validator.dart';
import 'package:keeper/src/validators/string/phone_validator.dart';
import 'package:keeper/src/validators/string/starts_with_validator.dart';
import 'package:keeper/src/validators/string/time_validator.dart';
import 'package:keeper/src/validators/string/url_validator.dart';
import 'package:keeper/src/validators/string/uuid_validator.dart';
import 'package:keeper/src/validators/validator.dart';

class KString extends KRefine<String> {
  final StringMessage _message;

  KString(this._message, {required String? message}) {
    add(RequiredValidator(message: message ?? _message.required));
  }

  @override
  KString add(KValidator<String> validator) {
    super.add(validator);

    return this;
  }

  KString email({String? message}) {
    return add(EmailValidator(message: message ?? _message.email));
  }

  KString uuid({UUIDVersion? version, String? message}) {
    return add(
      UUIDValidator(
        message: message ?? _message.uuid,
        version: version ?? UUIDVersion.v4,
      ),
    );
  }

  KString url({String? message}) {
    return add(UrlValidator(message: message ?? _message.url));
  }

  KString cpf({String? message}) {
    return add(CPFValidator(message: message ?? _message.cpf));
  }

  KString cnpj({String? message}) {
    return add(CNPJValidator(message: message ?? _message.cnpj));
  }

  KString cep({String? message}) {
    return add(CEPValidator(message: message ?? _message.cep));
  }

  KString min(int minLength, {String? message}) {
    return add(
      MinLengthValidator(
        minLength,
        message: message ?? _message.min(minLength),
      ),
    );
  }

  KString max(int maxLength, {String? message}) {
    return add(
      MaxLengthValidator(
        maxLength,
        message: message ?? _message.max(maxLength),
      ),
    );
  }

  KString phone(
    PhoneType type, {
    String? message,
    AreaCodeFormat areaCode = AreaCodeFormat.required,
    CountryCodeFormat countryCode = CountryCodeFormat.none,
  }) {
    return add(
      PhoneValidator(
        type,
        message: message ?? _message.phone,
        areaCode: areaCode,
        countryCode: countryCode,
      ),
    );
  }

  KString time({String? message}) {
    return add(TimeValidator(message: message ?? _message.time));
  }

  KString ip({String? message}) {
    return add(IPValidator(message: message ?? _message.ip));
  }

  KString date({String? message}) {
    return add(DateValidator(message: message ?? _message.date));
  }

  KString contains(
    String data, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      ContainsValidator(
        data,
        message: message ?? _message.contains(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  KString equals(
    String data, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EqualsValidator(
        data,
        message: message ?? _message.equals(data),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  KString startsWidth(
    String prefix, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      StartsWithValidator(
        prefix,
        message: message ?? _message.startsWith(prefix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  KString endsWith(
    String sufix, {
    String? message,
    CaseSensitivity caseSensitivity = CaseSensitivity.sensitive,
  }) {
    return add(
      EndsWithValidator(
        sufix,
        message: message ?? _message.endsWith(sufix),
        caseSensitivity: caseSensitivity,
      ),
    );
  }

  KString pattern(String pattern, {String? message}) {
    return add(PatternValidator(pattern, message: message ?? _message.pattern));
  }

  @override
  KString any(covariant List<KString> types, {String? message}) {
    super.any(types, message: message ?? _message.any);

    return this;
  }

  @override
  KString every(covariant List<KString> types, {String? message}) {
    super.every(types, message: message ?? _message.every);

    return this;
  }

  @override
  KString optional() {
    super.optional();

    return this;
  }

  @override
  KString nullable() {
    super.nullable();

    return this;
  }

  @override
  KString refine(bool Function(String? data) validator, {String? message}) {
    super.refine(validator, message: message ?? _message.refine);

    return this;
  }
}
