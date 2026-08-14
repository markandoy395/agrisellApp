import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

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
    final latitude = saved.shippingLatitude ?? address.latitude;
    final longitude = saved.shippingLongitude ?? address.longitude;
    if (latitude != null && longitude != null) {
      await ConfirmedLocationRepository().confirm(
        LocationOwnerRole.buyer,
        ConfirmedLocation(
          latitude: latitude,
          longitude: longitude,
          accuracyMeters: 0,
          capturedAt: DateTime.now(),
          address: saved.shippingAddress ?? address.address,
        ),
      );
    }
    return profile.copyWith(
      address: saved.shippingAddress ?? address.address,
      shippingLatitude: latitude,
      shippingLongitude: longitude,
    );
  }
}
