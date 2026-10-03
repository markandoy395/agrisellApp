import 'package:flutter/material.dart';

import '../styles/farmer_discount_dialog_styles.dart';

class FarmerDiscountDateButton extends StatelessWidget {
  const FarmerDiscountDateButton({
    super.key,
    required this.date,
    required this.placeholder,
    required this.icon,
    required this.onPressed,
  });

  final DateTime? date;
  final String placeholder;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Expanded(
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(
        date == null
            ? placeholder
            : '${date!.month}/${date!.day}/${date!.year}',
        style: FarmerDiscountDialogStyles.dateLabel,
      ),
      style: FarmerDiscountDialogStyles.dateButton,
    ),
  );
}
