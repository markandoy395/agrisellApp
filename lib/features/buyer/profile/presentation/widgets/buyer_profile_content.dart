import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_entrance_animation.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_info_card.dart';
import 'package:agresell_app/features/buyer/deals/presentation/screens/deals_and_promos_screen.dart';

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
      const SizedBox(height: 18),
      HomeEntranceAnimation(
        delay: const Duration(milliseconds: 240),
        offset: const Offset(0, 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
            ),
            title: const Text(
              'Voucher Wallet & Deals',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: const Text(
              'Browse available vouchers and discounts',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black38,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DealsAndPromosScreen(),
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}
