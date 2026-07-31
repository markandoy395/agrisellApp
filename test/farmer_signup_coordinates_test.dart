import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('confirming a farm pin changes only the coordinate fields', () {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);
    controllers.farmAddress.text = 'Purok 2, Mabini Street';

    controllers.setFarmCoordinates(
      latitudeValue: 14.5995,
      longitudeValue: 120.9842,
    );

    expect(controllers.latitude.text, '14.5995');
    expect(controllers.longitude.text, '120.9842');
    expect(controllers.farmAddress.text, 'Purok 2, Mabini Street');
  });
}
