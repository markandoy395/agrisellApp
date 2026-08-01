import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/payments/domain/farmer_gcash_details.dart';

abstract interface class CheckoutPaymentRepository {
  Future<List<FarmerGcashDetails>> loadGcashDetails(Iterable<int> farmIds);
}

class SupabaseCheckoutPaymentRepository implements CheckoutPaymentRepository {
  const SupabaseCheckoutPaymentRepository();

  @override
  Future<List<FarmerGcashDetails>> loadGcashDetails(
    Iterable<int> farmIds,
  ) async {
    final ids = farmIds.where((id) => id > 0).toSet().toList(growable: false);
    if (ids.isEmpty || !AgrisellSupabase.isInitialized) return const [];

    try {
      final response = await AgrisellSupabase.client.rpc<List<dynamic>>(
        'checkout_gcash_details',
        params: {'farm_ids': ids},
      );
      return response
          .whereType<Map<String, dynamic>>()
          .map((row) => FarmerGcashDetails.fromJson(row))
          .where((details) => details.isComplete)
          .toList(growable: false);
    } on PostgrestException catch (error) {
      throw CheckoutPaymentException(error.message);
    }
  }
}

class CheckoutPaymentException implements Exception {
  const CheckoutPaymentException(this.message);

  final String message;
}
