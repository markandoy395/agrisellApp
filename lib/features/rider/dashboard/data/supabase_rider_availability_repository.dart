import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';

class SupabaseRiderAvailabilityRepository
    implements RiderAvailabilityRepository, RiderDataSourceMetadata {
  SupabaseRiderAvailabilityRepository({RiderRepository? repository})
    : _repository = repository ?? RiderRepositoryImpl();

  final RiderRepository _repository;

  @override
  RiderDataOrigin get dataOrigin => RiderDataOrigin.backend;

  @override
  Future<RiderAvailability> loadAvailability(String riderId) async {
    final rider = await _repository.getCurrentRider();
    if (rider == null || rider.riderId != riderId) {
      throw StateError('The authenticated Rider profile is unavailable.');
    }
    if (rider.availabilityStatus == RiderDatabaseAvailability.offline) {
      return RiderAvailability.offline;
    }
    if (rider.availabilityStatus == RiderDatabaseAvailability.online) {
      return RiderAvailability.onlineAvailable;
    }
    return switch (rider.deliveryStatus) {
      RiderDeliveryProgress.assigned => RiderAvailability.deliveryReserved,
      RiderDeliveryProgress.goingToPickup => RiderAvailability.goingToPickup,
      RiderDeliveryProgress.arrivedAtPickup =>
        RiderAvailability.waitingAtPickup,
      RiderDeliveryProgress.pickedUp => RiderAvailability.productPickedUp,
      RiderDeliveryProgress.goingToBuyer => RiderAvailability.goingToBuyer,
      RiderDeliveryProgress.arrivedAtDelivery =>
        RiderAvailability.waitingAtDeliveryLocation,
      RiderDeliveryProgress.waiting ||
      RiderDeliveryProgress.completed => RiderAvailability.onlineAvailable,
    };
  }

  @override
  Future<void> saveAvailability(
    String riderId,
    RiderAvailability availability,
  ) async {
    final current = await _repository.getCurrentRider();
    if (current == null || current.riderId != riderId) {
      throw StateError('The authenticated Rider profile is unavailable.');
    }
    final status = _databaseStatus(availability, current.deliveryStatus);
    await _repository.updateRiderOperationalStatus(
      riderId,
      availability: status.$1,
      delivery: status.$2,
    );
  }

  (RiderDatabaseAvailability, RiderDeliveryProgress) _databaseStatus(
    RiderAvailability value,
    RiderDeliveryProgress current,
  ) => switch (value) {
    RiderAvailability.offline ||
    RiderAvailability.onBreak ||
    RiderAvailability.temporarilyUnavailable ||
    RiderAvailability.emergency => (
      RiderDatabaseAvailability.offline,
      current == RiderDeliveryProgress.completed
          ? RiderDeliveryProgress.completed
          : RiderDeliveryProgress.waiting,
    ),
    RiderAvailability.onlineAvailable ||
    RiderAvailability.reviewingDeliveryRequest => (
      RiderDatabaseAvailability.online,
      current == RiderDeliveryProgress.arrivedAtDelivery ||
              current == RiderDeliveryProgress.completed
          ? RiderDeliveryProgress.completed
          : RiderDeliveryProgress.waiting,
    ),
    RiderAvailability.deliveryReserved => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.assigned,
    ),
    RiderAvailability.goingToPickup => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.goingToPickup,
    ),
    RiderAvailability.waitingAtPickup => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.arrivedAtPickup,
    ),
    RiderAvailability.productPickedUp => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.pickedUp,
    ),
    RiderAvailability.goingToBuyer => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.goingToBuyer,
    ),
    RiderAvailability.waitingAtDeliveryLocation => (
      RiderDatabaseAvailability.busy,
      RiderDeliveryProgress.arrivedAtDelivery,
    ),
  };
}
