import 'package:supabase_flutter/supabase_flutter.dart';

/// Voucher text is an RPC value, never SQL or a wildcard filter expression.
class CheckoutVoucherLookup {
  const CheckoutVoucherLookup(this.client);

  final SupabaseClient client;

  Future<Map<String, dynamic>?> load(String code) async {
    final value = await client.rpc<Object?>(
      'current_checkout_voucher',
      params: {'p_code': code},
    );
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }
}
