import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_rider_confirmation_styles.dart';

class FarmerRiderConfirmationDetailRow extends StatelessWidget {
  const FarmerRiderConfirmationDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: FarmerRiderConfirmationStyles.detailPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: FarmerRiderConfirmationStyles.green,
          size: 21,
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FarmerRiderConfirmationStyles.detailLabelStyle,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: FarmerRiderConfirmationStyles.detailValueStyle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
