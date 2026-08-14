import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';

class SupabaseRiderEvidenceUploader {
  const SupabaseRiderEvidenceUploader(this._dataSource);

  final SupabaseDeliveryDataSource _dataSource;

  Future<String> resolve({
    required String reference,
    required String deliveryId,
    required DeliveryProofStage stage,
    required DeliveryProofType type,
  }) async {
    if (!reference.startsWith('local-secure://')) return reference;
    final fileName = _fileName(reference);
    final root = await getApplicationDocumentsDirectory();
    final file = File('${root.path}/delivery_proofs/$fileName');
    if (!await file.exists()) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.storage,
        'The offline Rider evidence is no longer available.',
      );
    }
    final extension = fileName.split('.').last.toLowerCase();
    return _dataSource.uploadDeliveryProof(
      deliveryId: deliveryId,
      stage: stage,
      type: type,
      bytes: await file.readAsBytes(),
      extension: extension,
      contentType: _contentType(extension),
    );
  }

  Future<List<String>> resolveAll({
    required List<String> references,
    required String deliveryId,
    required DeliveryProofStage stage,
    required DeliveryProofType type,
  }) => Future.wait([
    for (final reference in references)
      resolve(
        reference: reference,
        deliveryId: deliveryId,
        stage: stage,
        type: type,
      ),
  ]);

  Future<void> removeLocal(String reference) async {
    if (!reference.startsWith('local-secure://')) return;
    final fileName = _fileName(reference);
    final root = await getApplicationDocumentsDirectory();
    final file = File('${root.path}/delivery_proofs/$fileName');
    if (await file.exists()) await file.delete();
  }

  String _fileName(String reference) {
    final fileName = Uri.tryParse(reference)?.pathSegments.lastOrNull ?? '';
    if (fileName.isEmpty ||
        fileName.contains('..') ||
        !RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(fileName)) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.storage,
        'The offline Rider evidence reference is invalid.',
      );
    }
    return fileName;
  }
}

String _contentType(String extension) => switch (extension) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  _ => 'image/jpeg',
};
