import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_farm_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('farm coordinates stay hidden after a location is pinned', (
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
              onPickLocation: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.widgetWithText(TextField, 'Latitude'), findsNothing);
    expect(find.widgetWithText(TextField, 'Longitude'), findsNothing);
    expect(find.text('Tap to adjust the farm location pin'), findsOneWidget);
    expect(controllers.latitude.text, '14.5995');
    expect(controllers.longitude.text, '120.9842');
  });

  testWidgets('empty farm location shows a tappable map preview', (
    tester,
  ) async {
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerSignupFarmStep(
              controllers: controllers,
              errors: const {},
              onChanged: () {},
              onPickLocation: () => tapped = true,
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    final label = find.text('Tap to select the exact farm location *');
    expect(label, findsOneWidget);
    await tester.tap(label);
    expect(tapped, isTrue);
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
              onPickLocation: () {},
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
              onPickLocation: () {},
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
                'farmLocation': 'Choose your farm location.',
                'yearsOfExperience': 'Enter your years of farming experience.',
              },
              onChanged: () {},
              onPickLocation: () {},
              onPickImage: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Choose your farm location.'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Years of farming experience'),
      findsOneWidget,
    );
  });
}
