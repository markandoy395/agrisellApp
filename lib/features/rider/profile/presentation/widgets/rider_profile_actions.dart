import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';

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
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.account_balance_wallet_rounded,
        AgrisellColors.statusBlueText,
        'Earnings',
        'Review your delivery income',
        onEarnings,
      ),
      (
        Icons.inventory_2_rounded,
        AgrisellColors.accentOrange,
        'Delivery history',
        'View completed and past deliveries',
        onHistory,
      ),
      (
        Icons.star_rounded,
        AgrisellColors.statusOrangeText,
        'Ratings & reviews',
        'See ratings and buyer feedback',
        onRatings,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth < 350 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.2
            ? 1
            : 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final action in actions)
              SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 10) / columns,
                child: Semantics(
                  button: true,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: action.$5,
                      borderRadius: RiderProfileDesignStyles.radius,
                      child: RiderProfileCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(action.$1, size: 32, color: action.$2),
                            const SizedBox(height: 14),
                            Text(
                              action.$3,
                              style: RiderProfileDesignStyles.body,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              action.$4,
                              style: RiderProfileDesignStyles.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
