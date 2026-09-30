import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_verification_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

class SupabaseRiderVerificationRepository
    implements RiderVerificationRepository {
  SupabaseRiderVerificationRepository({SupabaseClient? client})
    : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get _resolvedClient =>
      _client ??
      (AgrisellSupabase.isInitialized ? AgrisellSupabase.client : null);

  static RiderVerificationDetails? _mockDetails;

  @visibleForTesting
  static void setMockDetailsForTesting(RiderVerificationDetails? details) {
    _mockDetails = details;
  }

  @override
  Future<RiderVerificationDetails> getVerificationDetails({
    String? reference,
  }) async {
    if (_mockDetails != null) return _mockDetails!;

    final client = _resolvedClient;
    if (client != null) {
      try {
        final response = await client.rpc<Object?>(
          'current_rider_verification_details',
        );
        if (response is Map) {
          final map = Map<String, Object?>.from(response);
          if (map['found'] == true) {
            return RiderVerificationDetails.fromJson(
              map,
              fallbackReference: reference,
            );
          }
        }
      } catch (_) {
        // Fall back to local/in-memory profile if RPC fails or user is offline
      }
    }

    return _fallbackDetails(reference);
  }

  RiderVerificationDetails _fallbackDetails(String? reference) {
    final profile = RiderRegistrationService.instance.currentProfile;
    final docs = RiderRegistrationService.instance.currentDocuments;

    final docItems = docs
        .map(
          (doc) => RiderVerificationDocumentItem(
            documentId: doc.documentId,
            documentType: doc.documentType,
            documentNumber: doc.documentNumber,
            verificationStatus: doc.verificationStatus,
            rejectionReason: doc.rejectionReason,
            updatedAt: doc.updatedAt,
          ),
        )
        .toList();

    return RiderVerificationDetails(
      reference: reference ?? profile?.id ?? '',
      verificationStatus:
          profile?.verificationStatus ?? RiderVerificationStatus.pending,
      documents: List.unmodifiable(docItems),
    );
  }
}
