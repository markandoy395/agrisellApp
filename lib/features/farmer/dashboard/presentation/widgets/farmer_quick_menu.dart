import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

enum FarmerQuickDestination {
  products,
  messages,
  reservations,
  discounts,
  payouts,
  reviews,
  account,
}

Future<FarmerQuickDestination?> showFarmerQuickMenu(
  BuildContext context, {
  required FarmerQuickDestination current,
}) {
  return showModalBottomSheet<FarmerQuickDestination>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Text(
                'Quick access',
                style: SharedPresentationStyles.headingTitleExtraBold,
              ),
            ),
            for (final destination in FarmerQuickDestination.values)
              ListTile(
                selected: destination == current,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  destination.icon,
                  color: AgrisellColors.authGreen,
                  size: 22,
                ),
                title: Text(
                  destination.label,
                  style: SharedPresentationStyles.bodyBold,
                ),
                onTap: () => Navigator.of(context).pop(destination),
              ),
          ],
        ),
      ),
    ),
  );
}

extension on FarmerQuickDestination {
  String get label => switch (this) {
    FarmerQuickDestination.products => 'Products',
    FarmerQuickDestination.messages => 'Messages',
    FarmerQuickDestination.reservations => 'Reservations',
    FarmerQuickDestination.discounts => 'Discounts & Promos',
    FarmerQuickDestination.payouts => 'Payouts',
    FarmerQuickDestination.reviews => 'Customer Reviews',
    FarmerQuickDestination.account => 'Account',
  };

  IconData get icon => switch (this) {
    FarmerQuickDestination.products => Icons.inventory_2_outlined,
    FarmerQuickDestination.messages => Icons.sms_outlined,
    FarmerQuickDestination.reservations => Icons.receipt_long_outlined,
    FarmerQuickDestination.discounts => Icons.local_offer_outlined,
    FarmerQuickDestination.payouts => Icons.account_balance_wallet_outlined,
    FarmerQuickDestination.reviews => Icons.star_outline_rounded,
    FarmerQuickDestination.account => Icons.person_outline_rounded,
  };
}
