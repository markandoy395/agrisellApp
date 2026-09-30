import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

class FarmerVerificationRepository {
  const FarmerVerificationRepository({
    this.customDetailsLoader,
    this.customResubmitHandler,
  });

  final Future<FarmerVerificationDetails?> Function()? customDetailsLoader;
  final Future<void> Function({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? farmName,
    String? farmAddress,
    Uint8List? profileImageBytes,
    Uint8List? farmImageBytes,
    String? notes,
  })? customResubmitHandler;

  bool get isAvailable => AgrisellSupabase.isInitialized;

  Future<FarmerVerificationDetails?> loadVerificationDetails() async {
    if (customDetailsLoader != null) {
      return customDetailsLoader!();
    }
    if (!isAvailable) return null;

    try {
      final response = await AgrisellSupabase.client.rpc<dynamic>(
        'current_farmer_verification_details',
      );
      if (response is Map<String, dynamic>) {
        return FarmerVerificationDetails.fromJson(response);
      }
      if (response is Map) {
        return FarmerVerificationDetails.fromJson(
          response.cast<String, dynamic>(),
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> resubmitVerification({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? farmName,
    String? farmAddress,
    Uint8List? profileImageBytes,
    Uint8List? farmImageBytes,
    String? notes,
  }) async {
    if (customResubmitHandler != null) {
      return customResubmitHandler!(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        farmName: farmName,
        farmAddress: farmAddress,
        profileImageBytes: profileImageBytes,
        farmImageBytes: farmImageBytes,
        notes: notes,
      );
    }
    if (!isAvailable) return;

    final client = AgrisellSupabase.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Farmer must be authenticated to resubmit verification.');
    }

    String? profileImageUrl;
    if (profileImageBytes != null) {
      profileImageUrl = await _uploadImage(
        client,
        user.id,
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        profileImageBytes,
      );
    }

    String? farmImageUrl;
    if (farmImageBytes != null) {
      farmImageUrl = await _uploadImage(
        client,
        user.id,
        'farm_${DateTime.now().millisecondsSinceEpoch}.jpg',
        farmImageBytes,
      );
    }

    await client.rpc<void>(
      'farmer_resubmit_verification',
      params: {
        'p_first_name': firstName,
        'p_last_name': lastName,
        'p_phone_number': phoneNumber,
        'p_farm_name': farmName,
        'p_farm_address': farmAddress,
        'p_profile_image_url': profileImageUrl,
        'p_farm_image_url': farmImageUrl,
        'p_document_urls': farmImageUrl != null ? [farmImageUrl] : null,
        'p_notes': notes,
      },
    );
  }

  Future<String> _uploadImage(
    SupabaseClient client,
    String authUserId,
    String filename,
    Uint8List bytes,
  ) async {
    const bucket = 'farmer-media';
    final path = '$authUserId/$filename';
    await client.storage.from(bucket).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        upsert: true,
        contentType: 'image/jpeg',
      ),
    );
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
