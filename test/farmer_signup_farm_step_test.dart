import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_farm_step.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_crops_field.dart';
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
    controllers.address.text = '123 Farm Road';
    controllers.province.text = 'Bukidnon';
    controllers.city.text = 'Valencia City';
    controllers.barangay.text = 'Lumbo';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: FarmerSignupFarmStep(
                controllers: controllers,
                errors: const {},
                onChanged: () => setState(() {}),
                onPickImage: () {},
              ),
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
    expect(controllers.farmAddress.text, '123 Farm Road');
    final farmStreetField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.controller == controllers.farmAddress,
    );
    expect(tester.widget<TextField>(farmStreetField).enabled, isFalse);
    controllers.address.text = '456 New Road';
    expect(controllers.farmAddress.text, '456 New Road');
    await tester.tap(addressSync);
    await tester.pump();
    expect(tester.widget<TextField>(farmStreetField).enabled, isTrue);
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

    final field = find.byKey(const ValueKey('farmer-Farming Type-options'));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();

    expect(find.text('Rice (Palay)'), findsOneWidget);
    await tester.tap(find.text('Rice (Palay)'));
    await tester.pumpAndSettle();
    expect(controllers.farmingType.text, 'Rice (Palay)');
  });

  testWidgets('farm choices fit a narrow phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controllers = FarmerSignupControllers();
    addTearDown(controllers.dispose);
    controllers.ownershipType.text =
        'Agrarian Reform Beneficiary (CLOA/EP Holder)';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FarmerSignupFarmStep(
                controllers: controllers,
                errors: const {},
                onChanged: () {},
                onPickImage: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(
      find.byKey(
        const ValueKey('farmer-Land Tenure / Ownership Status-options'),
      ),
    );
    await tester.pump();
    final textField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.controller == controllers.farmSize,
    );
    final expectedHeight = tester.getSize(textField).height;
    for (final label in [
      'Farm Size Unit',
      'Farming Type',
      'Land Tenure / Ownership Status',
      'Irrigation Type (optional)',
    ]) {
      expect(
        tester.getSize(find.byKey(ValueKey('farmer-$label-options'))).height,
        expectedHeight,
      );
    }
    expect(
      tester
          .getSize(
            find.descendant(
              of: find.byType(FarmerSignupCropsField),
              matching: find.byType(DropdownButtonFormField<String>),
            ),
          )
          .height,
      expectedHeight,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('decimal farm size, unit, and tenure keep separate values', (
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

    final sizeField = find.widgetWithText(TextField, 'Farm size');
    await tester.ensureVisible(sizeField);
    await tester.enterText(sizeField, '1.5');
    expect(controllers.farmSize.text, '1.5');

    final unit = find.byKey(const ValueKey('farmer-Farm Size Unit-options'));
    await tester.ensureVisible(unit);
    await tester.tap(unit);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Square Meters (sq m)').last);
    await tester.pumpAndSettle();
    expect(controllers.farmSizeUnit.text, 'sq m');

    final tenure = find.byKey(
      const ValueKey('farmer-Land Tenure / Ownership Status-options'),
    );
    await tester.ensureVisible(tenure);
    await tester.tap(tenure);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registered Owner').last);
    await tester.pumpAndSettle();
    expect(controllers.ownershipType.text, 'Registered Owner');
    expect(controllers.farmSize.text, '1.5');

    final irrigation = find.byKey(
      const ValueKey('farmer-Irrigation Type (optional)-options'),
    );
    await tester.ensureVisible(irrigation);
    await tester.tap(irrigation);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rainfed / No Irrigation').last);
    await tester.pumpAndSettle();
    expect(controllers.irrigationType.text, 'Rainfed / No Irrigation');
  });

  testWidgets('main crops are selected from the Philippine crop list', (
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

    final cropsField = find.byType(FarmerSignupCropsField);
    await tester.ensureVisible(cropsField);
    await tester.tap(
      find.descendant(
        of: cropsField,
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abaca').last);
    await tester.pumpAndSettle();
    expect(controllers.data().mainCrops, ['Abaca']);

    await tester.tap(
      find.descendant(
        of: cropsField,
        matching: find.byType(DropdownButtonFormField<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ampalaya Fruit').last);
    await tester.pumpAndSettle();
    expect(controllers.data().mainCrops, ['Abaca', 'Ampalaya Fruit']);
    expect(find.byType(InputChip), findsNWidgets(2));
    tester.widgetList<InputChip>(find.byType(InputChip)).first.onDeleted!();
    await tester.pump();
    expect(controllers.data().mainCrops, ['Ampalaya Fruit']);
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
