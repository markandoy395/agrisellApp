import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';

class BuyerShippingAddressRepository {
  const BuyerShippingAddressRepository(this._client);

  final SupabaseClient _client;

  Future<BuyerShippingAddress?> load() async {
    final buyer = await _client
        .from('buyers')
        .select('shipping_address,gps_lat,gps_long')
        .maybeSingle();
    final address = _text(buyer?['shipping_address']);
    return address == null
        ? null
        : BuyerShippingAddress(
            address: address,
            latitude: _latitude(buyer?['gps_lat']),
            longitude: _longitude(buyer?['gps_long']),
          );
  }

  Future<BuyerShippingAddress> save(BuyerShippingAddress address) async {
    await _client.rpc<Object?>(
      'set_current_buyer_shipping_address_location',
      params: {
        'address_value': address.address,
        'latitude_value': address.latitude,
        'longitude_value': address.longitude,
      },
    );
    return address;
  }

  String? _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  double? _latitude(Object? value) => _coordinate(value, -90, 90);

  double? _longitude(Object? value) => _coordinate(value, -180, 180);

  double? _coordinate(Object? value, double minimum, double maximum) {
    final coordinate = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');
    return coordinate != null &&
            coordinate.isFinite &&
            coordinate >= minimum &&
            coordinate <= maximum
        ? coordinate
        : null;
  }
}
