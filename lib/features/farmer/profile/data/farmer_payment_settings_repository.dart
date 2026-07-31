import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/buyer/cart/domain/farmer_gcash_details.dart';

class FarmerPaymentSettingsRepository {
  const FarmerPaymentSettingsRepository();

  Future<FarmerGcashDetails?> load() async {
    if (!AgrisellSupabase.isInitialized) return null;
    try {
      final response = await AgrisellSupabase.client.rpc<Object?>(
        'current_farmer_gcash_details',
      );
      if (response is! Map || response.isEmpty) return null;
      return FarmerGcashDetails.fromJson(Map<String, Object?>.from(response));
    } on PostgrestException catch (error) {
      throw FarmerPaymentSettingsException(error.message);
    }
  }

  Future<void> save({
    required String accountName,
    required String accountNumber,
  }) async {
    if (!AgrisellSupabase.isInitialized) {
      throw const FarmerPaymentSettingsException(
        'Connect your account before saving GCash details.',
      );
    }
    try {
      await AgrisellSupabase.client.rpc<void>(
        'save_current_farmer_gcash_details',
        params: {
          'account_name': accountName.trim(),
          'account_number': accountNumber.trim(),
        },
      );
    } on PostgrestException catch (error) {
      throw FarmerPaymentSettingsException(error.message);
    }
  }
}

class FarmerPaymentSettingsException implements Exception {
  const FarmerPaymentSettingsException(this.message);

  final String message;
}
