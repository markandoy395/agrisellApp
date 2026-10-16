import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';

class PickupProofStorageException implements Exception {
  const PickupProofStorageException(this.message);
  final String message;
}

class PickupProofStorage {
  PickupProofStorage({ImagePicker? picker, this.failUploads = false})
    : _picker = picker ?? ImagePicker();

  static const _maxBytes = 8 * 1024 * 1024;
  final ImagePicker _picker;
  final bool failUploads;
  String? _lastCapturedImagePath;
  // Ephemeral camera preview; proof submission still uses its protected reference.
  String? get lastCapturedImagePath => _lastCapturedImagePath;

  Future<String?> capturePhoto({
    required String deliveryId,
    required PickupConfirmationMethod method,
  }) async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
    );
    if (image == null) return null;
    final reference = await saveImage(
      deliveryId: deliveryId,
      method: method,
      image: image,
    );
    _lastCapturedImagePath = image.path;
    return reference;
  }

  Future<String> saveImage({
    required String deliveryId,
    required PickupConfirmationMethod method,
    required XFile image,
  }) async {
    if (failUploads) {
      throw const PickupProofStorageException('Proof upload failed.');
    }
    final bytes = await image.length();
    if (bytes == 0 || bytes > _maxBytes) {
      throw const PickupProofStorageException(
        'Pickup images must be under 8 MB.',
      );
    }
    final extension = image.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png', 'webp'}.contains(extension)) {
      throw const PickupProofStorageException('Use a JPG, PNG, or WEBP photo.');
    }
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      try {
        return await SupabaseDeliveryDataSource(
          AgrisellSupabase.client,
        ).uploadDeliveryProof(
          deliveryId: deliveryId,
          stage: DeliveryProofStage.pickup,
          type: method == PickupConfirmationMethod.farmerSignature
              ? DeliveryProofType.riderSignature
              : DeliveryProofType.productPhoto,
          bytes: await image.readAsBytes(),
          extension: extension,
          contentType: _pickupContentType(extension),
        );
      } on DeliveryDataException catch (error) {
        if (error.type != DeliveryDataFailureType.offline &&
            error.type != DeliveryDataFailureType.timeout) {
          throw PickupProofStorageException(error.message);
        }
      }
    }
    final directory = await getApplicationDocumentsDirectory();
    final id = '${method.name}-${DateTime.now().microsecondsSinceEpoch}';
    final fileName = 'pickup-$id.$extension';
    await File(image.path).copy('${directory.path}/$fileName');
    return 'local-secure://pickup/$deliveryId/$fileName';
  }

  Future<String> saveAttestation({
    required String deliveryId,
    required PickupConfirmationMethod method,
  }) async {
    if (method.requiresImage) {
      throw const PickupProofStorageException(
        'Capture a photo for this pickup proof.',
      );
    }
    if (failUploads) {
      throw const PickupProofStorageException('Proof upload failed.');
    }
    final id = '${method.name}-${DateTime.now().microsecondsSinceEpoch}';
    return 'protected://pickup/$deliveryId/$id';
  }

  Future<File?> resolveLocalPhoto(String reference) async {
    final uri = Uri.tryParse(reference);
    if (uri == null ||
        uri.scheme != 'local-secure' ||
        uri.host != 'pickup' ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.pathSegments.length != 2) {
      return null;
    }
    final name = uri.pathSegments.last;
    if (!RegExp(
      r'^pickup-(productPhoto|packagePhoto|farmerSignature)-[0-9]+\.(jpg|jpeg|png|webp)$',
    ).hasMatch(name))
      return null;
    final root = await getApplicationDocumentsDirectory();
    final file = File('${root.path}/$name');
    if (!await file.exists()) return null;
    final length = await file.length();
    return length > 0 && length <= _maxBytes ? file : null;
  }
}

String _pickupContentType(String extension) => switch (extension) {
  'png' => 'image/png',
  'webp' => 'image/webp',
  _ => 'image/jpeg',
};
