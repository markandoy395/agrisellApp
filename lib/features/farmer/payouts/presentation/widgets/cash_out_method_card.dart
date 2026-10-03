import 'package:flutter/material.dart';

import '../styles/cash_out_dialog_styles.dart';

class CashOutMethodCard extends StatelessWidget {
  const CashOutMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: CashOutDialogStyles.methodRadius,
      child: Container(
        padding: CashOutDialogStyles.methodPadding,
        decoration: isSelected
            ? CashOutDialogStyles.selectedMethod
            : CashOutDialogStyles.unselectedMethod,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? CashOutDialogStyles.green
                      : CashOutDialogStyles.muted,
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: CashOutDialogStyles.green,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: isSelected
                  ? CashOutDialogStyles.selectedMethodTitle
                  : CashOutDialogStyles.unselectedMethodTitle,
            ),
            Text(subtitle, style: CashOutDialogStyles.methodSubtitle),
          ],
        ),
      ),
    );
  }
}
