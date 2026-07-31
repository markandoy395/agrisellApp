import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_info_card.dart';

class BuyerProfileContent extends StatelessWidget {
  const BuyerProfileContent({
    required this.profile,
    required this.isEditing,
    required this.onCancelEdit,
    required this.onSaveProfile,
    required this.onSaveShippingAddress,
    super.key,
  });

  final UserProfile profile;
  final bool isEditing;
  final VoidCallback onCancelEdit;
  final ValueChanged<UserProfile> onSaveProfile;
  final Future<void> Function(BuyerShippingAddress address)
  onSaveShippingAddress;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const HomeEntranceAnimation(child: OrdersCard()),
      const SizedBox(height: 18),
      HomeEntranceAnimation(
        delay: const Duration(milliseconds: 120),
        offset: const Offset(0, 0.05),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeOutCubic,
          child: isEditing
              ? ProfileEditCard(
                  key: const ValueKey('profile-edit-card'),
                  profile: profile,
                  onCancel: onCancelEdit,
                  onSave: onSaveProfile,
                )
              : ProfileInfoCard(
                  key: const ValueKey('profile-info-card'),
                  entries: profile.infoEntries,
                ),
        ),
      ),
      const SizedBox(height: 18),
      HomeEntranceAnimation(
        delay: const Duration(milliseconds: 180),
        offset: const Offset(0, 0.05),
        child: ShippingAddressCard(
          address: profile.address,
          latitude: profile.shippingLatitude,
          longitude: profile.shippingLongitude,
          fullName: profile.headerName,
          phoneNumber: profile.phoneNumber,
          onSave: onSaveShippingAddress,
        ),
      ),
    ],
  );
}
