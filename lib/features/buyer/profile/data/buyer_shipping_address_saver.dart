import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';

abstract final class BuyerShippingAddressSaver {
  static Future<UserProfile> save(
    UserProfile profile,
    BuyerShippingAddress address,
  ) async {
    final account = AuthSessionService.instance.currentAccount;
    if (account == null) {
      throw const AuthRegistrationException('Please log in again.');
    }
    final saved = await AuthRegistrationService.instance
        .saveBuyerShippingAddress(account, address);
    return profile.copyWith(
      address: saved.shippingAddress ?? address.address,
      shippingLatitude: saved.shippingLatitude,
      shippingLongitude: saved.shippingLongitude,
    );
  }
}
