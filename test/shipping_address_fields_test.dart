import 'package:agresell_app/features/buyer/profile/domain/shipping_address_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const saved =
      'House 12, Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, 8501, Philippines';

  test(
    'saved address separates fields without losing commas in street details',
    () {
      final fields = ShippingAddressFields.fromAddress(saved);
      expect(fields.street, 'House 12, Purok 5');
      expect(fields.barangay, 'Hubang');
      expect(fields.city, 'San Francisco');
      expect(fields.province, 'Agusan del Sur');
      expect(fields.postalCode, '8501');
      expect(fields.formatted, saved);
    },
  );

  test('addresses without postal codes round trip', () {
    const address =
        'Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, Philippines';
    final fields = ShippingAddressFields.fromAddress(address);
    expect(fields.postalCode, '');
    expect(fields.formatted, address);
  });

  test('existing optional postal text is preserved when reopening', () {
    final address = saved.replaceFirst('8501', '8501-001');
    final fields = ShippingAddressFields.fromAddress(address);
    expect(fields.postalCode, '8501-001');
    expect(fields.formatted, address);
  });

  test('unrecognized legacy text is preserved for manual correction', () {
    for (final address in [
      '',
      'Near the church',
      'House 12, Block 3, Lot 4, Main Road',
    ]) {
      final fields = ShippingAddressFields.fromAddress(address);
      expect(fields.street, address);
      expect(fields.province, '');
      expect(fields.city, '');
      expect(fields.barangay, '');
    }
  });

  test(
    'several commas or Philippines in street details cannot bypass selected areas',
    () {
      for (final street in [
        'House 12, Block 3, Lot 4, Main Road',
        '12 Philippines Road',
      ]) {
        final fields = ShippingAddressFields(
          street: street,
          barangay: 'Hubang',
          city: 'San Francisco',
          province: 'Agusan del Sur',
        );
        expect(
          fields.formatted,
          '$street, Barangay Hubang, San Francisco, Agusan del Sur, Philippines',
        );
      }
    },
  );

  test('pasted full address uses the newly edited area and postal fields', () {
    const fields = ShippingAddressFields(
      street: saved,
      barangay: 'Poblacion',
      city: 'Lianga',
      province: 'Surigao del Sur',
      postalCode: '8307',
    );
    expect(
      fields.formatted,
      'House 12, Purok 5, Barangay Poblacion, Lianga, Surigao del Sur, 8307, Philippines',
    );
  });

  test('barangay prefixes and surrounding whitespace are normalized', () {
    const fields = ShippingAddressFields(
      street: ' Purok 5 ',
      barangay: ' Brgy. Hubang ',
      city: ' San Francisco ',
      province: ' Agusan del Sur ',
    );
    expect(
      fields.formatted,
      'Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, Philippines',
    );
    final parsed = ShippingAddressFields.fromAddress(
      fields.formatted.replaceFirst('Barangay', 'BRGY.'),
    );
    expect(parsed.barangay, 'Hubang');
  });
}
