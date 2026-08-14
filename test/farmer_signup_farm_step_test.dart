import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_farm_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farm coordinates stay hidden in the farm step UI', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);
    controllers.latitude.text = '14.5995';
    controllers.longitude.text = '120.9842';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {},
              onChanged: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Latitude'), findsNothing);
    expect(find.widgetWithText(TextField, 'Longitude'), findsNothing);
    expect(find.text('Farm GPS location'), findsNothing);
    expect(find.text('Refresh location'), findsNothing);
    expect(find.textContaining('Latitude'), findsNothing);
    expect(find.textContaining('longitude'), findsNothing);
    expect(controllers.latitude.text, '14.5995');
    expect(controllers.longitude.text, '120.9842');
  });

  testWidgets('empty farm location does not show GPS capture controls', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {},
              onChanged: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.widgetWithText(OutlinedButton, 'Use current location'),
      findsNothing,
    );
    expect(find.byIcon(Icons.my_location_rounded), findsNothing);
  });

  testWidgets('same address copies farmer area details into the farm', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);
    controllers.province.text = 'Bukidnon';
    controllers.city.text = 'Valencia City';
    controllers.barangay.text = 'Lumbo';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {},
              onChanged: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    final button = find.text('Same as farmer address');
    await tester.ensureVisible(button);
    final addressSync = find.byType(Switch);
    expect(tester.widget<Switch>(addressSync).value, isFalse);
    await tester.tap(addressSync);
    await tester.pump();

    expect(tester.widget<Switch>(addressSync).value, isTrue);
    expect(controllers.farmProvince.text, 'Bukidnon');
    expect(controllers.farmCity.text, 'Valencia City');
    expect(controllers.farmBarangay.text, 'Lumbo');
    expect(controllers.farmAddress.text, isEmpty);
  });

  testWidgets('farming type opens a list and accepts a selection', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {},
              onChanged: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    final field = find.byKey(const ValueKey('farmer-Farming type-options'));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();

    expect(find.text('Organic farming'), findsOneWidget);
    await tester.tap(find.text('Organic farming'));
    await tester.pumpAndSettle();
    expect(controllers.farmingType.text, 'Organic farming');
  });

  testWidgets('farm location and experience validation errors are visible', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {
                'farmLocation':
                    'Allow location access so we can capture your farm location.',
                'yearsOfExperience': 'Enter your years of farming experience.',
              },
              onChanged: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Allow location access so we can capture your farm location.'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextField, 'Years of farming experience'),
      findsOneWidget,
    );
  });
}
