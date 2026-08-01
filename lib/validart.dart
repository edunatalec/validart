/// Type-safe validation for Dart, inspired by Zod.
///
/// A schema is a value, not a callback: [V] builds one through fluent
/// factories ([V.string], [V.int], [V.map], [V.object]), and the result can
/// be composed, reused and shared between client and server. Running a
/// schema against an input walks a two-phase pipeline — pre-processing,
/// then validation — and yields a [VResult]: either a [VSuccess] carrying
/// the normalized value or a [VFailure] carrying a list of [VError].
///
/// Every [VError] carries a machine-readable [VError.code], a
/// human-readable [VError.message] resolved through the active [VLocale],
/// and a [VError.path] locating it inside nested maps, objects and arrays.
/// The codes themselves are constants on [VCode] and its per-type siblings
/// ([VStringCode], [VNumberCode], [VDateCode], …), which is what makes the
/// messages translatable without touching the schemas.
///
/// The package has no runtime dependencies and no code generation:
/// [VObject] validates instances of your own classes through field
/// extractor callbacks the compiler checks, and [VMap] validates the
/// JSON-like maps those classes are built from — with the same schema.
///
/// ```dart
/// final schema = V.map({
///   'email': V.string().email(),
///   'age': V.int().min(18),
/// });
///
/// print(schema.validate({'email': 'user@mail.com', 'age': 30})); // true
/// print(schema.errors({'email': 'nope', 'age': 30})!.first.code); // invalid_email
/// ```
///
/// See also:
///
///  * [V], the entry point every schema is created from.
///  * [VType], the base type holding the pipeline all schemas share.
///  * [VResult], the sealed result of parsing an input.
///  * [VLocale], which translates the error codes into messages.
///  * [Validator], the extension point for custom rules.
library;

export 'src/error.dart';
export 'src/extensions/apply_if.dart';
export 'src/phone_format.dart';
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
        VTransformedAsync,
        RefineStage;
export 'src/v.dart';
export 'src/v_code.dart';
export 'src/v_locale.dart';
export 'src/validation_mode.dart';
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
