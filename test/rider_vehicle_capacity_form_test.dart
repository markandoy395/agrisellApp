import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_cargo_capacity_policy.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_vehicle_edit_dialog.dart';

void main() {
  const ceilings = {
    'bicycle': 25.0,
    'eBike': 25.0,
    'motorcycle': 30.0,
    'tricycle': 200.0,
    'car': 200.0,
    'van': 1000.0,
    'truck': 1500.0,
  };
  for (final entry in ceilings.entries) {
    test(
      '${entry.key} rejects excess and accepts exactly its cargo ceiling',
      () {
        expect(RiderCargoCapacityPolicy.maximum(entry.key), entry.value);
        expect(
          RiderCargoCapacityPolicy.error('${entry.value}', entry.key),
          isNull,
        );
        expect(
          RiderCargoCapacityPolicy.error('${entry.value + 0.001}', entry.key),
          isNotNull,
        );
        for (final invalid in ['', '0', '-1', 'NaN', 'Infinity', 'abc']) {
          expect(RiderCargoCapacityPolicy.error(invalid, entry.key), isNotNull);
        }
      },
    );
    testWidgets('${entry.key} edit form stays open for excess kg', (
      tester,
    ) async {
      List<String>? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => saved = await showDialog<List<String>>(
                  context: context,
                  builder: (_) => RiderVehicleEditDialog(
                    vehicle: RiderVehicle(
                      vehicleId: 'v',
                      riderId: 'r',
                      vehicleType: entry.key,
                      vehicleModel: 'Model',
                      vehicleColor: 'Green',
                      plateNumber: 'ABC123',
                      registrationNumber: 'REG1',
                      capacityKg: 1,
                    ),
                  ),
                ),
                child: const Text('Edit'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final capacity = find.byKey(const ValueKey('vehicle-edit-5'));
      await tester.enterText(capacity, '${entry.value + 1}');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved, isNull);
      expect(find.byType(RiderVehicleEditDialog), findsOneWidget);
      expect(find.textContaining('allows at most'), findsOneWidget);
      await tester.enterText(capacity, '${entry.value}');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(saved?[5], '${entry.value}');
      expect(find.byType(RiderVehicleEditDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  test(
    'lower server ceiling wins and a higher server value cannot raise the app ceiling',
    () {
      expect(
        RiderCargoCapacityPolicy.maximum('motorcycle', serverMaximum: 20),
        20,
      );
      expect(
        RiderCargoCapacityPolicy.maximum('motorcycle', serverMaximum: 100),
        30,
      );
      expect(
        RiderCargoCapacityPolicy.error('21', 'motorcycle', serverMaximum: 20),
        isNotNull,
      );
      expect(RiderCargoCapacityPolicy.maximum('other'), isNull);
    },
  );
}
