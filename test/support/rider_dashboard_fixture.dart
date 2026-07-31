import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_dashboard_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';

import 'rider_availability_fakes.dart';
import 'rider_dashboard_fakes.dart';
import 'rider_test_models.dart';

class RiderDashboardFixture {
  RiderDashboardFixture._({
    required this.delivery,
    required this.location,
    required this.connectivity,
    required this.availabilityRepository,
    required this.availability,
    required this.dashboard,
  });

  final RiderDeliveryController delivery;
  final FakeRiderLocationController location;
  final FakeRiderConnectivityService connectivity;
  final FakeRiderAvailabilityRepository availabilityRepository;
  final RiderAvailabilityController availability;
  final RiderDashboardController dashboard;

  factory RiderDashboardFixture({
    required FakeRiderDashboardRepository dashboardRepository,
    Iterable<DeliveryRequest>? requests,
    Duration staleAfter = const Duration(minutes: 2),
  }) {
    final delivery = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(requests: requests),
    )..updateProfile(verifiedRiderProfile());
    final location = FakeRiderLocationController();
    final connectivity = FakeRiderConnectivityService();
    final availabilityRepository = FakeRiderAvailabilityRepository();
    final availability = RiderAvailabilityController(
      deliveryController: delivery,
      locationController: location,
      repository: availabilityRepository,
      connectivityService: connectivity,
      reconnectCheckInterval: Duration.zero,
    );
    return RiderDashboardFixture._(
      delivery: delivery,
      location: location,
      connectivity: connectivity,
      availabilityRepository: availabilityRepository,
      availability: availability,
      dashboard: RiderDashboardController(
        repository: dashboardRepository,
        cache: FakeRiderDashboardCache(),
        staleAfter: staleAfter,
      ),
    );
  }

  void dispose() {
    dashboard.dispose();
    availability.dispose();
    connectivity.dispose();
    location.dispose();
    delivery.dispose();
  }
}
