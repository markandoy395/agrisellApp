import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_version_footer.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/buyer/profile/presentation/styles/profile_screen_styles.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_account_tile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_deals_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/orders_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';

/// Builds the overview section widgets for the buyer profile list.
abstract final class BuyerProfileOverviewSections {
  static List<Widget> build({
    required UserProfile profile,
    required VoidCallback onOpenEditProfile,
    required Future<void> Function(BuyerShippingAddress) onSaveShippingAddress,
    required VoidCallback onOpenSafety,
    required VoidCallback onOpenIncidentHistory,
    required VoidCallback onOpenSupport,
    required VoidCallback onOpenSwitchAccount,
    required VoidCallback onOpenLogin,
  }) => [
    const BuyerDealsCard(),
    const SizedBox(height: ProfileScreenStyles.sectionSpacing),
    const BuyerSectionHeader('Orders & Activity'),
    const SizedBox(height: ProfileScreenStyles.sectionHeaderGap),
    const OrdersCard(),
    const SizedBox(height: ProfileScreenStyles.sectionSpacing),
    const BuyerSectionHeader('Account & Delivery'),
    const SizedBox(height: ProfileScreenStyles.sectionHeaderGap),
    BuyerPersonalInfoCard(
      profile: profile,
      onEditProfile: onOpenEditProfile,
      initiallyExpanded: false,
    ),
    const SizedBox(height: ProfileScreenStyles.addressSpacing),
    ShippingAddressCard(
      address: profile.address,
      latitude: profile.shippingLatitude,
      longitude: profile.shippingLongitude,
      fullName: profile.headerName,
      phoneNumber: profile.phoneNumber,
      onSave: onSaveShippingAddress,
    ),
    const SizedBox(height: ProfileScreenStyles.sectionSpacing),
    const BuyerSectionHeader('Safety & Support'),
    const SizedBox(height: ProfileScreenStyles.sectionHeaderGap),
    BuyerProfileCard(
      child: Column(
        children: [
          BuyerAccountTile(
            icon: Icons.shield_outlined,
            title: 'Safety & Emergency SOS',
            onTap: onOpenSafety,
          ),
          const Divider(height: 1, color: ProfileScreenStyles.normalDivider),
          BuyerAccountTile(
            icon: Icons.history_rounded,
            title: 'Incident History & Status',
            onTap: onOpenIncidentHistory,
          ),
          const Divider(height: 1, color: ProfileScreenStyles.normalDivider),
          BuyerAccountTile(
            icon: Icons.support_agent_rounded,
            title: 'Customer Support Tickets',
            onTap: onOpenSupport,
          ),
        ],
      ),
    ),
    const SizedBox(height: ProfileScreenStyles.sectionSpacing),
    const BuyerSectionHeader('Session'),
    const SizedBox(height: ProfileScreenStyles.sectionHeaderGap),
    BuyerProfileCard(
      child: Column(
        children: [
          BuyerAccountTile(
            icon: Icons.switch_account_outlined,
            title: 'Switch Account',
            onTap: onOpenSwitchAccount,
          ),
          const Divider(height: 1, color: ProfileScreenStyles.sessionDivider),
          BuyerAccountTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            onTap: onOpenLogin,
            destructive: true,
          ),
        ],
      ),
    ),
    const AppVersionFooter(),
  ];
}
