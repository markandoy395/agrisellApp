part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryIncidents on SupabaseRiderDeliveryRepository {
  SupabaseRiderIncidentStore get _incidentStore =>
      SupabaseRiderIncidentStore(client: _dataSource.client);

  Future<PickupProblemReport> _reportPickupProblem(
    PickupProblemReport report,
  ) async {
    final attachments = await _incidentAttachments(
      report.photoReferences,
      report.deliveryId,
      DeliveryProofStage.pickup,
    );
    await _incidentStore.submit(
      reportId: report.id,
      riderId: report.riderId,
      deliveryId: report.deliveryId,
      reportType: 'pickup_problem',
      category: report.kind.name,
      description: report.notes,
      latitude: report.location.latitude,
      longitude: report.location.longitude,
      accuracyMeters: report.location.accuracyMeters,
      attachments: attachments,
      reportedAt: report.reportedAt,
    );
    await _cleanupIncidentAttachments(report.photoReferences);
    return report;
  }

  Future<DeliveryDestinationProblemReport> _reportDestinationProblem(
    DeliveryDestinationProblemReport report,
  ) async {
    await _incidentStore.submit(
      reportId: report.id,
      riderId: report.riderId,
      deliveryId: report.deliveryId,
      reportType: 'destination_problem',
      category: 'destination_problem',
      description: report.notes,
      latitude: report.location.latitude,
      longitude: report.location.longitude,
      accuracyMeters: report.location.accuracyMeters,
      reportedAt: report.reportedAt,
    );
    return report;
  }

  Future<RiderDeliveryProblemReport> _reportDeliveryProblem(
    RiderDeliveryProblemReport report,
  ) async {
    final attachments = await _incidentAttachments(
      report.photoReferences,
      report.deliveryId,
      DeliveryProofStage.delivery,
    );
    final row = await _incidentStore.submit(
      reportId: report.id,
      riderId: report.riderId,
      deliveryId: report.deliveryId,
      reportType: 'delivery_problem',
      category: report.kind.name,
      description: report.notes,
      latitude: report.location.latitude,
      longitude: report.location.longitude,
      accuracyMeters: report.location.accuracyMeters,
      attachments: attachments,
      reportedAt: report.createdAt,
    );
    await _cleanupIncidentAttachments(report.photoReferences);
    return report.copyWith(
      status: RiderDeliveryProblemStatus.values.byName('${row['status']}'),
    );
  }

  Future<RiderDeliveryProblemReport?> _updateDeliveryProblemStatus({
    required String riderId,
    required String reportId,
    required RiderDeliveryProblemStatus status,
  }) async {
    final row = await _incidentStore.updateStatus(
      reportId: reportId,
      riderId: riderId,
      status: status.name,
    );
    if (row == null) return null;
    return RiderDeliveryProblemReport(
      id: '${row['report_id']}',
      deliveryId: '${row['delivery_id']}',
      riderId: '${row['rider_id']}',
      kind: RiderDeliveryProblemKind.values.byName('${row['category']}'),
      location: DeliveryStatusLocation(
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
        accuracyMeters: (row['accuracy_meters'] as num).toDouble(),
        timestamp: DateTime.parse('${row['reported_at']}'),
      ),
      createdAt: DateTime.parse('${row['reported_at']}'),
      notes: '${row['description']}',
      photoReferences: (row['attachments'] as List? ?? const []).cast<String>(),
      status: RiderDeliveryProblemStatus.values.byName('${row['status']}'),
    );
  }

  Future<List<String>> _incidentAttachments(
    List<String> references,
    String deliveryId,
    DeliveryProofStage stage,
  ) => _evidenceUploader.resolveAll(
    references: references,
    deliveryId: deliveryId,
    stage: stage,
    type: stage == DeliveryProofStage.pickup
        ? DeliveryProofType.productPhoto
        : DeliveryProofType.deliveryPhoto,
  );

  Future<void> _cleanupIncidentAttachments(List<String> references) async {
    for (final reference in references) {
      await _removeLocalProof(reference);
    }
  }
}
