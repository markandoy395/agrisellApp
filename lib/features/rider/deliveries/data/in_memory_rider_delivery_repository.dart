part of 'rider_delivery_repository.dart';

/// Empty transactional adapter for tests and backend-independent state checks.
/// A deployed app must replace this process-local store with a database-backed
/// implementation of [RiderDeliveryRepository].
class InMemoryRiderDeliveryRepository implements RiderDeliveryRepository {
  InMemoryRiderDeliveryRepository({
    Iterable<DeliveryRequest>? requests,
    Iterable<RiderAcceptanceState> riderStates = const [],
    Map<String, PickupConfiguration> pickupConfigurations = const {},
    Map<String, DeliveryCompletionConfiguration> deliveryConfigurations =
        const {},
    DateTime Function()? clock,
    this._beforeAcceptanceCommit,
  }) : _requests = {
         for (final request in requests ?? const <DeliveryRequest>[])
           request.id: request,
       },
       _riderStates = {for (final state in riderStates) state.riderId: state},
       _pickupConfigurations = Map.unmodifiable(pickupConfigurations),
       _deliveryConfigurations = Map.unmodifiable(deliveryConfigurations),
       _clock = clock ?? DateTime.now;

  final Map<String, DeliveryRequest> _requests;
  final Map<String, RiderAcceptanceState> _riderStates;
  final Map<String, Map<String, ActiveDeliveryRecord>> _activeDeliveries = {};
  final Map<String, ActiveDeliveryRecord> _activeByRequest = {};
  final Map<String, _IdempotencyRecord> _idempotencyReceipts = {};
  final Map<String, PickupConfiguration> _pickupConfigurations;
  final Map<String, DeliveryCompletionConfiguration> _deliveryConfigurations;
  final Map<String, PickupProblemReport> _pickupProblems = {};
  final Map<String, PickupCompletionResult> _pickupCompletions = {};
  final Map<String, int> _pickupCodeAttempts = {};
  final Set<String> _usedPickupCodes = {};
  final Set<String> _usedPickupQrPayloads = {};
  final Map<String, PickupCompletionRecord> _pickupRecords = {};
  final Map<String, DateTime> _pickupWaitingStartedAt = {};
  final Map<String, DateTime> _deliveryWaitingStartedAt = {};
  final Set<String> _buyerArrivalNotifications = {};
  final Map<String, int> _deliveryCodeAttempts = {};
  final Set<String> _usedDeliveryCodes = {};
  final Set<String> _usedDeliveryQrPayloads = {};
  final Map<String, DeliveryCompletionResult> _deliveryCompletions = {};
  final Map<String, DeliveryCompletionRecord> _completionHistory = {};
  final Map<String, CashCollectionRecord> _cashCollectionIssues = {};
  final Map<String, DeliveryDestinationProblemReport> _destinationProblems = {};
  final Map<String, RiderDeliveryProblemReport> _deliveryProblems = {};
  final Map<String, DeliveryStatusSnapshot> _statusSnapshots = {};
  final Map<String, DeliveryStatusSnapshot> _statusIdempotency = {};
  final DateTime Function() _clock;
  final FutureOr<void> Function()? _beforeAcceptanceCommit;
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Future<void> _transactionTail = Future<void>.value();
  int _assignmentSequence = 0;

  @override
  Future<DeliveryAcceptanceReceipt> acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) => _acceptDelivery(command);

  @override
  Future<List<DeliveryRequest>> fetchRequests({
    required String riderId,
    RiderDeliverySearch? search,
  }) async => _requests.values
      .where((request) => request.isVisibleTo(riderId))
      .toList(growable: false);

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) =>
      _fetchNearbyRequests(query);

  @override
  Stream<void> watchRequestChanges({required String riderId}) =>
      _changes.stream;

  @override
  Future<DeliveryRequest> decline({
    required String requestId,
    required String riderId,
  }) async => _replace(requestId, _requestFor(requestId).declineFor(riderId));

  @override
  Future<DeliveryRequest> cancel({
    required String requestId,
    required String riderId,
    required String reason,
  }) async =>
      _replace(requestId, _requestFor(requestId).cancelFor(riderId, reason));

  @override
  Future<DeliveryRequest> advance({
    required String requestId,
    required String riderId,
    required DeliveryStage nextStage,
    DeliveryProof? proof,
  }) async {
    final request = _requestFor(requestId);
    if (nextStage == DeliveryStage.delivered ||
        nextStage == DeliveryStage.completed) {
      throw const DeliveryTransitionException(
        'Use the configured delivery confirmation workflow.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    if (!request.isAssignedTo(riderId)) {
      throw const DeliveryTransitionException(
        'This delivery is not assigned to this rider.',
        code: DeliveryErrorCode.unauthorizedOperation,
      );
    }
    return _replace(requestId, request.advanceTo(nextStage, proof: proof));
  }

  @override
  Future<DeliveryStatusSnapshot> updateDeliveryStatus(
    DeliveryStatusUpdateCommand command,
  ) => _updateDeliveryStatus(command);

  @override
  Future<DeliveryStatusSnapshot?> fetchActiveDeliveryStatus(String riderId) =>
      _fetchActiveDeliveryStatus(riderId);

  @override
  Future<List<DeliveryStatusSnapshot>> fetchActiveDeliveryStatuses(
    String riderId,
  ) => _fetchActiveDeliveryStatuses(riderId);

  @override
  Future<PickupConfiguration> fetchPickupConfiguration({
    required String deliveryId,
    required String riderId,
  }) => _fetchPickupConfiguration(deliveryId: deliveryId, riderId: riderId);

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
  }) => _fetchDeliveryConfiguration(deliveryId: deliveryId, riderId: riderId);

  @override
  Future<DeliveryCompletionResult> completeDelivery(
    DeliveryCompletionCommand command,
  ) => _completeDelivery(command);

  @override
  Future<List<DeliveryCompletionRecord>> fetchCompletedDeliveries(
    String riderId,
  ) => _fetchCompletedDeliveries(riderId);

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
