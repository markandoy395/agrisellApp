import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registration maps the required rider record fields', () {
    final profile = RiderProfile.fromRegistration(
      const RiderRegistration(
        firstName: 'Ana',
        middleName: 'Maria',
        lastName: 'Reyes',
        dateOfBirth: '2000-01-01',
        gender: 'Female',
        contactNumber: '09171234567',
        email: 'ANA@EXAMPLE.COM',
        gpsLatitude: 8.4822,
        gpsLongitude: 124.6472,
        vehicleType: RiderVehicleType.motorcycle,
        vehiclePlateNumber: 'abc 1234',
        licenseNumber: 'n01-23-456789',
        profilePhotoPath: '/local/rider.jpg',
        password: 'Password1!',
        confirmPassword: 'Password1!',
        acceptsTerms: true,
        acceptsPrivacy: true,
        confirmsAccuracy: true,
      ),
      id: 'rider-1',
    );

    expect(profile.id, 'rider-1');
    expect(profile.logisticCompanyId, isNull);
    expect(profile.licenseNumber, 'N01-23-456789');
    expect(profile.fullName, 'Ana Maria Reyes');
    expect(profile.firstName, 'Ana');
    expect(profile.lastName, 'Reyes');
    expect(profile.vehiclePlateNumber, 'ABC 1234');
    expect(profile.availabilityStatus, RiderAvailability.offline);
    expect(profile.rating, 0);
    expect(profile.contactNumber, '09171234567');
    expect(profile.email, 'ana@example.com');
    expect(profile.gpsLatitude, 8.4822);
    expect(profile.gpsLongitude, 124.6472);
    expect(profile.hasRegisteredServiceCoordinates, isTrue);
    expect(profile.hasRegisteredServiceArea, isFalse);
    expect(profile.hasValidServiceRadius, isFalse);
    expect(profile.totalDeliveries, 0);
    expect(profile.employmentStatus, RiderEmploymentStatus.pending);
    expect(profile.profilePhotoUrl, '/local/rider.jpg');
  });
}
