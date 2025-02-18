import 'package:validart/validart.dart';

void main() {
  final baseMessage = BaseMessage(
    required: 'This field is required',
    refine: 'Invalid value provided',
    any: 'At least one condition must be met',
    every: 'All conditions must be met',
  );

  final stringMessage = StringMessage(
    email: 'Please provide a valid email',
    min: (value) => 'Minimum length: $value characters',
  ).mergeWithBase(baseMessage);

  final customMessages = Message(
    base: baseMessage,
    string: stringMessage,
  );

  final v = Validart(message: customMessages);

  // Example: Validating a required string
  final nameValidator = v.string();
  print(nameValidator.validate('John Doe')); // true
  print(nameValidator.validate('')); // false

  // Example: Validating an email
  final emailValidator = v.string().email();
  print(emailValidator.validate('user@example.com')); // true
  print(emailValidator.validate('invalid-email')); // false

  // Example: Validating a phone number (Brazil)
  final phoneValidator = v.string().phone(PhoneType.brazil);
  print(phoneValidator.validate('11 98765-4321')); // true
  print(phoneValidator.validate('1234567890')); // false

  // Example: Validating an integer with min/max constraints
  final ageValidator = v.int().min(18).max(60);
  print(ageValidator.validate(25)); // true
  print(ageValidator.validate(15)); // false
  print(ageValidator.validate(65)); // false

  // Example: Validating an array of emails
  final emailArrayValidator = v.string().email().array();
  print(
    emailArrayValidator.validate(['user@example.com', 'test@mail.com']),
  ); // true
  print(
    emailArrayValidator.validate(['user@example.com', 'invalid-email']),
  ); // false

  // Example: Validating a map with fields
  final userValidator = v.map({
    'name': v.string().min(3),
    'email': v.string().email(),
    'age': v.int().min(18),
  });

  final validUser = {'name': 'Alice', 'email': 'alice@example.com', 'age': 30};
  final invalidUser = {'name': 'Al', 'email': 'alice@', 'age': 16};

  print(userValidator.validate(validUser)); // true
  print(userValidator.getErrorMessage(invalidUser));
  // {'name': 'Minimum length: 3 characters', 'email': 'Please provide a valid email', 'age': 'The number must be at least 18'}
}
