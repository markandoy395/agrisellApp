import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_capacity_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'rider must enter a positive capacity no greater than the server ceiling',
    (tester) async {
      double? saved;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RiderCapacityEditor(
              vehicle: const RiderVehicle(
                vehicleId: 'rider-a',
                riderId: 'rider-a',
                vehicleType: 'motorcycle',
                vehicleModel: '',
                vehicleColor: '',
                plateNumber: 'ABC123',
                capacityKg: 0,
                maximumCapacityKg: 30,
              ),
              onSave: (value) async => saved = value,
            ),
          ),
        ),
      );
      final input = find.byKey(const ValueKey('rider-capacity-field'));
      final save = find.byKey(const ValueKey('rider-capacity-save'));
      expect(tester.widget<TextField>(input).controller?.text, isEmpty);
      for (final value in ['', '0', '-1', 'NaN', '31']) {
        await tester.enterText(input, value);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(saved, isNull);
      }
      await tester.enterText(input, '20');
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved, 20);
      expect(tester.takeException(), isNull);
    },
  );
}
