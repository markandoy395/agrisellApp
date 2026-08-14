import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';

abstract interface class FarmerRiderSelectionRepository {
  Future<FarmerRiderSelectionData> loadEligibleRiders(String orderId);

  Future<List<FarmerRiderRequest>> loadCurrentRequests();

  Stream<List<FarmerRiderRequest>> watchCurrentRequests();

  Future<FarmerRiderRequest> requestRider({
    required FarmerRiderDeliveryDetails delivery,
    required FarmerRiderCandidate rider,
  });

  Future<FarmerRiderRequest> cancelRequest(String requestId);
}

class FarmerRiderSelectionException implements Exception {
  const FarmerRiderSelectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UnavailableFarmerRiderSelectionRepository
    implements FarmerRiderSelectionRepository {
  const UnavailableFarmerRiderSelectionRepository();

  static const _message =
      'Connect to AgriSell before loading or requesting a rider.';

  @override
  Future<FarmerRiderSelectionData> loadEligibleRiders(String orderId) =>
      Future.error(const FarmerRiderSelectionException(_message));

  @override
  Future<List<FarmerRiderRequest>> loadCurrentRequests() async => const [];

  @override
  Stream<List<FarmerRiderRequest>> watchCurrentRequests() =>
      Stream.value(const []);

  @override
  Future<FarmerRiderRequest> requestRider({
    required FarmerRiderDeliveryDetails delivery,
    required FarmerRiderCandidate rider,
  }) => Future.error(const FarmerRiderSelectionException(_message));

  @override
  Future<FarmerRiderRequest> cancelRequest(String requestId) =>
      Future.error(const FarmerRiderSelectionException(_message));
}
