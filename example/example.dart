import 'package:keeper/keeper.dart';

void main() {
  final k = Keeper();

  // Example: Validating a required string
  final nameValidator = k.string();
  print(nameValidator.validate('John Doe')); // true
  print(nameValidator.validate('')); // false

  // Example: Validating an email
  final emailValidator = k.string().email();
  print(emailValidator.validate('user@example.com')); // true
  print(emailValidator.validate('invalid-email')); // false

  // Example: Validating a phone number (Brazil)
  final phoneValidator = k.string().phone(PhoneType.brazil);
  print(phoneValidator.validate('11 98765-4321')); // true
  print(phoneValidator.validate('1234567890')); // false

  // Example: Validating an integer with min/max constraints
  final ageValidator = k.int().min(18).max(60);
  print(ageValidator.validate(25)); // true
  print(ageValidator.validate(15)); // false
  print(ageValidator.validate(65)); // false

  // Example: Validating an array of emails
  final emailArrayValidator = k.string().email().array();
  print(
    emailArrayValidator.validate(['user@example.com', 'test@mail.com']),
  ); // true
  print(
    emailArrayValidator.validate(['user@example.com', 'invalid-email']),
  ); // false

  // Example: Validating a map with fields
  final userValidator = k.map({
    'name': k.string().min(3),
    'email': k.string().email(),
    'age': k.int().min(18),
  });

  final validUser = {'name': 'Alice', 'email': 'alice@example.com', 'age': 30};
  final invalidUser = {'name': 'Al', 'email': 'alice@', 'age': 16};

  print(userValidator.validate(validUser)); // true
  print(userValidator.getErrorMessage(invalidUser));
  // {'name': 'At least 3 characters required', 'email': 'Enter a valid email', 'age': 'The number must be at least 18'}
}
