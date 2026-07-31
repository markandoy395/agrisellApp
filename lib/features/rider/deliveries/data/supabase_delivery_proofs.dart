part of 'supabase_delivery_data_source.dart';

extension SupabaseDeliveryProofs on SupabaseDeliveryDataSource {
  Future<String> uploadDeliveryProof({
    required String deliveryId,
    required DeliveryProofStage stage,
    required DeliveryProofType type,
    required Uint8List bytes,
    required String extension,
    required String contentType,
  }) => _guard(() async {
    if (bytes.isEmpty) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.validation,
        'The selected proof is empty.',
      );
    }
    final authId = client.auth.currentUser?.id;
    if (authId == null) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.authentication,
        'Authentication is required to upload delivery proof.',
      );
    }
    final cleanExtension = extension.toLowerCase();
    final path =
        '$authId/$deliveryId/${stage.name}/'
        '${type.name}_${DateTime.now().microsecondsSinceEpoch}.$cleanExtension';
    await client.storage
        .from(SupabaseDeliveryDataSource.proofBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            cacheControl: '3600',
            contentType: contentType,
            upsert: false,
          ),
        );
    return path;
  });

  Future<DeliveryProof> saveDeliveryProof(DeliveryProof proof) =>
      _guard(() async {
        final filePath = proof.filePath ?? proof.secureReference;
        final value = await client.rpc<Object?>(
          'save_current_rider_delivery_proof',
          params: {
            'p_delivery_id': proof.deliveryId,
            'p_stage': proof.proofStage.name,
            'p_type': proof.type.databaseValue,
            'p_file_path': filePath,
            'p_remarks': proof.remarks,
            'p_latitude': proof.latitude,
            'p_longitude': proof.longitude,
          },
        );
        return DeliveryProof.fromJson(_map(value));
      });

  Future<List<DeliveryProof>> getDeliveryProofs(String deliveryId) =>
      _guard(() async {
        final rows = await client
            .from('delivery_proofs')
            .select(
              'proof_id,delivery_id,proof_stage,proof_type,file_path,remarks,'
              'latitude,longitude,confirmed_at,created_at,updated_at',
            )
            .eq('delivery_id', deliveryId)
            .order('created_at');
        return rows
            .map((row) => DeliveryProof.fromJson(_map(row)))
            .toList(growable: false);
      });

  Future<DeliveryProof> replaceDeliveryProof(
    DeliveryProof proof, {
    String? proofId,
  }) => saveDeliveryProof(proof);

  Future<DeliveryProof> saveConfirmationCode({
    required String deliveryId,
    required DeliveryProofStage stage,
    required String code,
    String? remarks,
  }) => _guard(() async {
    final value = await client.rpc<Object?>(
      'save_current_rider_confirmation_code',
      params: {
        'p_delivery_id': deliveryId,
        'p_stage': stage.name,
        'p_code': code,
        'p_remarks': remarks,
      },
    );
    return DeliveryProof.fromJson(_map(value));
  });

  Future<String> createProofSignedUrl(
    String filePath, {
    Duration expiresIn = const Duration(minutes: 5),
  }) => _guard(
    () => client.storage
        .from(SupabaseDeliveryDataSource.proofBucket)
        .createSignedUrl(filePath, expiresIn.inSeconds),
  );
}
