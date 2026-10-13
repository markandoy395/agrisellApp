import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_capacity_setup_banner.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/profile/data/rider_profile_entity_mapper.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/rider_batch_fixture.dart';
import 'support/rider_dashboard_fixture.dart';
import 'support/rider_dashboard_fakes.dart';

void main() {
  test(
    'missing capacity blocks additional acceptance; setting it unlocks batching',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [
          batchRequest(id: 'a', weightKg: 1),
          batchRequest(id: 'b', weightKg: 1),
        ],
        riderStates: [batchRiderState(capacityKg: 3)],
        clock: () => batchNow,
      );
      final controller = RiderDeliveryController(repository: repository)
        ..updateProfile(batchRiderProfile())
        ..updateRequestEnvironment(
          state: RiderRequestAccessState.eligible,
          location: const RiderDeliverySearch(
            latitude: 8.48,
            longitude: 124.65,
          ),
          accuracyMeters: 5,
        );
      addTearDown(controller.dispose);
      await controller.applyAuthoritativeAvailability(
        RiderAvailability.onlineAvailable,
        loadRequests: false,
      );
      await controller.load(riderId: 'rider-a');
      expect(
        (await controller.accept(requestId: 'a', riderId: 'rider-a')).isSuccess,
        isTrue,
      );
      controller.updateProfile(_profile(null));
      expect(controller.canReceiveAdditionalDelivery, isFalse);
      expect(controller.canAcceptRequest('b'), isFalse);
      final denied = await controller.accept(
        requestId: 'b',
        riderId: 'rider-a',
      );
      expect(denied.failure, DeliveryAcceptanceFailure.capacityNotSet);
      expect(repository.activeDeliveriesFor('rider-a'), hasLength(1));
      controller.updateProfile(batchRiderProfile());
      expect(controller.canReceiveAdditionalDelivery, isTrue);
      expect(
        (await controller.accept(requestId: 'b', riderId: 'rider-a')).isSuccess,
        isTrue,
      );
      expect(repository.activeDeliveriesFor('rider-a'), hasLength(2));
    },
  );

  testWidgets(
    'legacy rider sees Home capacity prompt which disappears after saving',
    (tester) async {
      final fixture = RiderDashboardFixture(
        dashboardRepository: FakeRiderDashboardRepository(),
      );
      addTearDown(fixture.dispose);
      Future<void> pump(RiderProfile profile) => tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RiderDashboardScreen(
              profile: profile,
              deliveryController: fixture.delivery,
              availabilityController: fixture.availability,
              dashboardController: fixture.dashboard,
              riderId: 'rider-a',
              onOpenDeliveries: () {},
              onOpenMap: () {},
              onOpenMessages: () {},
              onOpenEarnings: () {},
              onOpenNotifications: () {},
              onSafetySupport: () {},
            ),
          ),
        ),
      );
      await pump(_profile(null));
      await tester.pumpAndSettle();
      expect(find.byType(RiderCapacitySetupBanner), findsOneWidget);
      expect(find.text('Set capacity'), findsOneWidget);
      expect(
        find.textContaining('Before accepting multiple orders'),
        findsOneWidget,
      );
      await pump(_profile(3));
      await tester.pumpAndSettle();
      expect(find.byType(RiderCapacitySetupBanner), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'capacity prompt fits a narrow screen with enlarged text and handles tap',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                textScaler: TextScaler.linear(1.5),
              ),
              child: SizedBox(
                width: 280,
                child: RiderCapacitySetupBanner(
                  onSetCapacity: () => opened = true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Set capacity'));
      expect(opened, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'null, zero, negative, NaN and infinity are not saved usable capacity',
    () {
      for (final value in [null, 0.0, -1.0, double.nan, double.infinity]) {
        expect(_profile(value).hasCargoCapacity, isFalse);
      }
      expect(_profile(3).hasCargoCapacity, isTrue);
    },
  );
}

RiderProfile _profile(double? capacity) => riderProfileFromEntities(
  Rider.fromJson({
    'rider_id': 'rider-a',
    'vehicle_type': 'motorcycle',
    'first_name': 'Rider',
    'last_name': 'One',
    'full_name': 'Rider One',
    'employment_status': 'active',
    'availability_status': 'busy',
    'maximum_active_deliveries': 3,
    'capacity_kg': capacity,
  }),
  const RiderVehicle(
    vehicleId: 'rider-a',
    riderId: 'rider-a',
    vehicleType: 'motorcycle',
    vehicleModel: '',
    vehicleColor: '',
    plateNumber: 'ABC123',
    capacityKg: 0,
    maximumCapacityKg: 30,
  ),
  [],
  null,
  null,
);
