import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import '../domain/delivery_completion.dart';
import '../domain/delivery_proof.dart';

class DeliveryProofStorageException implements Exception {
  const DeliveryProofStorageException(this.message);
  final String message;
}

class DeliveryProofStorage {
  DeliveryProofStorage({ImagePicker? picker, this.failUploads = false})
    : _picker = picker ?? ImagePicker();

  static const _maxBytes = 8 * 1024 * 1024;
  final ImagePicker _picker;
  final bool failUploads;
  final Random _random = Random.secure();

  Future<String?> capturePhoto({required String deliveryId}) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
    );
    if (image == null) return null;
    final extension = image.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      throw const DeliveryProofStorageException(
        'Use a JPG, PNG, or WEBP delivery photo.',
      );
    }
    return saveBytes(
      deliveryId: deliveryId,
      method: DeliveryConfirmationMethod.handoverPhoto,
      bytes: await image.readAsBytes(),
      extension: extension,
    );
  }

  Future<String> saveBytes({
    required String deliveryId,
    required DeliveryConfirmationMethod method,
    required Uint8List bytes,
    String extension = 'bin',
  }) async {
    if (failUploads) {
      throw const DeliveryProofStorageException(
        'Delivery proof could not be stored securely.',
      );
    }
    if (bytes.isEmpty || bytes.length > _maxBytes) {
      throw const DeliveryProofStorageException(
        'Delivery proof must be between 1 byte and 8 MB.',
      );
    }
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      try {
        return await SupabaseDeliveryDataSource(
          AgrisellSupabase.client,
        ).uploadDeliveryProof(
          deliveryId: deliveryId,
          stage: DeliveryProofStage.delivery,
          type: method == DeliveryConfirmationMethod.buyerSignature
              ? DeliveryProofType.buyerSignature
              : DeliveryProofType.deliveryPhoto,
          bytes: bytes,
          extension: extension,
          contentType: _contentType(extension),
        );
      } on DeliveryDataException catch (error) {
        if (error.type != DeliveryDataFailureType.offline &&
            error.type != DeliveryDataFailureType.timeout) {
          throw DeliveryProofStorageException(error.message);
        }
      }
    }
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/delivery_proofs');
    if (!await directory.exists()) await directory.create(recursive: true);
    final id = _opaqueId();
    await File(
      '${directory.path}/$id.$extension',
    ).writeAsBytes(bytes, flush: true);
    return 'local-secure://delivery/$deliveryId/${method.name}/'
        '$id.$extension';
  }

  Future<String> saveAttestation({
    required String deliveryId,
    required DeliveryConfirmationMethod method,
  }) async {
    if (failUploads) {
      throw const DeliveryProofStorageException(
        'Delivery proof could not be stored securely.',
      );
    }
    return 'protected://delivery/$deliveryId/${method.name}/${_opaqueId()}';
  }

  String _opaqueId() => List<int>.generate(
    16,
    (_) => _random.nextInt(256),
  ).map((value) => value.toRadixString(16).padLeft(2, '0')).join();
}

String _contentType(String extension) => switch (extension.toLowerCase()) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  'heic' => 'image/heic',
  _ => 'image/jpeg',
};
