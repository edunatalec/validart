export 'src/error.dart';
export 'src/result.dart';
export 'src/types/type.dart'
    show
        VType,
        VString,
        VBool,
        VNumber,
        VInt,
        VDouble,
        VDate,
        VArray,
        VMap,
        VObject,
        VEnum,
        VLiteral,
        VUnion,
        VTransformed,
        VTransformedAsync;
export 'src/v.dart';
export 'src/validators/string/card_brand_pattern.dart'
    show
        CardBrandPattern,
        VisaBrand,
        MastercardBrand,
        AmexBrand,
        DinersBrand,
        DiscoverBrand,
        JcbBrand;
export 'src/validators/string/license_plate_pattern.dart'
    show LicensePlatePattern, UkPlatePattern;
export 'src/validators/string/phone_pattern.dart'
    show PhonePattern, E164PhonePattern;
export 'src/validators/string/postal_code_pattern.dart'
    show
        PostalCodePattern,
        UsZipPattern,
        CaPostalCodePattern,
        UkPostcodePattern;
export 'src/validators/string/tax_id_pattern.dart'
    show TaxIdPattern, UsSsnPattern, UkNiNumberPattern, CaSinPattern;
export 'src/validators/string/uuid_validator.dart' show UuidVersion;
export 'src/validators/validator.dart';
export 'src/v_code.dart';
export 'src/v_locale.dart';
export 'src/validation_mode.dart';
export 'src/phone_format.dart';
export 'src/extensions/apply_if.dart';
