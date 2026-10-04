part of 'user_profile_service.dart';

String _databaseMessage(PostgrestException error) => switch (error.code) {
  '42501' =>
    'Your account does not have permission to update this profile. '
        'Please sign in again.',
  'PGRST116' =>
    'Your account profile could not be found. Please sign in again.',
  '23514' =>
    'One profile field does not meet the database requirements. '
        'Check the phone number and birth date.',
  _ =>
    'Your profile could not be saved '
        '(database error ${error.code ?? 'unknown'}). Please retry.',
};

UserProfile _profileFromRow(UserProfile previous, Map<String, dynamic> row) {
  final firstName = _text(row['first_name']);
  final lastName = _text(row['last_name']);
  final extensionName = _text(row['extension_name']);
  final dateOfBirth = ProfileBirthDate.parse(
    _text(row['date_of_birth']),
  ).formatted;
  return previous.copyWith(
    name: [
      firstName,
      lastName,
      extensionName,
    ].where((part) => part.isNotEmpty).join(' '),
    firstName: firstName,
    lastName: lastName,
    extensionName: extensionName,
    email: _text(row['email']),
    phoneNumber: PhilippinePhoneNumber.display(_text(row['contact_number'])),
    dateOfBirth: dateOfBirth,
  );
}

UserProfile _profileFromFarmerRow(
  UserProfile previous,
  Map<String, dynamic> row,
) {
  final firstName = _text(row['first_name']);
  final lastName = _text(row['last_name']);
  final extensionName = _text(row['suffix']);
  return previous.copyWith(
    name: [
      firstName,
      lastName,
      extensionName,
    ].where((part) => part.isNotEmpty).join(' '),
    firstName: firstName,
    lastName: lastName,
    extensionName: extensionName,
    phoneNumber: PhilippinePhoneNumber.display(_text(row['phone_number'])),
    dateOfBirth: ProfileBirthDate.parse(_text(row['date_of_birth'])).formatted,
  );
}

String? _databaseDate(ProfileBirthDate value) {
  if (value.day == null || value.month == null || value.year == null) {
    return null;
  }
  final month = value.month!.toString().padLeft(2, '0');
  final day = value.day!.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String _text(Object? value) => value?.toString().trim() ?? '';

String? _blankToNull(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}
