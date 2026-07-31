class PasswordRequirement {
  const PasswordRequirement({required this.label, required this.isMet});

  final String label;
  final bool isMet;
}

abstract final class PasswordPolicy {
  static final _uppercase = RegExp(r'[A-Z]');
  static final _lowercase = RegExp(r'[a-z]');
  static final _number = RegExp(r'\d');
  static final _specialCharacter = RegExp(r'[^A-Za-z0-9]');

  static List<PasswordRequirement> evaluate(String password) => [
    PasswordRequirement(
      label: 'At least 8 characters',
      isMet: password.length >= 8,
    ),
    PasswordRequirement(
      label: 'One uppercase letter',
      isMet: _uppercase.hasMatch(password),
    ),
    PasswordRequirement(
      label: 'One lowercase letter',
      isMet: _lowercase.hasMatch(password),
    ),
    PasswordRequirement(label: 'One number', isMet: _number.hasMatch(password)),
    PasswordRequirement(
      label: 'One special character',
      isMet: _specialCharacter.hasMatch(password),
    ),
  ];

  static bool isStrong(String password) =>
      evaluate(password).every((requirement) => requirement.isMet);
}
