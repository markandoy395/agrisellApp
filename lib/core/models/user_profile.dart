class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    this.firstName = '',
    this.lastName = '',
    this.extensionName = '',
    this.shippingLatitude,
    this.shippingLongitude,
  });

  final String name;
  final String email;
  final String address;
  final String phoneNumber;
  final String gender;
  final String dateOfBirth;
  final String firstName;
  final String lastName;
  final String extensionName;
  final double? shippingLatitude;
  final double? shippingLongitude;

  String get headerName {
    final value = [
      firstName.trim(),
      lastName.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    if (value.isNotEmpty) return value;
    return name.trim().isEmpty ? 'Account' : name.trim();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? address,
    String? phoneNumber,
    String? gender,
    String? dateOfBirth,
    String? firstName,
    String? lastName,
    String? extensionName,
    double? shippingLatitude,
    double? shippingLongitude,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      extensionName: extensionName ?? this.extensionName,
      shippingLatitude: shippingLatitude ?? this.shippingLatitude,
      shippingLongitude: shippingLongitude ?? this.shippingLongitude,
    );
  }

  List<ProfileInfoEntry> get infoEntries {
    return [
      ProfileInfoEntry(label: 'First Name', value: firstName),
      ProfileInfoEntry(label: 'Last Name', value: lastName),
      ProfileInfoEntry(label: 'Name Extension', value: extensionName),
      ProfileInfoEntry(label: 'Phone Number', value: phoneNumber),
      ProfileInfoEntry(label: 'Date of Birth', value: dateOfBirth),
      ProfileInfoEntry(label: 'Email', value: email),
    ];
  }
}

class ProfileInfoEntry {
  const ProfileInfoEntry({required this.label, required this.value});

  final String label;
  final String value;
}
