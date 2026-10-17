import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/retry_safe_rpc.dart';

import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';

class SupabaseFarmerPayoutRepository implements FarmerPayoutRepository {
  const SupabaseFarmerPayoutRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<FarmerPayout>> loadPayouts() async {
    try {
      final response = await client.rpc<Object?>('current_farmer_payouts');
      if (response is! List) return const [];

      return response
          .whereType<Map>()
          .map((item) => FarmerPayout.fromJson(Map<String, Object?>.from(item)))
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<List<FarmerCashOutRequest>> loadCashOutRequests() async {
    try {
      final response = await client.rpc<Object?>(
        'current_user_payout_requests',
        params: {'p_user_role': 'farmer'},
      );
      if (response is! List) return const [];

      return response
          .whereType<Map>()
          .map(
            (item) =>
                FarmerCashOutRequest.fromJson(Map<String, Object?>.from(item)),
          )
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  @override
  Future<FarmerCashOutRequest> submitCashOutRequest(
    FarmerCashOutRequest request,
  ) async {
    final response =
        await RetrySafeRpc.call(client, 'submit_farmer_payout_once', {
          'p_amount': request.amount,
          'p_payout_method': request.payoutMethod,
          'p_account_name': request.accountName,
          'p_account_number': request.accountNumber,
          'p_bank_name': request.bankName.isNotEmpty ? request.bankName : null,
          'p_notes': request.notes.isNotEmpty ? request.notes : null,
        });

    if (response is Map) {
      return FarmerCashOutRequest.fromJson(Map<String, Object?>.from(response));
    }
    return request;
  }
}
