import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';

class SavedAccount {
  const SavedAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory SavedAccount.fromAccount(RegisteredAccount account) {
    return SavedAccount(
      id: account.id,
      firstName: account.firstName,
      lastName: account.lastName,
      email: account.email,
      role: account.role,
    );
  }

  factory SavedAccount.fromJson(Map<String, Object?> json) {
    return SavedAccount(
      id: _requiredText(json['id']),
      firstName: _text(json['firstName']),
      lastName: _text(json['lastName']),
      email: _requiredText(json['email']),
      role: _requiredText(json['role']),
    );
  }

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  String get displayName {
    final name = [
      firstName,
      lastName,
    ].where((part) => part.trim().isNotEmpty).join(' ');
    return name.isEmpty ? email : name;
  }

  AuthRole? get assignedRole => AuthRole.fromValue(role);

  Map<String, Object> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'role': role,
  };
}

String _text(Object? value) => value?.toString().trim() ?? '';

String _requiredText(Object? value) {
  final text = _text(value);
  if (text.isEmpty) throw const FormatException('Missing saved account field.');
  return text;
}
