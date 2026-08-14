class RiderRegistration {
  const RiderRegistration({
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.email,
    required this.gpsLatitude,
    required this.gpsLongitude,
    this.locationLabel = '',
    this.addressLine = '',
    this.barangay = '',
    this.cityMunicipality = '',
    this.province = '',
    this.postalCode = '',
    this.locationNotes = '',
    this.gpsAccuracyMeters,
    this.locationCapturedAt,
    required this.vehicleType,
    required this.vehiclePlateNumber,
    required this.licenseNumber,
    required this.profilePhotoPath,
    required this.password,
    required this.confirmPassword,
    required this.acceptsTerms,
    required this.acceptsPrivacy,
    required this.confirmsAccuracy,
    this.logisticsCompanyId,
  });

  final String firstName;
  final String middleName;
  final String lastName;
  final String dateOfBirth;
  final String gender;
  final String contactNumber;
  final String email;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String locationLabel;
  final String addressLine;
  final String barangay;
  final String cityMunicipality;
  final String province;
  final String postalCode;
  final String locationNotes;
  final double? gpsAccuracyMeters;
  final DateTime? locationCapturedAt;
  final RiderVehicleType? vehicleType;
  final String vehiclePlateNumber;
  final String licenseNumber;
  final String? profilePhotoPath;
  final String password;
  final String confirmPassword;
  final bool acceptsTerms;
  final bool acceptsPrivacy;
  final bool confirmsAccuracy;
  final String? logisticsCompanyId;

  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part.trim().isNotEmpty).join(' ');
}

enum RiderVehicleType {
  motorcycle,
  bicycle,
  eBike,
  tricycle,
  car,
  van,
  truck,
  other,
}

extension RiderVehicleTypeDetails on RiderVehicleType {
  String get label => switch (this) {
    RiderVehicleType.motorcycle => 'Motorcycle',
    RiderVehicleType.bicycle => 'Bicycle',
    RiderVehicleType.eBike => 'E-bike',
    RiderVehicleType.tricycle => 'Tricycle',
    RiderVehicleType.car => 'Car',
    RiderVehicleType.van => 'Van',
    RiderVehicleType.truck => 'Truck',
    RiderVehicleType.other => 'Other delivery vehicle',
  };

  bool get requiresPlate =>
      this != RiderVehicleType.bicycle && this != RiderVehicleType.eBike;
  bool get requiresLicense => requiresPlate;
}
