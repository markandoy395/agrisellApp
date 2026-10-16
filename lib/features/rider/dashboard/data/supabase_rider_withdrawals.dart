import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/rider_wallet.dart';
import '../domain/rider_withdrawal_models.dart';
import 'rider_analytics_repository.dart';

mixin SupabaseRiderWithdrawals
    implements RiderAnalyticsRepository, RiderWalletRepository {
  SupabaseClient get payoutClient;

  @override
  Future<RiderWallet> fetchWallet() async => RiderWallet.fromJson(
    _map(await payoutClient.rpc<Object?>('current_rider_wallet')),
  );

  @override
  Future<List<RiderWithdrawalMethod>> fetchWithdrawalMethods({
    required String riderId,
  }) async => _rows(
    await payoutClient.rpc<Object?>(
      'current_user_withdrawal_methods',
      params: {'p_user_role': 'rider'},
    ),
  ).map(RiderWithdrawalMethod.fromJson).toList(growable: false);

  @override
  Future<RiderWithdrawalMethod> saveWithdrawalMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  }) async => RiderWithdrawalMethod.fromJson(
    _map(
      await payoutClient.rpc<Object?>(
        'save_user_withdrawal_method',
        params: {
          'p_payout_method': method.payoutMethod,
          'p_account_name': method.accountName,
          'p_account_number': method.accountNumber,
          'p_bank_name': method.bankName.isNotEmpty ? method.bankName : null,
          'p_is_default': method.isDefault,
          'p_user_role': 'rider',
        },
      ),
    ),
  );

  @override
  Future<void> deleteWithdrawalMethod({
    required String riderId,
    required String methodId,
  }) async {
    await payoutClient.rpc<Object?>(
      'delete_user_withdrawal_method',
      params: {'p_method_id': methodId},
    );
  }

  @override
  Future<RiderWithdrawalRequest> submitWithdrawalRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  }) async => RiderWithdrawalRequest.fromJson(
    _map(
      await payoutClient.rpc<Object?>(
        'submit_rider_payout_request',
        params: {
          'p_method_id': request.withdrawalMethodId,
          'p_amount': request.amount,
          'p_request_key': request.requestId,
          'p_notes': request.notes.trim().isEmpty ? null : request.notes.trim(),
        },
      ),
    ),
  );

  @override
  Future<List<RiderWithdrawalRequest>> fetchWithdrawalRequests({
    required String riderId,
  }) async => _rows(
    await payoutClient.rpc<Object?>(
      'current_user_payout_requests',
      params: {'p_user_role': 'rider'},
    ),
  ).map(RiderWithdrawalRequest.fromJson).toList(growable: false);
}

List<Map<String, Object?>> _rows(Object? value) =>
    value is List ? value.map(_map).toList(growable: false) : const [];

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};
