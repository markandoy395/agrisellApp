import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_action_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_layout.dart';

class RiderProfileActions extends StatelessWidget {
  const RiderProfileActions({
    required this.onEarnings,
    required this.onHistory,
    required this.onRatings,
    super.key,
  });

  final VoidCallback onEarnings;
  final VoidCallback onHistory;
  final VoidCallback onRatings;

  @override
  Widget build(BuildContext context) => ProfileCardShell(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel(text: 'Activity'),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: ProfileSettingsGroup(
            title: 'Delivery',
            children: [
              ProfileSettingsActionRow(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Earnings',
                subtitle: 'Review your delivery income',
                onTap: onEarnings,
              ),
              ProfileSettingsActionRow(
                icon: Icons.history_rounded,
                title: 'Delivery history',
                subtitle: 'View completed and past deliveries',
                onTap: onHistory,
              ),
              ProfileSettingsActionRow(
                icon: Icons.star_outline_rounded,
                title: 'Ratings & reviews',
                subtitle: 'See ratings and buyer feedback',
                onTap: onRatings,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
