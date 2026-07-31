import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_components.dart';
import 'package:agresell_app/features/shared/widgets/profile/font_size_settings_control.dart';

class RiderProfileActions extends StatelessWidget {
  const RiderProfileActions({
    required this.onEarnings,
    required this.onHistory,
    required this.onRatings,
    required this.onEdit,
    required this.onVehicle,
    required this.onDocuments,
    required this.onChangePassword,
    required this.onSafety,
    required this.onSwitchAccount,
    required this.onLogout,
    super.key,
  });

  final VoidCallback onEarnings;
  final VoidCallback onHistory;
  final VoidCallback onRatings;
  final VoidCallback onEdit;
  final VoidCallback onVehicle;
  final VoidCallback onDocuments;
  final VoidCallback onChangePassword;
  final VoidCallback onSafety;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      children: [
        RiderProfileAction(
          label: 'Earnings',
          icon: Icons.account_balance_wallet_outlined,
          onTap: onEarnings,
        ),
        RiderProfileAction(
          label: 'Delivery history',
          icon: Icons.history_rounded,
          onTap: onHistory,
        ),
        RiderProfileAction(
          label: 'Ratings & reviews',
          icon: Icons.star_outline_rounded,
          onTap: onRatings,
        ),
        RiderProfileAction(
          label: 'Edit profile',
          icon: Icons.edit_outlined,
          onTap: onEdit,
        ),
        RiderProfileAction(
          label: 'Vehicle details',
          icon: Icons.two_wheeler_outlined,
          onTap: onVehicle,
        ),
        RiderProfileAction(
          label: 'Verification documents',
          icon: Icons.folder_shared_outlined,
          onTap: onDocuments,
        ),
        RiderProfileAction(
          label: 'Change password',
          icon: Icons.lock_outline_rounded,
          onTap: onChangePassword,
        ),
        const Divider(height: 1),
        const FontSizeSettingsControl(),
        const Divider(height: 1),
        RiderProfileAction(
          label: 'Safety & report a problem',
          icon: Icons.shield_outlined,
          onTap: onSafety,
        ),
        RiderProfileAction(
          label: 'Switch account',
          icon: Icons.switch_account_outlined,
          onTap: onSwitchAccount,
        ),
        RiderProfileAction(
          label: 'Logout',
          icon: Icons.logout_rounded,
          color: AgrisellColors.statusRedText,
          onTap: onLogout,
        ),
      ],
    ),
  );
}
