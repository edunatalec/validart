## [0.1.2] - 2025-02-27

### Fixed

- Updated the installation instructions in the documentation to use a placeholder `<version>` for `validart`, ensuring clarity on versioning.

## [0.1.1] - 2025-02-23

### Fixed

- Added missing `VDate` export to the package exports.

## [0.1.0] - 2025-02-23

### Added

- **`ValidationMode`** support for:
  - `.cep()`
  - `.cnpj()`
  - `.cpf()`
  - `.phone()`
- Now, it is possible to validate formatted strings (`ValidationMode.formatted`) or unformatted ones (`ValidationMode.unformatted`).
- Improved documentation for CPF, CNPJ, CEP, and Phone, explaining how to use `ValidationMode`.

### Changed

- Updated API to support both formatted and unformatted validation for documents and phone numbers.

## [0.0.4] - 2025-02-20

### Added

- Implemented an **assertion** in `VMap.refine()` to ensure the provided `path` exists in the defined object schema.
  - This prevents referencing non-existent fields, improving validation reliability.
  - Added a **test case** to verify that an `AssertionError` is thrown when an invalid path is used.

### Changed

- Updated the **README** with more detailed documentation and examples.
- Improved **API documentation** to ensure full coverage across all public elements.

## [0.0.3] - 2025-02-19

### Added

- Introduced a new primitive validator: `v.date()`, allowing date-based validations.
- Implemented `.prime()` validator for integers to check if a number is prime.
- Added new string validators:
  - `password()`: Ensures password complexity.
  - `jwt()`: Validates JSON Web Tokens.
  - `card()`: Validates credit card numbers.
  - `integer()`: Ensures the string represents a valid integer.
  - `double()`: Ensures the string represents a valid double.
  - `slug()`: Ensures the string is a valid slug format (lowercase, hyphens, no spaces or special characters).
  - `alpha()`: Ensures the string contains only alphabetic characters.
  - `alphanumeric()`: Ensures the string contains only letters and numbers.
- Expanded test suite, achieving **100% test coverage**.

### Changed

- Standardized class names for greater consistency across the library.
- Improved error messages and default validation messages.
- Adjusted validation logic for maps within arrays, fixing issues with nested validations.
- Updated **README.md** to include detailed documentation on array validations, including `.array()`, `.unique()`, `.contains()`, `.min()`, `.max()`, and other related methods.
- Improved examples for **string** and **integer** array validation.

### Fixed

- Resolved bugs related to map validation within arrays, ensuring proper validation behavior.

## [0.0.2] - 2025-02-17

### Changed

- Renamed `string().startsWidth` to `string().startsWith` for consistency.
- Updated **README** to reflect recent changes and improvements.

### Removed

- Removed `.any()` and `.every()` functions from `.map()` as they were not applicable.

### Added

- Achieved **100% test coverage**, ensuring full validation reliability.
- Added **default messages** for all validation types, providing a consistent error handling experience.

## [0.0.1] - 2025-02-16

- Initial release
