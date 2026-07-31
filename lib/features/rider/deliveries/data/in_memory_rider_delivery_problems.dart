part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryProblems on InMemoryRiderDeliveryRepository {
  Future<RiderDeliveryProblemReport> _reportDeliveryProblem(
    RiderDeliveryProblemReport report,
  ) async {
    final existing = _deliveryProblems[report.id];
    if (existing != null) return existing;
    final request = _requestFor(report.deliveryId);
    if (!request.isAssignedTo(report.riderId) || request.stage.isTerminal) {
      throw const DeliveryDomainException.unauthorized();
    }
    if (!report.location.isValid || report.notes.trim().isEmpty) {
      throw const DeliveryTransitionException(
        'Problem details and a current location are required.',
      );
    }
    if (report.photoReferences.any(_isPublicReportReference)) {
      throw const DeliveryTransitionException(
        'Problem photos must use protected storage.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    _deliveryProblems[report.id] = report;
    return report;
  }

  Future<RiderDeliveryProblemReport?> _updateDeliveryProblemStatus({
    required String riderId,
    required String reportId,
    required RiderDeliveryProblemStatus status,
  }) async {
    final report = _deliveryProblems[reportId];
    if (report == null || report.riderId != riderId) return null;
    final updated = report.copyWith(status: status);
    _deliveryProblems[reportId] = updated;
    return updated;
  }
}

bool _isPublicReportReference(String value) {
  final normalized = value.trim().toLowerCase();
  return !normalized.startsWith('protected://') &&
      !normalized.startsWith('local-secure://');
}
