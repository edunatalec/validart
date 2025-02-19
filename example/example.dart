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

  // Example: Validating an array of integers with min/max constraints
  final intArrayValidator = v.int().array().min(2).max(5);
  print(intArrayValidator.validate([10, 20, 30])); // true
  print(intArrayValidator.validate([10])); // false (less than 2 elements)
  print(intArrayValidator
      .validate([10, 20, 30, 40, 50, 60])); // false (more than 5 elements)

  // Example: Validating an array of unique strings
  final uniqueStringArrayValidator = v.string().array().unique();
  print(uniqueStringArrayValidator
      .validate(['apple', 'banana', 'cherry'])); // true
  print(uniqueStringArrayValidator
      .validate(['apple', 'banana', 'apple'])); // false (duplicate value)

  // Example: Ensuring an array contains specific values
  final containsValidator = v.string().array().contains(['admin', 'user']);
  print(containsValidator.validate(['admin', 'user', 'guest'])); // true
  print(containsValidator
      .validate(['guest', 'visitor'])); // false (missing required values)

  // Example: Nullable array
  final nullableArrayValidator = v.string().array().nullable();
  print(nullableArrayValidator.validate(null)); // true
  print(nullableArrayValidator.validate(['valid'])); // true
  print(nullableArrayValidator.validate([])); // false (empty array not allowed)

  // Example: Array of maps (objects)
  final userArrayValidator = v
      .map({
        'name': v.string().min(3),
        'email': v.string().email(),
      })
      .array()
      .min(1);

  final validUsers = [
    {'name': 'Alice', 'email': 'alice@example.com'},
    {'name': 'Bob', 'email': 'bob@example.com'},
  ];
  final invalidUsers = [
    {'name': 'Al', 'email': 'invalid-email'},
  ];

  print(userArrayValidator.validate(validUsers)); // true
  print(userArrayValidator.getErrorMessage(invalidUsers));
  // {'name': 'Minimum length: 3 characters', 'email': 'Please provide a valid email'}
}
