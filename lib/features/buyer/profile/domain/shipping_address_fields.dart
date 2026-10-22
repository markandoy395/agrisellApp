/// Editable parts of the buyer's combined, human-readable shipping address.
class ShippingAddressFields {
  const ShippingAddressFields({
    required this.street,
    this.province = '',
    this.city = '',
    this.barangay = '',
    this.postalCode = '',
  });

  final String street;
  final String province;
  final String city;
  final String barangay;
  final String postalCode;

  static final _barangayPrefix = RegExp(
    r'^(?:barangay|brgy\.?)\s+',
    caseSensitive: false,
  );

  factory ShippingAddressFields.fromAddress(String address) {
    final original = address.trim();
    final parts = original.split(',').map((part) => part.trim()).toList();
    if (parts.last.toLowerCase() == 'philippines') parts.removeLast();
    final barangayIndex = parts.indexWhere(_barangayPrefix.hasMatch);
    if (barangayIndex <= 0) return ShippingAddressFields(street: original);
    final suffix = parts.sublist(barangayIndex + 1);
    // Only split the app's known format; do not guess ambiguous legacy text.
    if (suffix.length < 2 ||
        suffix.length > 3 ||
        suffix.any((part) => part.isEmpty)) {
      return ShippingAddressFields(street: original);
    }
    return ShippingAddressFields(
      street: parts.sublist(0, barangayIndex).join(', '),
      barangay: parts[barangayIndex].replaceFirst(_barangayPrefix, ''),
      city: suffix[0],
      province: suffix[1],
      postalCode: suffix.length == 3 ? suffix[2] : '',
    );
  }

  String get formatted {
    // Pasting a previously saved full address must not override area edits.
    final streetDetails = ShippingAddressFields.fromAddress(street).street;
    final barangayName = barangay.trim().replaceFirst(_barangayPrefix, '');
    return [
      streetDetails.trim(),
      if (barangayName.isNotEmpty) 'Barangay $barangayName',
      city.trim(),
      province.trim(),
      postalCode.trim(),
      'Philippines',
    ].where((part) => part.isNotEmpty).join(', ');
  }
}
