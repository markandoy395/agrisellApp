class RiderAddress {
  const RiderAddress._();

  static bool isComplete({
    required String addressLine,
    required String barangay,
    required String cityMunicipality,
    required String province,
  }) => [
    addressLine,
    barangay,
    cityMunicipality,
    province,
  ].every((value) => value.trim().isNotEmpty);

  static String format({
    required String addressLine,
    required String barangay,
    required String cityMunicipality,
    required String province,
    String postalCode = '',
  }) => [
    addressLine.trim(),
    barangay.trim(),
    cityMunicipality.trim(),
    province.trim(),
    postalCode.trim(),
  ].where((value) => value.isNotEmpty).join(', ');
}
