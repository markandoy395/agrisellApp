part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryEvidence on SupabaseRiderDeliveryRepository {
  SupabaseRiderEvidenceUploader get _evidenceUploader =>
      SupabaseRiderEvidenceUploader(_dataSource);

  Future<String> _remoteProofReference({
    required String reference,
    required String deliveryId,
    required DeliveryProofStage stage,
    required DeliveryProofType type,
  }) async {
    return _evidenceUploader.resolve(
      reference: reference,
      deliveryId: deliveryId,
      stage: stage,
      type: type,
    );
  }

  Future<void> _removeLocalProof(String reference) =>
      _evidenceUploader.removeLocal(reference);
}
