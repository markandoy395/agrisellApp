import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a complete Philippine rider address', () {
    expect(
      RiderAddress.format(
        addressLine: '12 Rizal Street',
        barangay: 'Cogon',
        cityMunicipality: 'Cagayan de Oro City',
        province: 'Misamis Oriental',
        postalCode: '9000',
      ),
      '12 Rizal Street, Cogon, Cagayan de Oro City, Misamis Oriental, 9000',
    );
  });
}
