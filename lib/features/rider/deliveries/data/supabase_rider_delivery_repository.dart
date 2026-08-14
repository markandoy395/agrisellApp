part of 'rider_delivery_repository.dart';

class SupabaseRiderDeliveryRepository implements RiderDeliveryRepository {
  SupabaseRiderDeliveryRepository(this._dataSource);

  final SupabaseDeliveryDataSource _dataSource;
  final Map<String, String> _pendingPickupRemoteReferences = {};

  @override
  Future<List<DeliveryRequest>> fetchRequests({
    required String riderId,
    RiderDeliverySearch? search,
  }) => _fetchRequests(riderId);

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) =>
      _fetchNearbyRequests(query);

  @override
  Stream<void> watchRequestChanges({required String riderId}) {
    late final StreamController<void> controller;
    StreamSubscription<Object?>? deliverySubscription;
    StreamSubscription<Object?>? requestSubscription;
    controller = StreamController<void>(
      onListen: () {
        deliverySubscription = _dataSource.client
            .from('deliveries')
            .stream(primaryKey: ['delivery_id'])
            // The first stream value is the initial table snapshot, not a
            // change. The controller is already performing its initial load.
            .skip(1)
            .listen((_) => controller.add(null), onError: controller.addError);
        requestSubscription = _dataSource.client
            .from('rider_assignment_requests')
            .stream(primaryKey: ['request_id'])
            .skip(1)
            .listen((_) => controller.add(null), onError: controller.addError);
      },
      onCancel: () async {
        await deliverySubscription?.cancel();
        await requestSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  @override
  Future<DeliveryAcceptanceReceipt> acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) => _acceptDelivery(command);

  @override
  Future<DeliveryRequest> decline({
    required String requestId,
    required String riderId,
  }) => _decline(requestId: requestId, riderId: riderId);

  @override
  Future<DeliveryRequest> cancel({
    required String requestId,
    required String riderId,
    required String reason,
  }) => _cancel(requestId: requestId, riderId: riderId, reason: reason);

  @override
  Future<DeliveryRequest> advance({
    required String requestId,
    required String riderId,
    required DeliveryStage nextStage,
    DeliveryProof? proof,
  }) => _advance(
    requestId: requestId,
    riderId: riderId,
    nextStage: nextStage,
    proof: proof,
  );

  @override
  Future<DeliveryStatusSnapshot> updateDeliveryStatus(
    DeliveryStatusUpdateCommand command,
  ) => _updateStatus(command);

  @override
  Future<DeliveryStatusSnapshot?> fetchActiveDeliveryStatus(String riderId) =>
      _fetchActiveStatuses(
        riderId,
      ).then((items) => items.isEmpty ? null : items.first);

  @override
  Future<List<DeliveryStatusSnapshot>> fetchActiveDeliveryStatuses(
    String riderId,
  ) => _fetchActiveStatuses(riderId);

  @override
  Future<PickupConfiguration> fetchPickupConfiguration({
    required String deliveryId,
    required String riderId,
  }) => _pickupConfiguration(deliveryId, riderId);

  @override
  Future<PickupCompletionResult> completePickup(
    PickupCompletionCommand command,
  ) => _completePickup(command);

  @override
  Future<PickupProblemReport> reportPickupProblem(PickupProblemReport report) =>
      _reportPickupProblem(report);

  @override
  Future<DeliveryCompletionConfiguration> fetchDeliveryConfiguration({
    required String deliveryId,
    required String riderId,
  }) => _deliveryConfiguration(deliveryId, riderId);

  @override
  Future<DeliveryCompletionResult> completeDelivery(
    DeliveryCompletionCommand command,
  ) => _completeDelivery(command);

  @override
  Future<List<DeliveryCompletionRecord>> fetchCompletedDeliveries(
    String riderId,
  ) => _fetchCompleted(riderId);

  @override
  Future<DeliveryDestinationProblemReport> reportDestinationProblem(
    DeliveryDestinationProblemReport report,
  ) => _reportDestinationProblem(report);

  @override
  Future<RiderDeliveryProblemReport> reportDeliveryProblem(
    RiderDeliveryProblemReport report,
  ) => _reportDeliveryProblem(report);

  @override
  Future<RiderDeliveryProblemReport?> updateDeliveryProblemStatus({
    required String riderId,
    required String reportId,
    required RiderDeliveryProblemStatus status,
  }) => _updateDeliveryProblemStatus(
    riderId: riderId,
    reportId: reportId,
    status: status,
  );
}
