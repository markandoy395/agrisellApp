import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';

class FarmerMessageActions extends StatelessWidget {
  const FarmerMessageActions({
    required this.onViewOrder,
    required this.onConfirmReserve,
    required this.onMarkToShip,
    super.key,
  });

  final VoidCallback onViewOrder;
  final VoidCallback onConfirmReserve;
  final VoidCallback onMarkToShip;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionButton(
          icon: Icons.receipt_long_rounded,
          label: 'View Order',
          onPressed: onViewOrder,
        ),
        _ActionButton(
          icon: Icons.check_circle_outline_rounded,
          label: 'Confirm Reserve',
          onPressed: onConfirmReserve,
        ),
        _ActionButton(
          icon: Icons.local_shipping_outlined,
          label: 'Mark as To Ship',
          onPressed: onMarkToShip,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: OutlinedButton.styleFrom(
          foregroundColor: AgrisellColors.authGreen,
          side: const BorderSide(color: AgrisellColors.authGreen),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 12,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
